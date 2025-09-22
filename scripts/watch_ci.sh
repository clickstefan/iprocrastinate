#!/bin/bash

# GitHub Actions CI Monitor Script
# Watches the latest CI run for the current commit and shows real-time status

set -e

echo "🔍 GitHub Actions CI Monitor"
echo "==============================="

# Get the latest commit hash
LATEST_COMMIT=$(git rev-parse HEAD)
SHORT_COMMIT=$(git rev-parse --short HEAD)

echo "📋 Monitoring CI for commit: $SHORT_COMMIT"
echo "⏰ $(date)"
echo ""

# Function to get latest run for current commit
get_latest_run() {
    gh run list --json id,status,conclusion,headSha,workflowName --jq "
        map(select(.headSha == \"$LATEST_COMMIT\")) |
        sort_by(.id) |
        reverse |
        .[0] // empty
    "
}

# Function to format status
format_status() {
    local status="$1"
    local conclusion="$2"

    case "$status" in
        "queued") echo "🟡 Queued" ;;
        "in_progress") echo "🔵 Running" ;;
        "completed")
            case "$conclusion" in
                "success") echo "✅ Success" ;;
                "failure") echo "❌ Failed" ;;
                "cancelled") echo "⚪ Cancelled" ;;
                "skipped") echo "⏭️  Skipped" ;;
                *) echo "❓ $conclusion" ;;
            esac
            ;;
        *) echo "❓ $status" ;;
    esac
}

# Monitor loop
last_status=""
run_id=""

while true; do
    # Get latest run info
    run_info=$(get_latest_run)

    if [ -z "$run_info" ]; then
        echo "⏳ Waiting for CI to start for commit $SHORT_COMMIT..."
        sleep 5
        continue
    fi

    # Parse run info
    current_run_id=$(echo "$run_info" | jq -r '.id // empty')
    status=$(echo "$run_info" | jq -r '.status // empty')
    conclusion=$(echo "$run_info" | jq -r '.conclusion // empty')
    workflow_name=$(echo "$run_info" | jq -r '.workflowName // empty')

    if [ -z "$current_run_id" ]; then
        echo "⏳ Waiting for CI to start..."
        sleep 5
        continue
    fi

    # Update run_id if it changed
    if [ "$run_id" != "$current_run_id" ]; then
        run_id="$current_run_id"
        echo "🆔 Run ID: $run_id"
        echo "📋 Workflow: $workflow_name"
        echo ""
    fi

    # Format current status
    current_status=$(format_status "$status" "$conclusion")

    # Show status update if it changed
    if [ "$last_status" != "$current_status" ]; then
        echo "[$(date '+%H:%M:%S')] $current_status"
        last_status="$current_status"

        # If completed, show final details
        if [ "$status" = "completed" ]; then
            echo ""
            echo "📊 Final Status: $current_status"
            echo "🔗 View on GitHub: https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/actions/runs/$run_id"

            if [ "$conclusion" = "failure" ]; then
                echo ""
                echo "❌ Build failed! Showing error logs:"
                echo "==========================================="
                gh run view "$run_id" --log-failed 2>/dev/null || echo "Could not fetch failure logs"
            elif [ "$conclusion" = "success" ]; then
                echo ""
                echo "🎉 Build successful! All checks passed."
                echo ""
                echo "📋 Summary:"
                gh run view "$run_id" 2>/dev/null | head -20 || echo "Could not fetch run summary"
            fi

            break
        fi
    fi

    sleep 3
done

echo ""
echo "✅ CI monitoring complete for commit $SHORT_COMMIT"