#!/bin/bash

# Custom statusLine for Claude Code
# Shows: Directory | Git Branch | Model | Context remaining % | Rate limits

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
    BRANCH=$(git --git-dir="$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')/.git" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_INFO=" | branch: $BRANCH"
    else
        GIT_INFO=""
    fi
else
    GIT_INFO=""
fi

# Extract model display name
MODEL=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$MODEL" ]; then
    MODEL_INFO=" | model: $MODEL"
else
    MODEL_INFO=""
fi

# Extract remaining context percentage
REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$REMAINING" ]; then
    REMAINING_ROUNDED=$(printf "%.0f" "$REMAINING")
    CONTEXT_INFO=" | ctx: ${REMAINING_ROUNDED}% left"
else
    CONTEXT_INFO=""
fi

# Extract rate limit usage (5-hour and 7-day) when available
FIVE_HOUR=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_HOUR_RESETS=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_DAY=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
SEVEN_DAY_RESETS=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
LIMITS_INFO=""
if [ -n "$FIVE_HOUR" ] || [ -n "$SEVEN_DAY" ]; then
    LIMITS_INFO=" |"
    if [ -n "$FIVE_HOUR" ]; then
        FIVE_HOUR_STR="5h: $(printf '%.0f' "$FIVE_HOUR")%"
        if [ -n "$FIVE_HOUR_RESETS" ] && [ "$FIVE_HOUR_RESETS" != "null" ]; then
            RESET_TIME=$(date -r "$FIVE_HOUR_RESETS" "+%H:%M" 2>/dev/null)
            if [ -n "$RESET_TIME" ]; then
                FIVE_HOUR_STR="${FIVE_HOUR_STR} (reset ${RESET_TIME})"
            fi
        fi
        LIMITS_INFO="${LIMITS_INFO} ${FIVE_HOUR_STR}"
    fi
    if [ -n "$SEVEN_DAY" ]; then
        SEVEN_DAY_STR="7d: $(printf '%.0f' "$SEVEN_DAY")%"
        if [ -n "$SEVEN_DAY_RESETS" ] && [ "$SEVEN_DAY_RESETS" != "null" ]; then
            RESET_DAY=$(date -r "$SEVEN_DAY_RESETS" "+%a" 2>/dev/null)
            if [ -n "$RESET_DAY" ]; then
                SEVEN_DAY_STR="${SEVEN_DAY_STR} (reset ${RESET_DAY})"
            fi
        fi
        LIMITS_INFO="${LIMITS_INFO} ${SEVEN_DAY_STR}"
    fi
fi

# Output format
printf "%s%s%s%s%s" "$DIR" "$GIT_INFO" "$MODEL_INFO" "$CONTEXT_INFO" "$LIMITS_INFO"
