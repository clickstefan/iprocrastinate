#!/bin/bash

# Quick Validation Script
# Fast checks for most common CI issues (30 seconds or less)

echo "⚡ Quick Validation Check"
echo "========================"
echo "Running essential checks to catch common CI failures..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

quick_status=0

# Function for quick status
quick_check() {
    local name="$1"
    local command="$2"
    echo -n "  $name... "

    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        return 0
    else
        echo -e "${RED}❌${NC}"
        return 1
    fi
}

# 1. Dependencies (most common CI failure)
echo "📦 Dependencies"
if quick_check "dart pub get" "dart pub get"; then
    echo -e "   ${GREEN}Dependencies resolve correctly${NC}"
else
    echo -e "   ${RED}Dependency issues found - run 'dart pub get' for details${NC}"
    quick_status=1
fi

# 2. Code Formatting (second most common)
echo ""
echo "🎨 Formatting"
if dart format --output=none --set-exit-if-changed . >/dev/null 2>&1; then
    echo -e "   ${GREEN}✅ Code properly formatted${NC}"
else
    echo -e "   ${RED}❌ Formatting issues - run 'dart format .' to fix${NC}"
    quick_status=1
fi

# 3. Basic Analysis (catches most syntax errors)
echo ""
echo "🔍 Analysis"
if quick_check "dart analyze" "dart analyze --fatal-warnings"; then
    echo -e "   ${GREEN}Static analysis passed${NC}"
else
    echo -e "   ${RED}Analysis issues - run 'dart analyze' for details${NC}"
    quick_status=1
fi

# 4. Build Test (catches compilation errors)
echo ""
echo "🏗️  Build"
if quick_check "test compile" "dart compile js lib/main.dart -o .quick_test_build.js"; then
    echo -e "   ${GREEN}Code compiles successfully${NC}"
    rm -f .quick_test_build.js* 2>/dev/null
else
    echo -e "   ${RED}Compilation errors found${NC}"
    quick_status=1
fi

# Quick Summary
echo ""
echo "⚡ Quick Check Summary"
echo "====================="

if [ $quick_status -eq 0 ]; then
    echo -e "${GREEN}✅ All quick checks passed!${NC}"
    echo -e "   ${GREEN}Most likely to pass CI${NC}"
    echo ""
    echo "💡 For comprehensive validation:"
    echo "   ./scripts/pre_commit_check.sh  # Full validation"
    echo "   ./scripts/simulate_ci.sh       # Complete CI simulation"
else
    echo -e "${RED}❌ Some quick checks failed${NC}"
    echo -e "   ${RED}Would likely fail in CI${NC}"
    echo ""
    echo "🔧 Quick fixes:"
    echo "   dart pub get      # Fix dependencies"
    echo "   dart format .     # Fix formatting"
    echo "   dart analyze      # See analysis issues"
    echo ""
    echo "📋 For detailed diagnostics:"
    echo "   ./scripts/pre_commit_check.sh"
fi

echo ""
echo "⏱️  Quick check completed in ~10 seconds"

exit $quick_status