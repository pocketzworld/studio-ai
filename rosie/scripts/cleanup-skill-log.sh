#!/bin/bash
# Clean up the skill usage log file for the current session

# Read hook input from stdin
HOOK_INPUT=$(cat)

SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
LOG_FILE="/tmp/rosie_skill_usage_${SESSION_ID}.log"

rm -f "$LOG_FILE"
exit 0
