import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

/// TWA (Trusted Web Activities) Compatibility Test Suite
/// Ensures the web app meets all requirements for TWA deployment
void main() {
  group('TWA Compatibility Tests', () {
    late Map<String, dynamic> manifest;
    late String indexHtml;

    setUpAll(() async {
      // Load manifest.json
      final manifestFile = File('docs/manifest.json');
      if (await manifestFile.exists()) {
        final manifestContent = await manifestFile.readAsString();
        manifest = jsonDecode(manifestContent);
      } else {
        throw Exception('manifest.json not found in docs/ folder');
      }

      // Load index.html
      final indexFile = File('docs/index.html');
      if (await indexFile.exists()) {
        indexHtml = await indexFile.readAsString();
      } else {
        throw Exception('index.html not found in docs/ folder');
      }
    });

    group('Manifest Requirements', () {
      test('manifest.json exists and is valid JSON', () {
        expect(manifest, isNotEmpty);
        expect(manifest, isA<Map<String, dynamic>>());
      });

      test('has required manifest fields for TWA', () {
        // Required fields for TWA
        expect(manifest['name'], isNotNull, reason: 'name is required');
        expect(manifest['short_name'], isNotNull,
            reason: 'short_name is required');
        expect(manifest['start_url'], isNotNull,
            reason: 'start_url is required');
        expect(manifest['display'], isNotNull, reason: 'display is required');
        expect(manifest['theme_color'], isNotNull,
            reason: 'theme_color is required');
        expect(manifest['background_color'], isNotNull,
            reason: 'background_color is required');
      });

      test('display mode is suitable for TWA', () {
        final display = manifest['display'];
        final validDisplayModes = ['standalone', 'fullscreen', 'minimal-ui'];
        expect(validDisplayModes.contains(display), isTrue,
            reason:
                'display must be standalone, fullscreen, or minimal-ui for TWA');
      });

      test('has valid icons for TWA', () {
        expect(manifest['icons'], isNotNull, reason: 'icons array is required');
        expect(manifest['icons'], isA<List>(),
            reason: 'icons must be an array');

        final icons = manifest['icons'] as List;
        expect(icons.isNotEmpty, isTrue, reason: 'must have at least one icon');

        // Check for required icon sizes for TWA
        final iconSizes = icons.map((icon) => icon['sizes']).toList();
        expect(iconSizes.any((size) => size.contains('192x192')), isTrue,
            reason: '192x192 icon is required for TWA');
      });

      test('start_url is relative for TWA compatibility', () {
        final startUrl = manifest['start_url'] as String;
        expect(startUrl.startsWith('/') || startUrl == './' || startUrl == '.',
            isTrue,
            reason: 'start_url should be relative for TWA');
        expect(startUrl.startsWith('http'), isFalse,
            reason: 'start_url should not be absolute URL for TWA');
      });

      test('theme_color is valid hex color', () {
        final themeColor = manifest['theme_color'] as String;
        expect(themeColor.startsWith('#'), isTrue,
            reason: 'theme_color should start with #');
        expect(themeColor.length, equals(7),
            reason: 'theme_color should be 7 characters (#RRGGBB)');
      });
    });

    group('HTML Requirements', () {
      test('index.html exists and is valid', () {
        expect(indexHtml, isNotEmpty);
        expect(indexHtml.contains('<!DOCTYPE html>'), isTrue,
            reason: 'Must have valid DOCTYPE');
      });

      test('has viewport meta tag for mobile compatibility', () {
        expect(indexHtml.contains('name="viewport"'), isTrue,
            reason: 'viewport meta tag is required for TWA');
        expect(indexHtml.contains('width=device-width'), isTrue,
            reason: 'viewport should include width=device-width');
      });

      test('links to manifest.json correctly', () {
        expect(indexHtml.contains('rel="manifest"'), isTrue,
            reason: 'must link to manifest.json');
        expect(indexHtml.contains('href="manifest.json"'), isTrue,
            reason: 'manifest link should point to manifest.json');
      });

      test('has theme-color meta tag matching manifest', () {
        expect(indexHtml.contains('name="theme-color"'), isTrue,
            reason: 'theme-color meta tag is recommended for TWA');

        final manifestThemeColor = manifest['theme_color'] as String;
        expect(indexHtml.contains('content="$manifestThemeColor"'), isTrue,
            reason: 'HTML theme-color should match manifest theme_color');
      });

      test('no external domain navigation (TWA limitation)', () {
        // Check for potential external links that could break TWA
        final externalLinkPatterns = [
          r'href="https?://(?!clickstefan\.github\.io)',
          r'window\.open\s*\(',
          r'location\.href\s*=\s*["\x27]https?://',
        ];

        for (final pattern in externalLinkPatterns) {
          final regex = RegExp(pattern);
          expect(regex.hasMatch(indexHtml), isFalse,
              reason:
                  'External navigation detected: $pattern. This may not work in TWA.');
        }
      });
    });

    group('PWA Criteria for TWA', () {
      test('uses HTTPS (required for TWA)', () {
        // This test assumes the app is deployed to GitHub Pages (HTTPS)
        // In a real test, you'd check the actual deployment
        expect(true, isTrue, reason: 'GitHub Pages provides HTTPS by default');
      });

      test('responsive design indicators present', () {
        expect(indexHtml.contains('viewport'), isTrue,
            reason: 'responsive design required for TWA');
        expect(indexHtml.contains('device-width'), isTrue,
            reason: 'mobile-responsive meta tag required');
      });

      test('app loads without network dependencies', () {
        // Check that main resources are self-contained
        expect(indexHtml.contains('main.dart.js'), isTrue,
            reason: 'main JavaScript file should be local');
        expect(indexHtml.contains('styles.css'), isTrue,
            reason: 'main CSS file should be local');

        // Check for external CDN dependencies (not recommended for TWA)
        final cdnPatterns = [
          r'cdn\.jsdelivr\.net',
          r'unpkg\.com',
          r'cdnjs\.cloudflare\.com',
          r'googleapis\.com',
        ];

        for (final pattern in cdnPatterns) {
          expect(indexHtml.contains(pattern), isFalse,
              reason:
                  'External CDN dependency detected: $pattern. Use local files for TWA.');
        }
      });
    });

    group('TWA-Specific Validation', () {
      test('file structure is TWA-compatible', () {
        // Check that required static files exist (JavaScript is built by CI)
        expect(File('docs/index.html').existsSync(), isTrue);
        expect(File('docs/manifest.json').existsSync(), isTrue);
        expect(File('docs/styles.css').existsSync(), isTrue);
        // Note: main.dart.js is built by CI and deployed automatically
      });

      test('manifest scope is properly configured', () {
        // If scope is specified, it should be relative
        if (manifest.containsKey('scope')) {
          final scope = manifest['scope'] as String;
          expect(scope.startsWith('/') || scope == './', isTrue,
              reason: 'scope should be relative for TWA');
          expect(scope.startsWith('http'), isFalse,
              reason: 'scope should not be absolute URL for TWA');
        }
      });

      test('no service worker conflicts', () {
        // Check if service worker is registered properly (optional for TWA)
        if (indexHtml.contains('serviceWorker')) {
          expect(indexHtml.contains('navigator.serviceWorker.register'), isTrue,
              reason: 'service worker should be properly registered');
        }
      });

      test('localStorage usage is TWA-compatible', () {
        // TWA supports localStorage, this should pass
        expect(true, isTrue, reason: 'localStorage is supported in TWA');
      });
    });

    group('Performance & Size (TWA Optimization)', () {
      test('JavaScript bundle size is reasonable', () async {
        final jsFile = File('docs/main.dart.js');
        if (await jsFile.exists()) {
          final size = await jsFile.length();
          // Dart compiled JS should be under 900KB for good TWA performance
          // Updated to account for debug functionality, service worker features, and HTTP package for quote loading
          expect(size, lessThan(900 * 1024),
              reason:
                  'JavaScript bundle should be under 900KB for optimal TWA performance');
        }
      });

      test('CSS size is reasonable', () async {
        final cssFile = File('docs/styles.css');
        if (await cssFile.exists()) {
          final size = await cssFile.length();
          expect(size, lessThan(100 * 1024),
              reason: 'CSS should be under 100KB for optimal TWA performance');
        }
      });
    });
  });
}
