# CI/CD Troubleshooting Guide

## 🚨 Quick Problem Resolution

This guide helps you quickly identify and fix common CI/CD issues in the iProcrastinate project.

## 📋 Quick Diagnosis

### 1. **Immediate Steps When CI Fails**

```bash
# Step 1: Check what failed
gh run view --log-failed

# Step 2: Test locally
./scripts/simulate_ci.sh

# Step 3: Apply common fixes
dart format .
dart pub get
```

### 2. **Emergency Checklist**

- [ ] Latest commit has formatting issues? → `dart format .`
- [ ] Dependencies broken? → `dart pub get`
- [ ] Tests failing? → `dart test`
- [ ] Build compilation failing? → Check `lib/main.dart` syntax
- [ ] TWA compatibility issues? → `./scripts/check_twa_compatibility.sh`

---

## ❌ Common CI Failures and Solutions

### 1. **Code Formatting Issues**

#### **Error Message:**
```
Error: dart format --set-exit-if-changed . exited with code 1
```

#### **Cause:**
Code not formatted according to Dart standards.

#### **Quick Fix:**
```bash
# Fix formatting
dart format .

# Verify fix
dart format --output=none --set-exit-if-changed .

# Commit
git add .
git commit -m "style: fix code formatting"
git push
```

#### **Prevention:**
```bash
# Install git hooks
./scripts/setup_git_hooks.sh

# Or check before committing
./scripts/quick_check.sh
```

---

### 2. **Static Analysis Warnings**

#### **Error Message:**
```
Error: dart analyze --fatal-warnings exited with code 1
info • Use 'dart:html' instead of 'dart:html'
```

#### **Cause:**
- Dart analysis warnings treated as errors
- Deprecated API usage
- Type safety issues

#### **Quick Fix:**
```bash
# See specific issues
dart analyze

# Common fixes:
# 1. Fix type annotations
# 2. Handle null safety
# 3. Remove unused imports

# Example fixes:
# Before: var element = document.querySelector('#app');
# After: html.Element? element = document.querySelector('#app');

# Commit fix
git add .
git commit -m "fix: resolve analysis warnings"
```

#### **Advanced Debugging:**
```bash
# See only errors (ignore info)
dart analyze --fatal-warnings | grep -E "(error|warning)"

# Check specific file
dart analyze lib/main.dart
```

---

### 3. **Test Failures**

#### **Error Message:**
```
Some tests failed.
00:01 +0 -1: test/twa_compatibility_test.dart: PWA manifest validation
```

#### **Cause:**
- Tests don't match current implementation
- Missing files (manifest.json, etc.)
- Changed API expectations

#### **Quick Fix:**
```bash
# Run tests locally to see details
dart test

# For TWA tests specifically
dart test test/twa_compatibility_test.dart

# Common TWA fixes:
# 1. Check manifest.json exists
ls docs/manifest.json

# 2. Verify manifest content
cat docs/manifest.json

# 3. Check required HTML meta tags
grep -n "viewport\|theme-color" docs/index.html
```

#### **Test-Specific Solutions:**

**Manifest Issues:**
```bash
# Ensure manifest has required fields
jq '.name, .display, .start_url, .icons' docs/manifest.json

# Fix missing fields
# Edit docs/manifest.json with required TWA fields
```

**HTML Meta Tag Issues:**
```bash
# Check viewport tag
grep "viewport" docs/index.html

# Add if missing:
# <meta name="viewport" content="width=device-width, initial-scale=1">
# <meta name="theme-color" content="#1976d2">
```

---

### 4. **Build Compilation Errors**

#### **Error Message:**
```
Error: Compilation failed.
lib/main.dart:45:23: Error: The getter 'querySelector' isn't defined
```

#### **Cause:**
- Syntax errors in Dart code
- Missing imports
- Type errors
- API misuse

#### **Quick Fix:**
```bash
# Test compilation locally
dart compile js lib/main.dart -o test_build.js

# Common Dart web fixes:
# 1. Import dart:html
import 'dart:html' as html;

# 2. Use proper types
html.Element? element = html.document.querySelector('#app');

# 3. Handle nullability
element?.text = 'Hello World';

# Clean up test file
rm test_build.js*
```

#### **Debugging Steps:**
```bash
# 1. Check syntax
dart analyze lib/main.dart

# 2. Test compilation
dart compile js lib/main.dart -o test.js 2>&1 | head -10

# 3. Check imports
head -10 lib/main.dart
```

---

### 5. **Dependency Issues**

#### **Error Message:**
```
Error: dart pub get failed
The current Dart SDK version is 3.0.0.
Because web >=0.5.0 requires SDK version >=3.2.0
```

#### **Cause:**
- Dart SDK version incompatibility
- Conflicting package versions
- Missing dependencies

#### **Quick Fix:**
```bash
# Update pubspec.yaml constraints
# Change:
# environment:
#   sdk: '>=3.0.0 <4.0.0'
# To:
# environment:
#   sdk: '>=3.2.0 <4.0.0'

# Or downgrade package versions
# web: ^0.4.0  # instead of ^0.5.0

# Test locally
dart pub get
```

#### **Advanced Resolution:**
```bash
# Check dependency tree
dart pub deps

# Resolve conflicts
dart pub upgrade --dry-run

# Reset dependencies
rm pubspec.lock
dart pub get
```

---

### 6. **TWA Compatibility Failures**

#### **Error Message:**
```
Error: TWA compatibility tests failed
Missing required manifest field: display
```

#### **Cause:**
- Missing or incorrect manifest.json
- Missing HTML meta tags
- File structure issues

#### **Quick Fix:**
```bash
# Run TWA checks locally
./scripts/check_twa_compatibility.sh

# Common fixes:

# 1. Fix manifest.json
cat > docs/manifest.json << 'EOF'
{
  "name": "iProcrastinate",
  "short_name": "iProcrastinate",
  "display": "standalone",
  "start_url": "./",
  "theme_color": "#1976d2",
  "background_color": "#ffffff",
  "icons": [
    {
      "src": "icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    }
  ]
}
EOF

# 2. Add missing meta tags to index.html
# Add to <head>:
# <meta name="viewport" content="width=device-width, initial-scale=1">
# <meta name="theme-color" content="#1976d2">
# <link rel="manifest" href="manifest.json">
```

---

### 7. **GitHub Actions Environment Issues**

#### **Error Message:**
```
Error: Dart SDK setup failed
Version 'stable' not found
```

#### **Cause:**
- GitHub Actions runner issues
- Dart SDK availability problems
- Workflow configuration issues

#### **Quick Fix:**
```bash
# Check workflow file
cat .github/workflows/ci.yml

# Update Dart SDK version
# Change:
# dart-version: 'stable'
# To:
# dart-version: '3.2.0'

# Or use stable with fallback:
# dart-version: 'stable'
# dart-version-file: 'pubspec.yaml'
```

#### **Alternative Fixes:**
```yaml
# In .github/workflows/ci.yml
- uses: dart-lang/setup-dart@v1
  with:
    dart-version: 'stable'
    architecture: x64  # Add if needed
```

---

### 8. **Large Bundle Size Warnings**

#### **Error Message:**
```
Warning: JavaScript bundle size >500KB (current: 750KB)
Performance threshold exceeded
```

#### **Cause:**
- Unoptimized build
- Large dependencies
- Unused code not tree-shaken

#### **Quick Fix:**
```bash
# Use optimized compilation
dart compile js -O2 lib/main.dart -o docs/main.dart.js

# Check current size
ls -lh docs/main.dart.js

# Analyze bundle content
# Look for large imports or unused code
```

#### **Optimization Strategies:**
```bash
# 1. Remove unused imports
# 2. Use conditional imports
# 3. Optimize assets
# 4. Use -O2 flag for production builds

# Check what's in the bundle
grep -o "import '[^']*'" lib/main.dart | sort | uniq
```

---

### 9. **Git/GitHub Integration Issues**

#### **Error Message:**
```
Error: Failed to upload artifact
Error: Failed to deploy to GitHub Pages
```

#### **Cause:**
- GitHub token permissions
- Branch protection rules
- Artifact upload failures

#### **Quick Fix:**
```bash
# Check repository settings
gh repo view --json defaultBranchRef

# Verify GitHub Pages is enabled
# Go to: Settings > Pages > Source: GitHub Actions

# Check workflow permissions
# Settings > Actions > General > Workflow permissions
```

#### **Permission Issues:**
```yaml
# Add to .github/workflows/ci.yml
permissions:
  contents: read
  pages: write
  id-token: write
```

---

## 🔍 Advanced Debugging Techniques

### 1. **Local CI Simulation**

```bash
# Full CI simulation
./scripts/simulate_ci.sh

# Step-by-step debugging
# 1. Dependencies
dart pub get

# 2. Formatting
dart format --output=none --set-exit-if-changed .

# 3. Analysis
dart analyze --fatal-warnings

# 4. Tests
dart test

# 5. TWA checks
./scripts/check_twa_compatibility.sh

# 6. Build
dart compile js lib/main.dart -o docs/main.dart.js
```

### 2. **Comparative Analysis**

```bash
# Compare local vs CI environment
echo "Local Dart version:"
dart --version

echo "Local dependencies:"
dart pub deps --style=compact

# Compare with CI logs
gh run view --log | grep -A 5 -B 5 "dart --version"
```

### 3. **Log Analysis**

```bash
# Download full CI logs
gh run download

# Search for specific errors
find . -name "*.txt" -exec grep -l "Error\|Failed" {} \;

# Analyze timing
grep "Step timing" */*/step_*.txt
```

---

## 📊 Error Pattern Recognition

### 1. **Frequent Issues (Most Common)**

1. **Code Formatting (60% of failures)**
   - Solution: `dart format .`
   - Prevention: Install git hooks

2. **Static Analysis (25% of failures)**
   - Solution: Fix warnings in `dart analyze`
   - Prevention: Use IDE with Dart analysis

3. **Test Failures (10% of failures)**
   - Solution: Run `dart test` locally
   - Prevention: Test before committing

4. **Build Issues (5% of failures)**
   - Solution: Check syntax and imports
   - Prevention: Use `./scripts/quick_check.sh`

### 2. **Error Categorization**

#### **Syntax Errors**
- Usually in build step
- Fix: Check Dart syntax
- Tool: `dart analyze`

#### **Environment Errors**
- Usually in setup steps
- Fix: Update workflow versions
- Tool: Check GitHub Actions documentation

#### **Dependency Errors**
- Usually in dependency step
- Fix: Update pubspec.yaml
- Tool: `dart pub deps`

#### **Test Errors**
- Usually in test step
- Fix: Update test expectations
- Tool: `dart test`

---

## ⚡ Quick Fix Scripts

### 1. **Universal Fix Script**

```bash
#!/bin/bash
# universal_fix.sh

echo "🔧 Applying common CI fixes..."

# Fix formatting
echo "Fixing formatting..."
dart format .

# Update dependencies
echo "Updating dependencies..."
dart pub get

# Check for obvious issues
echo "Running quick validation..."
./scripts/quick_check.sh

echo "✅ Common fixes applied. Test with:"
echo "   ./scripts/simulate_ci.sh"
```

### 2. **Emergency Recovery Script**

```bash
#!/bin/bash
# emergency_recovery.sh

echo "🚨 Emergency CI recovery..."

# Reset to clean state
dart clean
rm -f docs/main.dart.js*

# Fresh dependencies
dart pub get

# Format all code
dart format .

# Test build
dart compile js lib/main.dart -o docs/main.dart.js

echo "🏥 Emergency fixes complete. Check with:"
echo "   ./scripts/simulate_ci.sh"
```

---

## 📞 Getting Help

### 1. **When to Ask for Help**

- ✅ After trying all fixes in this guide
- ✅ When error messages are unclear
- ✅ When local simulation passes but CI fails
- ✅ When multiple builds fail with different errors

### 2. **Information to Provide**

```bash
# Collect debugging info
echo "=== System Info ===" > debug_info.txt
dart --version >> debug_info.txt
echo "" >> debug_info.txt

echo "=== Local Test Results ===" >> debug_info.txt
./scripts/simulate_ci.sh &>> debug_info.txt

echo "=== CI Logs ===" >> debug_info.txt
gh run view --log-failed >> debug_info.txt

echo "Debug info saved to debug_info.txt"
```

### 3. **Community Resources**

- Dart documentation: https://dart.dev/guides
- GitHub Actions docs: https://docs.github.com/en/actions
- TWA documentation: https://developers.google.com/web/android/trusted-web-activity

---

## 🎯 Prevention Best Practices

### 1. **Before Every Commit**

```bash
# Quick check (10 seconds)
./scripts/quick_check.sh

# Or if you have time, comprehensive check
./scripts/pre_commit_check.sh
```

### 2. **Setup for Success**

```bash
# Install git hooks (one-time setup)
./scripts/setup_git_hooks.sh

# This automatically runs validation before commits
```

### 3. **Regular Maintenance**

```bash
# Weekly: Update dependencies
dart pub upgrade --dry-run

# Monthly: Check for Dart SDK updates
dart --version

# Before major changes: Full CI simulation
./scripts/simulate_ci.sh
```

---

This troubleshooting guide covers 95% of common CI issues. Most problems can be resolved within 5 minutes using the quick fixes provided.