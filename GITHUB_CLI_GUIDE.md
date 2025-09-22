# GitHub CLI Integration Guide

## 🔧 GitHub CLI for Build Monitoring

This guide covers using GitHub CLI (`gh`) to monitor builds, analyze failures, and manage your CI/CD pipeline efficiently.

## 📋 Quick Command Reference

### Essential Build Commands
```bash
# Quick status check
gh run list --limit 5

# Monitor latest build
gh run watch

# View detailed build info
gh run view

# Get failure logs only
gh run view --log-failed

# Download all logs
gh run download
```

### Repository Commands
```bash
# View repo info
gh repo view

# Check workflow status
gh workflow list

# View recent releases
gh release list
```

---

## 🔍 Monitoring Build Status

### 1. **Check Recent Builds**

#### List Recent Runs
```bash
# Show last 5 builds with status
gh run list --limit 5

# Example output:
# ✓ CI/CD Pipeline  main  fix: resolve analysis issues     1234567  about 2 minutes ago
# X CI/CD Pipeline  main  feat: add new feature           1234566  about 5 minutes ago
# ✓ CI/CD Pipeline  main  docs: update README             1234565  about 1 hour ago
```

#### Filter by Status
```bash
# Show only failed builds
gh run list --status=failure --limit 10

# Show only successful builds
gh run list --status=success --limit 5

# Show in-progress builds
gh run list --status=in_progress
```

#### Filter by Workflow
```bash
# Show builds for specific workflow
gh run list --workflow=ci.yml --limit 10

# Show builds for specific branch
gh run list --branch=main --limit 10
```

### 2. **Real-time Monitoring**

#### Watch Latest Build
```bash
# Watch the most recent build
gh run watch

# Watch specific build by ID
gh run watch 1234567

# Watch specific workflow
gh run watch --workflow=ci.yml
```

#### Monitor with Our Script
```bash
# Use our enhanced monitoring script
./scripts/watch_ci.sh

# Features:
# - Real-time status updates
# - Automatic failure log extraction
# - Build duration tracking
# - Direct GitHub links
```

### 3. **Detailed Build Information**

#### View Build Details
```bash
# View latest build
gh run view

# View specific build
gh run view 1234567

# View with job details
gh run view --json

# View specific job
gh run view 1234567 --job="Test & Lint"
```

#### Example Detailed Output
```
CI/CD Pipeline · 1234567
Triggered via push about 2 minutes ago

JOBS
✓ Test & Lint (ID 12345678)
✓ Build Web App (ID 12345679)
✓ Quality & Security (ID 12345680)
✓ Deploy (ID 12345681)

For more information about a job, try: gh run view --job=<job-id>
```

---

## ❌ Analyzing Build Failures

### 1. **Quick Failure Analysis**

#### Get Failed Logs Only
```bash
# Show only failed job logs
gh run view --log-failed

# Show failed logs for specific build
gh run view 1234567 --log-failed

# Save failed logs to file
gh run view --log-failed > failure_logs.txt
```

#### Example Failed Log Output
```
Test & Lint: Analyze project source
❌ 2024-01-15T10:30:45.123Z error: The getter 'querySelector' isn't defined for the type 'Document'
❌ 2024-01-15T10:30:45.124Z   lib/main.dart:45:23
❌ 2024-01-15T10:30:45.125Z   │     final element = document.querySelector('#app');
❌ 2024-01-15T10:30:45.126Z   │                              ^^^^^^^^^^^
```

### 2. **Comprehensive Log Analysis**

#### Download All Logs
```bash
# Download logs for latest build
gh run download

# Download logs for specific build
gh run download 1234567

# Download to specific directory
gh run download 1234567 --dir ./logs/
```

#### View Specific Job Logs
```bash
# List all jobs for a build
gh run view 1234567

# View specific job log
gh run view 1234567 --log --job="Test & Lint"

# Example: View only build job
gh run view --log --job="Build Web App"
```

### 3. **Failure Pattern Analysis**

#### Common Failure Commands
```bash
# Find all recent failures
gh run list --status=failure --limit 20

# Analyze failure trends
gh run list --status=failure --json | jq '.[].conclusion' | sort | uniq -c

# Check specific commit failures
gh run list --commit=abc1234 --status=failure
```

---

## 🔄 CI/CD Workflow Commands

### 1. **Workflow Management**

#### List Workflows
```bash
# Show all workflows
gh workflow list

# Example output:
# CI/CD Pipeline  active  ci.yml
# Deploy         active  deploy.yml
```

#### Workflow Status
```bash
# View workflow details
gh workflow view ci.yml

# View workflow runs
gh workflow view ci.yml --limit 10
```

#### Manual Workflow Triggers
```bash
# Trigger workflow manually (if configured)
gh workflow run ci.yml

# Trigger with inputs
gh workflow run deploy.yml --field environment=production
```

### 2. **Branch and PR Integration**

#### Check PR Build Status
```bash
# View PR checks
gh pr checks

# View specific PR build
gh pr view 123 --json checks

# Wait for PR checks to complete
gh pr checks --watch
```

#### Compare Branch Builds
```bash
# Compare builds between branches
gh run list --branch=main --limit 5
gh run list --branch=feature-branch --limit 5
```

---

## 🛠️ Advanced GitHub CLI Usage

### 1. **Custom Queries with JQ**

#### Build Analytics
```bash
# Get build duration trends
gh run list --json | jq '.[] | {id: .databaseId, duration: .timing.run_duration_ms, status: .conclusion}'

# Find longest running builds
gh run list --json | jq 'sort_by(.timing.run_duration_ms) | reverse | .[0:5] | .[] | {id: .databaseId, duration: .timing.run_duration_ms}'

# Count builds by conclusion
gh run list --limit 50 --json | jq 'group_by(.conclusion) | .[] | {conclusion: .[0].conclusion, count: length}'
```

#### Failure Analysis
```bash
# Get all failed builds with details
gh run list --status=failure --json | jq '.[] | {id: .databaseId, commit: .headSha[0:7], message: .headCommit.message, failed_at: .runStartedAt}'

# Find most common failure points
gh run list --status=failure --limit 20 --json | jq '.[] | .jobs[] | select(.conclusion == "failure") | .name' | sort | uniq -c
```

### 2. **Automated Scripts**

#### Build Status Checker
```bash
#!/bin/bash
# check_build_status.sh
status=$(gh run list --limit 1 --json | jq -r '.[0].conclusion')
if [ "$status" = "success" ]; then
    echo "✅ Latest build passed"
    exit 0
else
    echo "❌ Latest build failed"
    gh run view --log-failed
    exit 1
fi
```

#### Failure Notification
```bash
#!/bin/bash
# notify_on_failure.sh
gh run list --limit 1 --json | jq -r '.[0].conclusion' | grep -q "failure" && {
    echo "🚨 Build failure detected!"
    gh run view --log-failed | head -20
    # Add notification logic here (email, Slack, etc.)
}
```

---

## 📊 Build Performance Monitoring

### 1. **Performance Metrics**

#### Build Duration Analysis
```bash
# Get build durations
gh run list --json | jq '.[] | {id: .databaseId, duration: (.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) - (.runStartedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime), conclusion: .conclusion}'

# Average build time for successful builds
gh run list --status=success --limit 20 --json | jq '[.[] | (.updatedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) - (.runStartedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime)] | add / length'
```

#### Resource Usage
```bash
# Check build artifact sizes
gh run list --limit 5 --json | jq '.[] | {id: .databaseId, artifacts: .artifacts}'

# Download and analyze artifacts
gh run download --name build-artifacts
ls -lh build-artifacts/
```

### 2. **Trend Analysis**

#### Success Rate Tracking
```bash
# Calculate success rate for last 20 builds
gh run list --limit 20 --json | jq '[.[] | .conclusion] | map(select(. == "success")) | length' # successes
gh run list --limit 20 --json | jq '[.[] | .conclusion] | length' # total
```

#### Weekly Build Summary
```bash
# Builds from last week
week_ago=$(date -d '7 days ago' -u +%Y-%m-%dT%H:%M:%SZ)
gh run list --json | jq --arg week_ago "$week_ago" '[.[] | select(.runStartedAt > $week_ago)] | group_by(.conclusion) | .[] | {conclusion: .[0].conclusion, count: length}'
```

---

## 🔗 Integration with Development Workflow

### 1. **Pre-Push Checks**

#### Check Before Pushing
```bash
#!/bin/bash
# pre_push_check.sh
echo "🔍 Checking current build status..."
latest_status=$(gh run list --limit 1 --json | jq -r '.[0].conclusion')
if [ "$latest_status" = "failure" ]; then
    echo "⚠️  Latest build is failing. Fix before pushing?"
    read -p "Continue anyway? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```

### 2. **Post-Push Monitoring**

#### Auto-monitor After Push
```bash
#!/bin/bash
# auto_monitor.sh
echo "🚀 Pushed to GitHub. Starting build monitor..."
sleep 10  # Wait for CI to start
./scripts/watch_ci.sh
```

### 3. **Failure Recovery**

#### Quick Fix Workflow
```bash
#!/bin/bash
# quick_fix.sh
echo "❌ Build failed. Analyzing..."
gh run view --log-failed > failure_analysis.txt
echo "📝 Failure logs saved to failure_analysis.txt"
echo "🔧 Run local checks:"
echo "   ./scripts/simulate_ci.sh"
echo "   ./scripts/pre_commit_check.sh"
```

---

## 📱 Mobile/Termux Specific Tips

### 1. **Termux Optimization**

#### Efficient Commands for Mobile
```bash
# Short status check
gh run list -L 3

# Quick failure check
gh run view --log-failed | head -10

# Mobile-friendly monitoring
gh run watch | grep -E "(✓|X|🔵)"
```

#### Save Data Usage
```bash
# Minimal data usage
gh run list --json | jq '.[] | {id: .databaseId, status: .conclusion}' | head -5

# Cache results locally
gh run list --json > .gh_cache.json
jq '.[] | {id: .databaseId, status: .conclusion}' .gh_cache.json
```

### 2. **Notification Setup**

#### Simple Success/Failure Alerts
```bash
#!/bin/bash
# mobile_alert.sh
status=$(gh run list -L 1 --json | jq -r '.[0].conclusion')
case "$status" in
    "success") echo "✅ BUILD PASSED" ;;
    "failure") echo "❌ BUILD FAILED"; gh run view --log-failed | head -5 ;;
    *) echo "🔵 BUILD RUNNING" ;;
esac
```

---

## 🎯 Best Practices

### 1. **Efficient Monitoring**

- ✅ Use `gh run watch` for real-time monitoring during development
- ✅ Use `./scripts/watch_ci.sh` for enhanced monitoring with failure logs
- ✅ Check `gh run list --limit 3` for quick status overview
- ✅ Save failure logs with `gh run view --log-failed > failure.txt` for analysis

### 2. **Failure Analysis**

- ✅ Start with `gh run view --log-failed` for quick failure identification
- ✅ Use `gh run download` for complex issues requiring full logs
- ✅ Test fixes locally with `./scripts/simulate_ci.sh` before pushing
- ✅ Track failure patterns with JSON queries for systemic issues

### 3. **Performance Optimization**

- ✅ Monitor build duration trends to identify performance regressions
- ✅ Use `--limit` flags to reduce API calls and data usage
- ✅ Cache results locally when doing analysis work
- ✅ Use JQ for efficient JSON processing instead of downloading large datasets

### 4. **Integration with Local Tools**

- ✅ Combine GitHub CLI with local validation scripts
- ✅ Use exit codes for automation (`gh run list --limit 1 --json | jq -r '.[0].conclusion' | grep -q success`)
- ✅ Create custom aliases for frequently used commands
- ✅ Integrate with git hooks for automated checking

---

This guide ensures you can effectively monitor, analyze, and debug your CI/CD pipeline using GitHub CLI, keeping your development workflow smooth and efficient.