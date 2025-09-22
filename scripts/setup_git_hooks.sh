#!/bin/bash

# Git Hooks Setup Script
# Installs pre-commit hooks to automatically run validation before commits

set -e

echo "🔧 Git Hooks Setup"
echo "=================="
echo "Setting up automatic pre-commit validation..."
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "   Run this script from the project root directory"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to create pre-commit hook
create_pre_commit_hook() {
    local hook_file=".git/hooks/pre-commit"

    cat > "$hook_file" << 'EOF'
#!/bin/bash

# Automatic Pre-Commit Validation
# Runs validation checks before allowing commit

echo "🔍 Running pre-commit validation..."

# Run the pre-commit check script
if [ -f "scripts/pre_commit_check.sh" ]; then
    if ./scripts/pre_commit_check.sh; then
        echo ""
        echo "✅ Pre-commit validation passed!"
        exit 0
    else
        echo ""
        echo "❌ Pre-commit validation failed!"
        echo ""
        echo "💡 To commit anyway (not recommended):"
        echo "   git commit --no-verify -m \"your message\""
        echo ""
        echo "🔧 To fix issues:"
        echo "   dart format .              # Fix formatting"
        echo "   dart analyze               # Check analysis issues"
        echo "   dart test                  # Run failing tests"
        echo "   ./scripts/pre_commit_check.sh  # Re-run validation"
        exit 1
    fi
else
    echo "⚠️  Pre-commit script not found, allowing commit"
    exit 0
fi
EOF

    chmod +x "$hook_file"
    echo -e "${GREEN}✅ Created pre-commit hook${NC}"
}

# Function to create commit-msg hook for commit message validation
create_commit_msg_hook() {
    local hook_file=".git/hooks/commit-msg"

    cat > "$hook_file" << 'EOF'
#!/bin/bash

# Commit Message Validation
# Ensures commit messages follow good practices

commit_msg_file="$1"
commit_msg=$(cat "$commit_msg_file")

# Skip validation for merge commits
if grep -q "^Merge " "$commit_msg_file"; then
    exit 0
fi

# Check minimum length
if [ ${#commit_msg} -lt 10 ]; then
    echo "❌ Commit message too short (minimum 10 characters)"
    echo "Current: \"$commit_msg\""
    exit 1
fi

# Check maximum length for first line
first_line=$(echo "$commit_msg" | head -1)
if [ ${#first_line} -gt 72 ]; then
    echo "⚠️  First line of commit message is long (${#first_line} chars, recommend <72)"
    echo "Consider breaking it into title + description"
fi

# Suggest conventional commit format if not already used
if ! echo "$first_line" | grep -qE "^(feat|fix|docs|style|refactor|test|chore|build|ci)(\(.+\))?: "; then
    echo "💡 Consider using conventional commit format:"
    echo "   feat: add new feature"
    echo "   fix: resolve bug"
    echo "   docs: update documentation"
    echo "   Current: \"$first_line\""
fi

exit 0
EOF

    chmod +x "$hook_file"
    echo -e "${GREEN}✅ Created commit-msg validation hook${NC}"
}

# Function to create pre-push hook
create_pre_push_hook() {
    local hook_file=".git/hooks/pre-push"

    cat > "$hook_file" << 'EOF'
#!/bin/bash

# Pre-Push Validation
# Final check before pushing to remote

echo "🚀 Running pre-push validation..."

# Check if we have a clean working directory
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  You have uncommitted changes"
    git status --short
    echo ""
    echo "💡 Consider committing all changes before pushing"
fi

# Run a quick CI simulation
if [ -f "scripts/simulate_ci.sh" ]; then
    echo "🤖 Running quick CI simulation..."
    if ./scripts/simulate_ci.sh >/dev/null 2>&1; then
        echo "✅ CI simulation passed - push should succeed"
    else
        echo "❌ CI simulation failed - push might fail"
        echo ""
        echo "🔧 Run for details: ./scripts/simulate_ci.sh"
        echo ""
        echo "💡 To push anyway (not recommended):"
        echo "   git push --no-verify"
        exit 1
    fi
fi

exit 0
EOF

    chmod +x "$hook_file"
    echo -e "${GREEN}✅ Created pre-push validation hook${NC}"
}

# Main setup
echo "📋 Available hooks to install:"
echo "   1. pre-commit: Validates code before each commit"
echo "   2. commit-msg: Validates commit message format"
echo "   3. pre-push: Final validation before pushing"
echo ""

# Check for existing hooks
existing_hooks=()
for hook in pre-commit commit-msg pre-push; do
    if [ -f ".git/hooks/$hook" ]; then
        existing_hooks+=("$hook")
    fi
done

if [ ${#existing_hooks[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Existing hooks found: ${existing_hooks[*]}${NC}"
    echo -n "Replace existing hooks? [y/N]: "
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Cancelled setup"
        exit 0
    fi
fi

# Install hooks
echo "🔧 Installing git hooks..."
echo ""

create_pre_commit_hook
create_commit_msg_hook
create_pre_push_hook

echo ""
echo -e "${GREEN}🎉 Git hooks setup complete!${NC}"
echo ""
echo -e "${BLUE}📋 What happens now:${NC}"
echo "   • Before each commit: Code validation runs automatically"
echo "   • Before each push: CI simulation runs to catch issues"
echo "   • Commit messages: Basic format validation"
echo ""
echo -e "${BLUE}💡 Testing your setup:${NC}"
echo "   ./scripts/pre_commit_check.sh  # Test pre-commit validation"
echo "   ./scripts/simulate_ci.sh       # Test CI simulation"
echo ""
echo -e "${BLUE}🛠️  Bypassing hooks (when needed):${NC}"
echo "   git commit --no-verify         # Skip pre-commit validation"
echo "   git push --no-verify           # Skip pre-push validation"
echo ""
echo -e "${YELLOW}⚠️  Note: Hooks are local only and not committed to git${NC}"
echo "   Other contributors need to run this script too"