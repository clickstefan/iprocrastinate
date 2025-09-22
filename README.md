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

## 🧪 Testing & CI/CD

### Local Testing
```bash
# Run TWA compatibility tests
dart test test/twa_compatibility_test.dart

# Run complete compatibility check
./scripts/check_twa_compatibility.sh

# Format and analyze code
dart format .
dart analyze
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