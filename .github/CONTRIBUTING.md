# Contributing to iProcrastinate

## Development Workflow

### 🚀 Quick Start
```bash
# Clone and setup
git clone https://github.com/clickstefan/iprocrastinate.git
cd iprocrastinate
dart pub get

# Local development
dart compile js lib/main.dart -o docs/main.dart.js
cd docs && python -m http.server 8080
```

### 🧪 Before Committing
Always run these checks locally:

```bash
# Format code
dart format .

# Analyze code
dart analyze

# Run tests
dart test

# Check TWA compatibility
./scripts/check_twa_compatibility.sh
```

### 📋 Pull Request Checklist
- [ ] Code is formatted (`dart format`)
- [ ] No analysis issues (`dart analyze`)
- [ ] All tests pass (`dart test`)
- [ ] TWA compatibility verified
- [ ] Changes maintain mobile responsiveness
- [ ] Bundle size impact considered

### 🔧 Folder Structure Conventions

The project supports multiple output folder conventions:

```
├── lib/           # Dart source code
├── docs/          # GitHub Pages output (current)
├── web/           # Alternative: web convention
├── build/         # Alternative: build output
├── dist/          # Alternative: distribution
├── test/          # Test files
├── scripts/       # Build and utility scripts
└── .github/       # GitHub Actions workflows
```

### 📊 Performance Guidelines

**Bundle Size Targets:**
- JavaScript: < 500KB (current: ~91KB ✅)
- CSS: < 100KB (current: ~3KB ✅)
- Total app: < 1MB

**TWA Compatibility:**
- All changes must pass TWA compatibility tests
- No external CDN dependencies
- Relative URLs only
- Valid PWA manifest
- Mobile-first responsive design

### 🏗️ Build Process

The GitHub Actions workflow automatically:

1. **Tests** your changes
2. **Builds** optimized production assets
3. **Validates** TWA compatibility
4. **Deploys** to GitHub Pages (on main branch)

### 🐛 Issue Reporting

When reporting issues:
- Include browser/device information
- Mention if testing locally vs. deployed version
- Include console errors if any
- Test TWA compatibility if relevant

### 🎯 Development Focus

This project prioritizes:
- TWA/Play Store compatibility
- Mobile-first design
- Performance optimization
- Progressive Web App features
- Self-contained dependencies