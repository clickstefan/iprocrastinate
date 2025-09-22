#!/bin/bash

# Pre-Commit Validation Script
# Runs the same checks as CI locally to catch issues before committing

set -e

echo "🔍 Pre-Commit Validation"
echo "========================"
echo "Running the same checks as GitHub Actions CI..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
        "success") echo -e "${GREEN}✅ $message${NC}" ;;
        "warning") echo -e "${YELLOW}⚠️  $message${NC}" ;;
        "error") echo -e "${RED}❌ $message${NC}" ;;
        "info") echo -e "${BLUE}ℹ️  $message${NC}" ;;
    esac
}

# Function to run check with status reporting
run_check() {
    local name="$1"
    local command="$2"
    local error_msg="$3"

    echo -n "🔍 $name... "

    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✅${NC}"
        return 0
    else
        echo -e "${RED}❌${NC}"
        print_status "error" "$error_msg"
        return 1
    fi
}

# Track overall status
overall_status=0

# 1. Check Dart SDK version compatibility
echo "📋 Step 1: Environment Validation"
echo "--------------------------------"

dart_version=$(dart --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
print_status "info" "Local Dart SDK: $dart_version"

if [[ $(echo "$dart_version 3.2.0" | tr ' ' '\n' | sort -V | head -1) == "3.2.0" ]]; then
    print_status "success" "Dart SDK version compatible with CI"
else
    print_status "warning" "Dart SDK might be too old for web package (needs >=3.2.0)"
fi

echo ""

# 2. Dependency Resolution
echo "📦 Step 2: Dependency Resolution"
echo "--------------------------------"

if run_check "Checking pubspec.yaml" "dart pub deps --json >/dev/null" "pubspec.yaml has dependency issues"; then
    print_status "success" "Dependencies resolve correctly"
else
    print_status "error" "Run 'dart pub get' to see dependency errors"
    overall_status=1
fi

if run_check "Installing dependencies" "dart pub get" "Failed to install dependencies"; then
    print_status "success" "All dependencies installed"
else
    overall_status=1
fi

echo ""

# 3. Code Formatting (same as CI)
echo "🎨 Step 3: Code Formatting"
echo "--------------------------"

# Check if code is properly formatted
if dart format --output=none --set-exit-if-changed . >/dev/null 2>&1; then
    print_status "success" "Code is properly formatted"
else
    print_status "error" "Code formatting issues found. Run 'dart format .' to fix"
    echo ""
    print_status "info" "Files that need formatting:"
    dart format --output=none --set-exit-if-changed . 2>&1 | grep "^Changed" || true
    overall_status=1
fi

echo ""

# 4. Static Analysis (same as CI)
echo "🔍 Step 4: Static Analysis"
echo "--------------------------"

# Run analysis with same settings as CI
analysis_output=$(dart analyze --fatal-warnings 2>&1)
analysis_status=$?

if [ $analysis_status -eq 0 ]; then
    print_status "success" "Static analysis passed"
else
    print_status "error" "Static analysis found issues:"
    echo "$analysis_output" | grep -E "(error|warning|info)" | head -10
    overall_status=1
fi

echo ""

# 5. Tests (same as CI)
echo "🧪 Step 5: Test Execution"
echo "-------------------------"

if run_check "Unit tests" "dart test" "Unit tests failed"; then
    print_status "success" "All unit tests passed"
else
    print_status "error" "Run 'dart test' to see test failures"
    overall_status=1
fi

echo ""

# 6. TWA Compatibility (same as CI)
echo "📱 Step 6: TWA Compatibility"
echo "----------------------------"

if [ -f "scripts/check_twa_compatibility.sh" ]; then
    if run_check "TWA compatibility tests" "./scripts/check_twa_compatibility.sh >/dev/null" "TWA compatibility issues found"; then
        print_status "success" "TWA compatibility verified"
    else
        print_status "error" "Run './scripts/check_twa_compatibility.sh' to see TWA issues"
        overall_status=1
    fi
else
    print_status "warning" "TWA compatibility script not found"
fi

echo ""

# 7. Build Test (same as CI)
echo "🏗️  Step 7: Build Validation"
echo "----------------------------"

# Test if the build works
if run_check "JavaScript compilation" "dart compile js lib/main.dart -o .test_build.js" "Build compilation failed"; then
    print_status "success" "Build compiles successfully"
    rm -f .test_build.js .test_build.js.deps .test_build.js.map 2>/dev/null
else
    print_status "error" "Build would fail in CI"
    overall_status=1
fi

# Check build size (performance threshold)
if [ -f "docs/main.dart.js" ]; then
    js_size=$(wc -c < docs/main.dart.js)
    js_size_kb=$((js_size / 1024))

    if [ $js_size -lt 500000 ]; then
        print_status "success" "JavaScript bundle size: ${js_size_kb}KB (optimal)"
    else
        print_status "warning" "JavaScript bundle size: ${js_size_kb}KB (consider optimization)"
    fi
fi

echo ""

# 8. Git Status Check
echo "📋 Step 8: Git Status"
echo "---------------------"

# Check for uncommitted changes that might affect CI
uncommitted=$(git status --porcelain | wc -l)
if [ "$uncommitted" -gt 0 ]; then
    print_status "warning" "You have $uncommitted uncommitted changes"
    print_status "info" "Make sure to commit all changes before pushing"
else
    print_status "success" "No uncommitted changes"
fi

echo ""

# Summary
echo "📊 Pre-Commit Validation Summary"
echo "================================"

if [ $overall_status -eq 0 ]; then
    print_status "success" "All checks passed! ✨ Ready to commit"
    echo ""
    print_status "info" "Your commit should pass CI without issues"
    echo ""
    echo "💡 Quick commands for next steps:"
    echo "   git add ."
    echo "   git commit -m \"Your commit message\""
    echo "   git push"
else
    print_status "error" "Some checks failed! ⚠️  Fix issues before committing"
    echo ""
    print_status "info" "Common fixes:"
    echo "   • dart format .              # Fix formatting"
    echo "   • dart pub get               # Fix dependencies"
    echo "   • dart analyze               # See analysis issues"
    echo "   • dart test                  # Run failing tests"
    echo ""
    exit 1
fi

echo ""
print_status "info" "To auto-run this before every commit, use: ./scripts/setup_git_hooks.sh"