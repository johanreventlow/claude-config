#!/bin/bash

# Custom statusLine for SPCify development
# Shows: Directory | Git Branch | Model | Cost

# Read JSON input from stdin
input=$(cat)

# Get current directory (relative to home)
DIR=$(pwd | sed "s|^$HOME|~|")

# Get git branch if in a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_INFO=" | 🌿 $BRANCH"
    else
        GIT_INFO=""
    fi
else
    GIT_INFO=""
fi

# Extract model display name from JSON
if command -v jq &> /dev/null; then
    MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
else
    MODEL="Unknown (jq not installed)"
fi

# Output format
echo "📁 $DIR$GIT_INFO | 🤖 $MODEL"
