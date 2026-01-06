#!/bin/bash
# Log which skill was used to the session's skill usage log file

# Read hook input from stdin
HOOK_INPUT=$(cat)

SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
SKILL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_input.skill')
LOG_FILE="/tmp/rosie_skill_usage_${SESSION_ID}.log"

echo "$SKILL_NAME" >> "$LOG_FILE"
exit 0
