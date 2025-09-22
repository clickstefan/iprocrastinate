#!/bin/bash

# Local CI Simulation Script
# Simulates the exact GitHub Actions CI pipeline locally
# Helps identify CI issues before pushing

set -e

echo "🤖 Local CI Simulation"
echo "====================="
echo "Simulating GitHub Actions CI/CD Pipeline locally..."
echo ""

# Configuration (matches CI environment)
OUTPUT_DIR="docs"
export OUTPUT_DIR

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Function to simulate CI job
simulate_job() {
    local job_name="$1"
    local job_emoji="$2"
    shift 2

    echo -e "${PURPLE}🔄 JOB: $job_emoji $job_name${NC}"
    echo "----------------------------------------"

    local start_time=$(date +%s)
    local job_status=0

    # Run each step
    for step in "$@"; do
        echo -n "  ⚡ $step... "

        case "$step" in
            "Setup Dart SDK")
                if command -v dart >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌ Dart not found${NC}"
                    job_status=1
                fi
                ;;
            "Install dependencies")
                if dart pub get >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌${NC}"
                    job_status=1
                fi
                ;;
            "Verify formatting")
                if dart format --output=none --set-exit-if-changed . >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌ Code formatting issues${NC}"
                    job_status=1
                fi
                ;;
            "Analyze project source")
                if dart analyze --fatal-warnings >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌ Analysis issues${NC}"
                    job_status=1
                fi
                ;;
            "Run unit tests")
                if dart test >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌ Test failures${NC}"
                    job_status=1
                fi
                ;;
            "Run TWA compatibility tests")
                if [ -f "scripts/check_twa_compatibility.sh" ] && ./scripts/check_twa_compatibility.sh >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌ TWA compatibility issues${NC}"
                    job_status=1
                fi
                ;;
            "Build optimized JavaScript")
                if dart compile js -O2 lib/main.dart -o .ci_test_build.js >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                    rm -f .ci_test_build.js* 2>/dev/null
                else
                    echo -e "${RED}❌ Build failed${NC}"
                    job_status=1
                fi
                ;;
            "Copy static assets")
                # Simulate copying static assets
                if [ -f "$OUTPUT_DIR/index.html" ] && [ -f "$OUTPUT_DIR/styles.css" ]; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${YELLOW}⚠️  Some assets missing${NC}"
                fi
                ;;
            "Validate build output")
                local required_files=("index.html" "main.dart.js" "styles.css" "manifest.json")
                local all_present=true

                for file in "${required_files[@]}"; do
                    if [ ! -f "$OUTPUT_DIR/$file" ]; then
                        all_present=false
                        break
                    fi
                done

                if $all_present; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${RED}❌ Required files missing${NC}"
                    job_status=1
                fi
                ;;
            "Security audit")
                # Simple dependency check
                if dart pub deps >/dev/null 2>&1; then
                    echo -e "${GREEN}✅${NC}"
                else
                    echo -e "${YELLOW}⚠️  Dependency issues${NC}"
                fi
                ;;
            "Performance check")
                # Build temporarily for size check
                if dart compile js -O2 lib/main.dart -o .perf_test_build.js >/dev/null 2>&1; then
                    local js_size=$(wc -c < .perf_test_build.js)
                    local js_size_kb=$((js_size / 1024))
                    rm -f .perf_test_build.js* 2>/dev/null

                    if [ $js_size -lt 500000 ]; then
                        echo -e "${GREEN}✅ (${js_size_kb}KB)${NC}"
                    else
                        echo -e "${YELLOW}⚠️  Large bundle (${js_size_kb}KB)${NC}"
                    fi
                else
                    echo -e "${YELLOW}⚠️  Build failed${NC}"
                fi
                ;;
            *)
                echo -e "${BLUE}ℹ️  Simulated${NC}"
                ;;
        esac

        sleep 0.1  # Simulate processing time
    done

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ $job_status -eq 0 ]; then
        echo -e "  ${GREEN}✅ JOB PASSED${NC} (${duration}s)"
    else
        echo -e "  ${RED}❌ JOB FAILED${NC} (${duration}s)"
    fi

    echo ""
    return $job_status
}

# Track overall pipeline status
pipeline_status=0

# Simulate each CI job
echo "🚀 Starting CI Pipeline Simulation..."
echo ""

# Job 1: Test & Lint
if ! simulate_job "Test & Lint" "🧪" \
    "Setup Dart SDK" \
    "Install dependencies" \
    "Verify formatting" \
    "Analyze project source" \
    "Run unit tests" \
    "Run TWA compatibility tests"; then
    pipeline_status=1
fi

# Job 2: Build Web App
if ! simulate_job "Build Web App" "🏗️" \
    "Setup Dart SDK" \
    "Install dependencies" \
    "Build optimized JavaScript" \
    "Copy static assets" \
    "Validate build output"; then
    pipeline_status=1
fi

# Job 3: Quality & Security
if ! simulate_job "Quality & Security" "🔍" \
    "Setup Dart SDK" \
    "Install dependencies" \
    "Security audit" \
    "Performance check"; then
    # Don't fail pipeline for quality warnings
    echo -e "  ${YELLOW}⚠️  Quality job had warnings but pipeline continues${NC}"
fi

# Job 4: Deploy (simulation only)
simulate_job "Deploy Simulation" "🚀" \
    "Upload to GitHub Pages" \
    "Deploy to GitHub Pages" >/dev/null

# Pipeline Summary
echo "📊 CI Pipeline Simulation Results"
echo "================================="

if [ $pipeline_status -eq 0 ]; then
    echo -e "${GREEN}🎉 PIPELINE SUCCESS${NC}"
    echo ""
    echo -e "${GREEN}✅ All critical jobs would pass in CI${NC}"
    echo -e "${BLUE}ℹ️  Your code is ready to push${NC}"
    echo ""
    echo "🔗 Comparison with actual CI:"
    echo "   • Test & Lint: Fully simulated"
    echo "   • Build: Fully simulated"
    echo "   • Quality: Fully simulated"
    echo "   • Deploy: GitHub Pages only (requires push)"
else
    echo -e "${RED}💥 PIPELINE FAILURE${NC}"
    echo ""
    echo -e "${RED}❌ CI would fail with current code${NC}"
    echo -e "${YELLOW}⚠️  Fix issues before pushing${NC}"
    echo ""
    echo "🔧 Recommended fixes:"
    echo "   • Run individual commands to see specific errors"
    echo "   • Use './scripts/pre_commit_check.sh' for detailed diagnostics"
    echo "   • Check the failed job steps above"
fi

echo ""
echo "📋 Quick Commands:"
echo "  ./scripts/pre_commit_check.sh    # Detailed diagnostics"
echo "  dart format .                    # Fix formatting"
echo "  dart analyze                     # See analysis issues"
echo "  dart test                        # Run tests with output"
echo "  ./scripts/check_twa_compatibility.sh  # Check TWA"

# Cleanup temporary files
rm -f /tmp/ci_simulation_* 2>/dev/null || true

exit $pipeline_status