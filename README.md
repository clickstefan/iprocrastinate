# iProcrastinate

[![CI/CD Pipeline](https://github.com/clickstefan/iprocrastinate/actions/workflows/ci.yml/badge.svg)](https://github.com/clickstefan/iprocrastinate/actions/workflows/ci.yml)
[![TWA Compatible](https://img.shields.io/badge/TWA-Compatible-brightgreen)](https://developers.google.com/web/android/trusted-web-activity)
[![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-Live-blue)](https://clickstefan.github.io/iprocrastinate)

A modern web app to help overcome procrastination and boost productivity.

## 🚀 Live Demo

**Live App**: https://clickstefan.github.io/iprocrastinate

**Local Development**: http://localhost:8080 (when running locally)

## 🛠️ Getting Started

### Prerequisites
- Dart SDK (3.0+)

### Development
1. Clone the repository
2. Install dependencies: `dart pub get`
3. Compile to JavaScript: `dart compile js lib/main.dart -o docs/main.dart.js`
4. Start local server: `cd docs && python -m http.server 8080`
5. Open http://localhost:8080 in your browser

## ✨ Features

- **Task Management**: Add, select, and complete tasks
- **Progress Tracking**: See completed task counter
- **Modern UI**: Material Design-inspired responsive interface
- **Mobile Optimized**: Works perfectly on phones and tablets
- **Progressive Web App**: Can be installed on devices
- **Local Storage**: Tasks persist between sessions
- **Real-time Updates**: Instant UI updates

## 🏗️ Architecture

- **Frontend**: Pure Dart compiled to JavaScript
- **Styling**: Modern CSS with gradients and animations
- **Storage**: Browser localStorage for persistence
- **Responsive**: Mobile-first design

## 🧪 Development Workflow & CI/CD

### 📚 **Complete Workflow Documentation**

We provide comprehensive guides for efficient development with minimal CI failures:

- **[📋 DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md)** - Complete development workflow from code to deployment
- **[🔧 GITHUB_CLI_GUIDE.md](./GITHUB_CLI_GUIDE.md)** - GitHub CLI integration for build monitoring
- **[🚨 TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Solutions for common CI/CD issues
- **[🗺️ WORKFLOW_FLOWCHART.md](./WORKFLOW_FLOWCHART.md)** - Visual decision tree for workflow optimization

### ⚡ **Quick Start Workflow**

#### **🚀 Essential Commands (catch 90% of CI issues)**
```bash
./scripts/quick_check.sh           # ⚡ 10-second essential checks
./scripts/pre_commit_check.sh      # 🔍 Comprehensive validation (30s)
./scripts/simulate_ci.sh           # 🤖 Complete CI simulation (60s)
./scripts/setup_git_hooks.sh       # 🔧 Install automatic validation
```

#### **📊 GitHub CLI Build Monitoring**
```bash
gh run list --limit 5              # Check recent build status
gh run watch                       # Monitor latest build live
gh run view --log-failed           # Get failure logs quickly
./scripts/watch_ci.sh              # Enhanced real-time monitoring
```

#### **🔄 Recommended Development Flow**

**1. Setup (once):**
```bash
./scripts/setup_git_hooks.sh       # Auto-validation on commit/push
```

**2. During development:**
```bash
# After changes (fast feedback)
./scripts/quick_check.sh           # 10 seconds

# Before committing (thorough check)
./scripts/pre_commit_check.sh      # 30 seconds
```

**3. Before pushing:**
```bash
./scripts/simulate_ci.sh           # 60 seconds, prevents CI failures
```

**4. After pushing:**
```bash
gh run watch                       # Monitor CI in real-time
# or
./scripts/watch_ci.sh              # Enhanced monitoring with auto-logs
```

### 🎯 **Quick Problem Solving**

| Problem | Quick Fix | Documentation |
|---------|-----------|---------------|
| ❌ **CI Failed** | `gh run view --log-failed` | [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) |
| 🎨 **Formatting** | `dart format .` | [Common Issues](./TROUBLESHOOTING.md#code-formatting-issues) |
| 🔍 **Analysis** | `dart analyze` | [Static Analysis](./TROUBLESHOOTING.md#static-analysis-warnings) |
| 🧪 **Tests** | `dart test` | [Test Failures](./TROUBLESHOOTING.md#test-failures) |
| 🏗️ **Build** | Check syntax in `lib/main.dart` | [Build Issues](./TROUBLESHOOTING.md#build-compilation-errors) |
| 📱 **TWA** | `./scripts/check_twa_compatibility.sh` | [TWA Guide](./TROUBLESHOOTING.md#twa-compatibility-failures) |

### 📋 **Individual Validation Commands**
```bash
# Code quality
dart format .                      # Fix formatting
dart analyze                       # Static analysis
dart test                          # Run all tests

# TWA compatibility
dart test test/twa_compatibility_test.dart
./scripts/check_twa_compatibility.sh

# Build validation
dart compile js lib/main.dart -o docs/main.dart.js
```

### GitHub Actions Workflow
Automated CI/CD pipeline runs on every push and PR:

#### **Pipeline Stages:**

1. **🧪 Test & Lint**
   - Code formatting validation
   - Static analysis with `dart analyze`
   - Unit tests with coverage
   - TWA compatibility verification

2. **🏗️ Build**
   - Optimized JavaScript compilation (`-O2`)
   - Static asset copying
   - Build validation (file sizes, required files)
   - Post-build TWA compatibility check

3. **🚀 Deploy** (on `master`/`main` branch)
   - Automatic GitHub Pages deployment
   - Build artifact upload
   - Performance validation

4. **🔍 Quality & Security**
   - Dependency security audit
   - Performance analysis (bundle size)
   - Lighthouse CI checks (optional)

#### **Configuration Options:**

Edit `.github/workflows/config.yml` to customize:

```yaml
# Output directory (common conventions supported)
output_directory: docs  # or: web, build, dist

# Performance thresholds
max_js_size: 500000    # 500KB
max_css_size: 100000   # 100KB

# Feature toggles
twa_checks_enabled: true
deploy_to_github_pages: true
performance_checks_enabled: true
```

#### **Workflow Features:**

- ✅ **Multi-folder support**: `docs/`, `web/`, `build/`, `dist/`
- ✅ **Caching**: Dart dependencies cached for faster builds
- ✅ **Artifacts**: Build outputs saved for 30 days
- ✅ **Security**: Dependency vulnerability scanning
- ✅ **Performance**: Bundle size monitoring
- ✅ **TWA validation**: Ensures Play Store compatibility

### Testing Coverage
**What we validate:**
- ✅ Manifest.json validation (PWA requirements)
- ✅ HTML structure (viewport, theme-color, responsive)
- ✅ No external dependencies (CDN-free)
- ✅ File sizes optimized for mobile
- ✅ TWA-specific requirements (relative URLs, display mode)
- ✅ Performance benchmarks
- ✅ Security vulnerabilities

## 📚 Complete Documentation Suite

This project includes comprehensive documentation for efficient development:

### 🔧 **Core Workflow Guides**
- **[📋 DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md)** - Complete development workflow from setup to deployment
  - Step-by-step development phases
  - Local testing integration
  - CI monitoring workflows
  - Best practices and optimization tips

- **[🔧 GITHUB_CLI_GUIDE.md](./GITHUB_CLI_GUIDE.md)** - Master GitHub CLI for build monitoring
  - Real-time build monitoring commands
  - Failure analysis and log retrieval
  - Advanced CLI queries and automation
  - Mobile/Termux optimization tips

### 🚨 **Problem Resolution**
- **[🚨 TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Solutions for 95% of common CI issues
  - Quick fixes for formatting, analysis, tests, and build errors
  - Emergency recovery procedures
  - Pattern recognition for recurring issues
  - Advanced debugging techniques

- **[🗺️ WORKFLOW_FLOWCHART.md](./WORKFLOW_FLOWCHART.md)** - Visual decision trees
  - Quick command selection flowchart
  - Situation-specific workflows
  - Error recovery flowcharts
  - Efficiency optimization matrix

### 🛠️ **Local Development Tools**
We provide 4 powerful scripts for local validation:

| Script | Speed | Purpose | When to Use |
|--------|-------|---------|-------------|
| `quick_check.sh` | 10s | Essential checks | During development |
| `pre_commit_check.sh` | 30s | Comprehensive validation | Before commits |
| `simulate_ci.sh` | 60s | Complete CI simulation | Before pushes |
| `setup_git_hooks.sh` | Once | Automatic validation | Initial setup |

### 📱 **TWA/Play Store Ready**
- Complete TWA compatibility testing
- Optimized for Google Play Store deployment
- Progressive Web App standards compliance
- Mobile-first responsive design

### 💡 **Getting Started with Documentation**

**New developers should read in this order:**
1. **README.md** (this file) - Project overview and quick start
2. **[DEVELOPMENT_WORKFLOW.md](./DEVELOPMENT_WORKFLOW.md)** - Complete workflow guide
3. **[WORKFLOW_FLOWCHART.md](./WORKFLOW_FLOWCHART.md)** - Visual workflow decision tree

**When encountering issues:**
1. **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Quick fixes for common problems
2. **[GITHUB_CLI_GUIDE.md](./GITHUB_CLI_GUIDE.md)** - Advanced CI monitoring and debugging

**For CI/CD optimization:**
- Use the local testing scripts extensively
- Install git hooks for automatic validation
- Follow the workflow recommendations in the guides

## 🧰 Tech Stack

- Dart 3.x
- HTML5 / CSS3
- Progressive Web App
- Local Storage API

## 📱 Publishing to Google Play Store (TWA)

### Requirements
- Google Play Developer account ($25 one-time fee)
- Web app deployed with HTTPS (GitHub Pages works)
- Android development tools

### Steps
1. **Deploy web app first:**
   ```bash
   # Build for production
   dart compile js -O2 lib/main.dart -o docs/main.dart.js
   # Deploy to GitHub Pages or any HTTPS hosting
   ```

2. **Create TWA (Trusted Web Activities) wrapper:**
   - Use Android Studio TWA template
   - Configure to load your web app URL
   - Add Digital Asset Links verification file

3. **Build and publish:**
   ```bash
   # Generate signed app bundle
   ./gradlew bundleRelease
   # Upload to Google Play Console
   ```

4. **TWA Benefits:**
   - Wraps web app in native Android container
   - Full Play Store distribution
   - Native Android notifications support
   - Minimal additional code required