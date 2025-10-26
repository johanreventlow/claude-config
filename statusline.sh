#!/bin/bash

# Custom statusLine for SPCify development
# Shows: Directory | Git Branch | Model | Token Usage

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

# Model name (hardcoded for now - Claude Code doesn't expose this as env var)
MODEL="Sonnet 4.5"

# Token usage placeholder (Claude Code doesn't expose this as env var yet)
# This will show "N/A" until Claude Code provides token info
TOKENS="N/A"

# Output format
echo "📁 $DIR$GIT_INFO | 🤖 $MODEL | 🎫 $TOKENS"
