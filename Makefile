# iProcrastinate - Development Makefile

.PHONY: help clean format analyze build test check all

# Default target
help:
	@echo "iProcrastinate Development Commands:"
	@echo ""
	@echo "  make clean     - Clean build artifacts"
	@echo "  make format    - Format Dart code"
	@echo "  make analyze   - Run static analysis"
	@echo "  make build     - Build JavaScript and docs"
	@echo "  make test      - Run all tests"
	@echo "  make check     - Run full pre-commit check (format + analyze + build + test)"
	@echo "  make all       - Clean + format + analyze + build + test"
	@echo ""

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf docs/main.dart.js*
	@echo "✅ Clean complete"

# Format code
format:
	@echo "🎨 Formatting Dart code..."
	dart format .
	@echo "✅ Formatting complete"

# Static analysis
analyze:
	@echo "🔍 Running static analysis..."
	dart analyze
	@echo "✅ Analysis complete"

# Build JavaScript
build:
	@echo "🏗️  Compiling Dart to JavaScript..."
	dart compile js lib/main.dart -o docs/main.dart.js
	@echo "📦 Build size: $$(wc -c < docs/main.dart.js | numfmt --to=iec-i --suffix=B)"
	@echo "✅ Build complete"

# Run tests
test: build
	@echo "🧪 Running tests..."
	dart test
	@echo "✅ Tests complete"

# Full pre-commit check
check: format analyze build test
	@echo "✅ All checks passed!"

# Complete workflow
all: clean format analyze build test
	@echo "🎉 Complete build and test cycle finished!"