# Development Workflow Guide

## 🚀 Complete Development Workflow

This guide covers the complete development workflow from code changes to deployment, including local testing, GitHub CLI integration, and CI/CD monitoring.

## 📁 Critical: Understanding File Structure

### **ALWAYS COMMIT** ✅
```
lib/main.dart              ← Dart source code
test/                      ← Test files
docs/index.html            ← HTML template with notification UI
docs/styles.css            ← CSS styles with notification components
docs/manifest.json         ← PWA manifest for TWA compatibility
docs/sw.js                 ← Service worker for notifications
Makefile                   ← Build commands
.gitignore                 ← Git ignore rules
```

### **NEVER COMMIT** ❌
```
docs/main.dart.js          ← Compiled JavaScript (375KB)
docs/main.dart.js.map      ← Source maps (170KB)
docs/main.dart.js.deps     ← Dependencies (11KB)
```

### **Why This Matters**
- **HTML/CSS/Manifest/SW** are source templates containing the notification system UI
- **JavaScript files** are compiled build artifacts that change with every build
- **CI automatically compiles** Dart to JS, so committing JS creates conflicts
- **Local development** needs `make build` first to generate the JS files
- **File sizes** matter for TWA performance (keep total under 1MB)

## 📋 Quick Reference

### Essential Commands
```bash
# Build process (REQUIRED for local development)
make build                 # Compile Dart to JavaScript
make clean                 # Remove generated files
make test                  # Build + run tests

# Fast validation (10 seconds)
./scripts/quick_check.sh

# Comprehensive pre-commit check
./scripts/pre_commit_check.sh

# Full CI simulation
./scripts/simulate_ci.sh

# Setup automatic validation
./scripts/setup_git_hooks.sh
```

### File Management Commands
```bash
# Check what's staged for commit
git status

# See what changed in source files
git diff lib/ test/ docs/ Makefile .gitignore

# SAFE: Add only source files
git add lib/ test/ docs/index.html docs/styles.css docs/manifest.json docs/sw.js Makefile

# DANGER: Never add these
git add docs/main.dart.js*  # ❌ DON'T DO THIS
```

### GitHub CLI Build Monitoring
```bash
# Check latest build status
gh run list --limit 5

# Monitor current/latest run
gh run view

# Get failed build logs
gh run view --log-failed

# Watch build in real-time
gh run watch
```

---

## 🔄 Development Workflow Steps

### 1. **Setup Phase** (One-time)

#### Install Git Hooks (Recommended)
```bash
./scripts/setup_git_hooks.sh
```
**What this does:**
- Installs pre-commit validation hooks
- Adds commit message format checking
- Sets up pre-push CI simulation
- Prevents most CI failures automatically

#### Verify Environment
```bash
dart --version  # Should be 3.0+ (3.2+ for web features)
gh --version    # For CI monitoring
```

### 2. **Development Phase** (Daily workflow)

#### Make Code Changes
```bash
# Edit your source code
code lib/main.dart          # Dart logic
code docs/index.html        # HTML template
code docs/styles.css        # CSS styles
code docs/manifest.json     # PWA manifest
code docs/sw.js            # Service worker
code test/               # Tests
```

#### Build for Local Testing
```bash
# REQUIRED: Build before testing locally
make build                  # Compiles lib/main.dart → docs/main.dart.js

# Alternative: Individual commands
dart compile js lib/main.dart -o docs/main.dart.js
```

**⚠️ Important**: Local development requires building first because:
- The HTML template loads `main.dart.js`
- This file is generated from `lib/main.dart`
- Without building, the app won't work locally

#### Quick Validation (10 seconds)
```bash
./scripts/quick_check.sh
```
**Use when:** Making small changes, want fast feedback

**Catches:**
- ✅ Dependency issues
- ✅ Code formatting problems
- ✅ Basic syntax errors
- ✅ Compilation failures

#### Fix Common Issues
```bash
# Fix formatting (most common issue)
dart format .

# Update dependencies
dart pub get

# Check analysis issues
dart analyze
```

### 3. **Pre-Commit Phase**

#### Comprehensive Validation
```bash
./scripts/pre_commit_check.sh
```
**Use when:** Ready to commit, want thorough validation

**Validates:**
- ✅ Environment compatibility
- ✅ Dependencies resolution
- ✅ Code formatting (CI-exact)
- ✅ Static analysis (CI-exact)
- ✅ Unit tests
- ✅ TWA compatibility
- ✅ Build compilation
- ✅ Bundle size optimization

#### Commit Changes
```bash
# Check what's changed
git status

# SAFE: Add only source files (recommended)
git add lib/ test/ docs/index.html docs/styles.css docs/manifest.json docs/sw.js Makefile

# ALTERNATIVE: Add all non-ignored files (be careful!)
git add .

# Commit with descriptive message
git commit -m "feat: your change description"
```

**⚠️ Critical File Rules:**
- ✅ **ALWAYS commit**: `lib/`, `test/`, `docs/*.html`, `docs/*.css`, `docs/*.json`, `docs/sw.js`
- ❌ **NEVER commit**: `docs/main.dart.js*` (these are auto-generated)
- 🔍 **Check .gitignore**: Compiled files should be automatically ignored

**Note:** If you installed git hooks, validation runs automatically

### 4. **Pre-Push Phase**

#### Full CI Simulation
```bash
./scripts/simulate_ci.sh
```
**Use when:** About to push, want to ensure CI success

**Simulates:**
- 🧪 Complete Test & Lint job
- 🏗️ Complete Build job
- 🔍 Quality & Security checks
- 🚀 Deployment validation

#### Push to Repository
```bash
git push origin main
```
**Note:** If you installed git hooks, CI simulation runs automatically

### 5. **CI Monitoring Phase**

#### Monitor Build Status
```bash
# Quick status check
gh run list --limit 3

# Watch current build live
gh run watch

# Detailed view of latest run
gh run view
```

#### Handle Build Failures
```bash
# Get failure details
gh run view --log-failed

# Download full logs for analysis
gh run download
```

#### Emergency Fixes
```bash
# If CI fails after push:
# 1. Check logs
gh run view --log-failed

# 2. Fix locally and test
./scripts/simulate_ci.sh

# 3. Commit and push fix
git add .
git commit -m "fix: resolve CI failure"
git push
```

---

## 🛠️ GitHub CLI Integration

### Build Status Commands

#### Check Build Status
```bash
# List recent builds with status
gh run list --limit 5
# Output: ✅ success, ❌ failure, 🟡 in_progress

# Check specific build
gh run view [run-id]

# Monitor latest build
gh run view --log
```

#### Real-time Monitoring
```bash
# Watch build progress live
gh run watch

# Watch specific workflow
gh run watch --workflow=ci.yml
```

#### Failure Analysis
```bash
# Get only failed logs
gh run view --log-failed

# Download all logs for offline analysis
gh run download [run-id]

# View specific job logs
gh run view [run-id] --job=[job-name]
```

### Automated Monitoring Script

We have a `scripts/watch_ci.sh` script that automates build monitoring:

```bash
# Monitor latest commit's build
./scripts/watch_ci.sh

# Monitor specific commit
./scripts/watch_ci.sh abc1234
```

**Features:**
- Real-time status updates
- Automatic failure log extraction
- Build duration tracking
- Desktop notifications (if available)

---

## 🔧 Troubleshooting Guide

### Common CI Failures

#### 1. **Code Formatting Issues**
```
❌ Error: dart format --set-exit-if-changed . failed
```
**Fix:**
```bash
dart format .
git add .
git commit -m "style: fix code formatting"
```

#### 2. **Static Analysis Warnings**
```
❌ Error: dart analyze --fatal-warnings failed
```
**Fix:**
```bash
dart analyze  # See specific issues
# Fix the reported issues
git add .
git commit -m "fix: resolve analysis warnings"
```

#### 3. **Test Failures**
```
❌ Error: dart test failed
```
**Fix:**
```bash
dart test  # See failing tests
# Fix test issues
git add .
git commit -m "test: fix failing tests"
```

#### 4. **Build Compilation Errors**
```
❌ Error: dart compile js failed
```
**Fix:**
```bash
dart compile js lib/main.dart -o test.js  # See errors
# Fix compilation issues
rm test.js
git add .
git commit -m "fix: resolve compilation errors"
```

#### 5. **TWA Compatibility Issues**
```
❌ Error: TWA compatibility tests failed
```
**Fix:**
```bash
./scripts/check_twa_compatibility.sh  # See specific issues
# Fix manifest.json, HTML meta tags, etc.
git add .
git commit -m "fix: improve TWA compatibility"
```

#### 6. **Dependency Issues**
```
❌ Error: dart pub get failed
```
**Fix:**
```bash
dart pub get  # See dependency conflicts
# Update pubspec.yaml
dart pub get
git add .
git commit -m "deps: resolve dependency conflicts"
```

#### 7. **Large Bundle Size Warning**
```
⚠️ Warning: JavaScript bundle size >500KB
```
**Fix:**
```bash
# Analyze bundle size
ls -lh docs/main.dart.js

# Optimize imports
# Remove unused dependencies
# Use dart compile js -O2 for smaller builds
```

### Local Testing vs CI Differences

| Issue | Local Test | CI Behavior | Solution |
|-------|------------|-------------|----------|
| Different Dart versions | Works locally | CI fails | Use exact CI Dart version locally |
| File permissions | Works on Termux | Fails on Ubuntu | Test with `--check` flags |
| Environment variables | Local env | CI env | Use `scripts/simulate_ci.sh` |
| Dependency caching | Local cache | Fresh install | Test with `dart pub get --offline` |

---

## 📊 Workflow Decision Tree

```
Making code changes?
├─ Small change (5 min) → ./scripts/quick_check.sh
├─ Medium change (15 min) → ./scripts/pre_commit_check.sh
└─ Major change/refactor → ./scripts/simulate_ci.sh

Ready to commit?
├─ Git hooks installed → git commit (auto-validates)
└─ No git hooks → ./scripts/pre_commit_check.sh first

Ready to push?
├─ Git hooks installed → git push (auto-simulates CI)
└─ No git hooks → ./scripts/simulate_ci.sh first

CI failed after push?
├─ Check logs → gh run view --log-failed
├─ Fix locally → ./scripts/simulate_ci.sh
└─ Push fix → git commit -m "fix: resolve CI issue"
```

---

## ⚡ Performance Optimization

### Fast Development Loop
```bash
# Ultra-fast check (2 seconds)
dart analyze lib/main.dart && dart format --output=none lib/main.dart

# Medium check (10 seconds)
./scripts/quick_check.sh

# Full check (30 seconds)
./scripts/pre_commit_check.sh

# Complete CI simulation (60 seconds)
./scripts/simulate_ci.sh
```

### Efficient Git Workflow
```bash
# With hooks installed (recommended):
git add .
git commit -m "feat: new feature"  # Auto-validates
git push                           # Auto-simulates CI

# Manual workflow:
./scripts/quick_check.sh    # Fast feedback
# Fix any issues
./scripts/simulate_ci.sh    # Final check
git add .
git commit -m "feat: new feature"
git push
gh run watch               # Monitor CI
```

---

## 🎯 Best Practices

### Development
- ✅ Run `./scripts/quick_check.sh` frequently during development
- ✅ Install git hooks for automatic validation
- ✅ Use conventional commit messages (feat:, fix:, docs:)
- ✅ Keep bundle size under 500KB for optimal TWA performance

### Testing
- ✅ Test TWA compatibility with `./scripts/check_twa_compatibility.sh`
- ✅ Simulate CI locally before pushing with `./scripts/simulate_ci.sh`
- ✅ Monitor builds with `gh run watch` after pushing

### Debugging
- ✅ Use `gh run view --log-failed` for quick failure analysis
- ✅ Download full logs with `gh run download` for complex issues
- ✅ Test fixes locally with simulation scripts before re-pushing

### Performance
- ✅ Monitor bundle size with each build
- ✅ Use `dart compile js -O2` for production builds
- ✅ Keep TWA-required files under 1MB total

---

## 📱 TWA-Specific Workflow

### Pre-Play Store Checklist
```bash
# 1. Full TWA validation
./scripts/check_twa_compatibility.sh

# 2. Build optimization
dart compile js -O2 lib/main.dart -o docs/main.dart.js

# 3. Test PWA installation
# Open https://clickstefan.github.io/iprocrastinate
# Check "Add to Home Screen" works

# 4. Verify manifest
cat docs/manifest.json  # Check all required fields

# 5. Final CI check
./scripts/simulate_ci.sh
```

### Play Store Upload Preparation
```bash
# Build optimized version
dart compile js -O2 lib/main.dart -o docs/main.dart.js

# Verify HTTPS deployment
curl -I https://clickstefan.github.io/iprocrastinate

# Check all TWA requirements
./scripts/check_twa_compatibility.sh

# Verify in TWA builder tool
# Use Google's TWA Builder with your GitHub Pages URL
```

---

## 🆘 Emergency Procedures

### CI Is Failing and Blocking Development
```bash
# 1. Quick local fix attempt
gh run view --log-failed  # Identify issue
./scripts/simulate_ci.sh   # Test fix locally

# 2. If local simulation passes but CI fails
# Check Dart SDK version differences
dart --version
# Update .github/workflows/ci.yml if needed

# 3. Emergency bypass (use sparingly)
git push --no-verify  # Skip pre-push hooks
# Then fix CI immediately
```

### Corrupted Build State
```bash
# 1. Clean everything
dart pub get
dart clean
make clean                  # Removes docs/main.dart.js*

# 2. Fresh build
make build                  # Recompiles everything

# 3. Full validation
./scripts/simulate_ci.sh
```

### Accidentally Committed Generated Files
```bash
# 1. Remove from git tracking (keeps local files)
git rm --cached docs/main.dart.js docs/main.dart.js.map docs/main.dart.js.deps

# 2. Ensure .gitignore is correct
cat .gitignore | grep "main.dart.js"
# Should show: docs/main.dart.js, docs/main.dart.js.map, docs/main.dart.js.deps

# 3. Commit the removal
git commit -m "fix: remove generated files from git tracking"

# 4. Rebuild locally for testing
make build
```

### Git Status Shows Generated Files
```bash
# Check if .gitignore is working
git check-ignore docs/main.dart.js
# Should output: docs/main.dart.js (meaning it's ignored)

# If not ignored, add to .gitignore:
echo "docs/main.dart.js" >> .gitignore
echo "docs/main.dart.js.map" >> .gitignore
echo "docs/main.dart.js.deps" >> .gitignore
git add .gitignore
git commit -m "fix: ignore generated JavaScript files"
```

### Git Hooks Causing Issues
```bash
# Temporarily disable
rm .git/hooks/pre-commit .git/hooks/pre-push

# Re-enable with updates
./scripts/setup_git_hooks.sh
```

---

This workflow guide ensures efficient development with minimal CI failures and rapid feedback loops. Use the local testing scripts extensively to catch issues before they reach CI.