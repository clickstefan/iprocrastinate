# iProcrastinate - Development Makefile

.PHONY: help clean format format-fix analyze build test check all dev-server stop-dev-server

# Default target
help:
	@echo "iProcrastinate Development Commands:"
	@echo ""
	@echo "  make clean      - Clean build artifacts"
	@echo "  make format     - Check code formatting (CI-compatible)"
	@echo "  make format-fix - Fix code formatting (development)"
	@echo "  make analyze    - Run static analysis (CI-compatible)"
	@echo "  make build      - Build JavaScript"
	@echo "  make test       - Run all tests (builds first)"
	@echo "  make check      - Run full pre-commit check (format + analyze + build + test)"
	@echo "  make all        - Clean + format-fix + analyze + build + test"
	@echo "  make dev-server      - Start development server with hot reload (background)"
	@echo "  make stop-dev-server - Stop the development server"
	@echo ""

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf docs/main.dart.js*
	@echo "✅ Clean complete"

# Format code (CI-compatible - validation only)
format:
	@echo "🎨 Checking code formatting..."
	dart format --output=none --set-exit-if-changed .
	@echo "✅ Code format validated"

# Fix code formatting (development)
format-fix:
	@echo "🎨 Fixing code formatting..."
	dart format .
	@echo "✅ Code formatting fixed"

# Static analysis (CI-compatible)
analyze:
	@echo "🔍 Running static analysis..."
	dart analyze --fatal-warnings
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
all: clean format-fix analyze build test
	@echo "🎉 Complete build and test cycle finished!"

# Development server with auto-rebuild
dev-server:
	@echo "🚀 Starting development server in background..."
	@echo "📍 Server will be available at http://localhost:8080"
	@echo "🔄 Auto-rebuild on Dart changes"
	@echo "🛑 Use 'make stop-dev-server' to stop the server"
	@echo ""
	@if nc -z localhost 8080 2>/dev/null; then \
		echo "⚠️  Development server already running"; \
		echo "   Use 'make stop-dev-server' to stop it first"; \
	else \
		make build; \
		cd docs && nohup python -m http.server 8080 > ../.dev-server.log 2>&1 & \
		echo "✅ Development server started in background"; \
		echo "📋 View logs: tail -f .dev-server.log"; \
		echo "💡 Run 'make build' after Dart changes"; \
	fi

# Stop development server
stop-dev-server:
	@echo "🛑 Stopping development server..."
	@if nc -z localhost 8080 2>/dev/null; then \
		pkill -f "python.*http.server.*8080"; \
		echo "✅ Development server stopped"; \
	else \
		echo "ℹ️  No development server running"; \
	fi