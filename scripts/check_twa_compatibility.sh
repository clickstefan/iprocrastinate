#!/bin/bash

# TWA Compatibility Check Script
# Validates that the web app meets all TWA requirements

echo "🔍 Checking TWA Compatibility..."
echo "=================================="

# Check if required files exist
echo "📁 Checking file structure..."

required_files=("docs/index.html" "docs/manifest.json" "docs/main.dart.js" "docs/styles.css")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing - Required for TWA"
        exit 1
    fi
done

# Check manifest.json structure
echo ""
echo "📱 Validating manifest.json..."

if command -v jq &> /dev/null; then
    # Check required manifest fields
    required_fields=("name" "short_name" "start_url" "display" "theme_color" "background_color" "icons")
    for field in "${required_fields[@]}"; do
        if jq -e ".$field" docs/manifest.json > /dev/null; then
            echo "✅ manifest.$field present"
        else
            echo "❌ manifest.$field missing - Required for TWA"
            exit 1
        fi
    done

    # Check display mode
    display_mode=$(jq -r '.display' docs/manifest.json)
    if [[ "$display_mode" == "standalone" || "$display_mode" == "fullscreen" || "$display_mode" == "minimal-ui" ]]; then
        echo "✅ display mode '$display_mode' is TWA-compatible"
    else
        echo "⚠️  display mode '$display_mode' may not be optimal for TWA"
    fi

    # Check for 192x192 icon
    if jq -e '.icons[] | select(.sizes | contains("192x192"))' docs/manifest.json > /dev/null; then
        echo "✅ 192x192 icon present"
    else
        echo "❌ 192x192 icon missing - Required for TWA"
        exit 1
    fi
else
    echo "⚠️  jq not available - skipping detailed manifest validation"
fi

# Check HTML structure
echo ""
echo "🌐 Validating HTML structure..."

if grep -q 'name="viewport"' docs/index.html; then
    echo "✅ viewport meta tag present"
else
    echo "❌ viewport meta tag missing - Required for TWA mobile compatibility"
    exit 1
fi

if grep -q 'rel="manifest"' docs/index.html; then
    echo "✅ manifest link present"
else
    echo "❌ manifest link missing - Required for TWA"
    exit 1
fi

if grep -q 'name="theme-color"' docs/index.html; then
    echo "✅ theme-color meta tag present"
else
    echo "⚠️  theme-color meta tag recommended for TWA"
fi

# Check for external dependencies
echo ""
echo "🔗 Checking for external dependencies..."

external_patterns=("cdn\\.jsdelivr\\.net" "unpkg\\.com" "cdnjs\\.cloudflare\\.com" "googleapis\\.com")
external_found=false

for pattern in "${external_patterns[@]}"; do
    if grep -q "$pattern" docs/index.html; then
        echo "⚠️  External CDN detected: $pattern - Consider using local files for TWA"
        external_found=true
    fi
done

if [ "$external_found" = false ]; then
    echo "✅ No external CDN dependencies found"
fi

# Check file sizes
echo ""
echo "📊 Checking file sizes..."

js_size=$(wc -c < docs/main.dart.js)
css_size=$(wc -c < docs/styles.css)

js_size_kb=$((js_size / 1024))
css_size_kb=$((css_size / 1024))

echo "📄 JavaScript: ${js_size_kb}KB"
echo "🎨 CSS: ${css_size_kb}KB"

if [ $js_size -lt 500000 ]; then
    echo "✅ JavaScript size optimal for TWA"
else
    echo "⚠️  JavaScript size (${js_size_kb}KB) is large - consider optimization"
fi

if [ $css_size -lt 100000 ]; then
    echo "✅ CSS size optimal for TWA"
else
    echo "⚠️  CSS size (${css_size_kb}KB) is large - consider optimization"
fi

# Run Dart tests if available
echo ""
echo "🧪 Running TWA compatibility tests..."

if [ -f "test/twa_compatibility_test.dart" ]; then
    dart test test/twa_compatibility_test.dart
    test_result=$?
    if [ $test_result -eq 0 ]; then
        echo "✅ All TWA compatibility tests passed"
    else
        echo "❌ Some TWA compatibility tests failed"
        exit 1
    fi
else
    echo "⚠️  TWA compatibility tests not found"
fi

echo ""
echo "🎉 TWA Compatibility Check Complete!"
echo "✅ Your app appears to be TWA-ready"
echo ""
echo "Next steps for TWA deployment:"
echo "1. Deploy to HTTPS domain (✅ GitHub Pages)"
echo "2. Create Android Studio TWA project"
echo "3. Configure Digital Asset Links"
echo "4. Build and publish to Play Store"