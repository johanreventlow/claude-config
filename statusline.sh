#!/bin/bash

# Custom statusLine for Claude Code
# Shows: Directory | Git Branch | Context remaining %

# Read JSON input from stdin
input=$(cat)

# Get current working directory (relative to home, shortened)
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
if [ -z "$DIR" ]; then
    DIR=$(pwd)
fi
DIR=$(echo "$DIR" | sed "s|^$HOME|~|")

# Get git branch if in a git repo
if git -C "$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_INFO=" | branch: $BRANCH"
    else
        GIT_INFO=""
    fi
else
    GIT_INFO=""
fi

# Extract remaining context percentage
REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$REMAINING" ]; then
    REMAINING_ROUNDED=$(printf "%.0f" "$REMAINING")
    CONTEXT_INFO=" | context: ${REMAINING_ROUNDED}%"
else
    CONTEXT_INFO=""
fi

# Output format
printf "%s%s%s" "$DIR" "$GIT_INFO" "$CONTEXT_INFO"
