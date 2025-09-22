# iProcrastinate

A modern web app to help overcome procrastination and boost productivity.

## 🚀 Live Demo

Visit the web app at: **http://localhost:8080** (when running locally)

## 🛠️ Getting Started

### Prerequisites
- Dart SDK (3.0+)

### Development
1. Clone the repository
2. Install dependencies: `dart pub get`
3. Compile to JavaScript: `dart compile js lib/main.dart -o web/main.dart.js`
4. Start local server: `cd web && python -m http.server 8080`
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
   dart compile js -O2 lib/main.dart -o web/main.dart.js
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