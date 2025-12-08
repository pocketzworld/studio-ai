#!/bin/bash

# Rosie Feedback Script
# Collects context and sends feedback to Slack

set -e

FEEDBACK="$*"

if [ -z "$FEEDBACK" ]; then
    echo "Error: No feedback message provided"
    exit 1
fi

if [ -z "$ROSIE_FEEDBACK_WEBHOOK" ]; then
    echo "Error: ROSIE_FEEDBACK_WEBHOOK environment variable not set. Are you in a Highrise Studio project?"
    exit 1
fi

# Gather machine info
MACHINE_TYPE=$(uname -sm 2>/dev/null || echo "Unknown")

# Get user identifier (git email > whoami > Unknown)
USER_ID=$(git config user.email 2>/dev/null || whoami 2>/dev/null || echo "Unknown")

# Get model info from environment variable (set by Claude when invoking the command)
MODEL_INFO="${CLAUDE_MODEL:-Unknown}"

# Find the most recent conversation file
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
CONVERSATION_FILE=""
CONVERSATION_SUMMARY="No conversation history found"

if [ -d "$CLAUDE_PROJECTS_DIR" ]; then
    # Find the most recently modified .jsonl file
    CONVERSATION_FILE=$(find "$CLAUDE_PROJECTS_DIR" -name "*.jsonl" -type f -print0 2>/dev/null | \
        xargs -0 ls -t 2>/dev/null | head -n 1)

    if [ -n "$CONVERSATION_FILE" ] && [ -f "$CONVERSATION_FILE" ] && command -v jq &> /dev/null; then
        # Parse JSONL and extract just role + message content in readable format
        FULL_CONVERSATION=$(tail -n 100 "$CONVERSATION_FILE" 2>/dev/null | jq -r '
            select(.message.role != null) |
            # Skip meta messages (expanded slash commands)
            select(.isMeta != true) |
            # Extract role and content
            .message as $msg |
            ($msg.role | if . == "user" then "User" else "Assistant" end) as $role |
            # Content can be string or array of objects
            (if ($msg.content | type) == "string" then
                $msg.content
            elif ($msg.content | type) == "array" then
                [.message.content[] | select(.type == "text") | .text] | join("\n")
            else
                ""
            end) as $content |
            # Only output if there is content
            select($content != "" and $content != null) |
            "\($role): \($content)\n"
        ' 2>/dev/null)

        # Check if truncation will happen
        FULL_LINE_COUNT=$(echo "$FULL_CONVERSATION" | wc -l | tr -d ' ')
        FULL_CHAR_COUNT=${#FULL_CONVERSATION}
        TRUNCATED=false

        if [ "$FULL_LINE_COUNT" -gt 20 ] || [ "$FULL_CHAR_COUNT" -gt 2500 ]; then
            TRUNCATED=true
        fi

        # Apply limits
        CONVERSATION_SUMMARY=$(echo "$FULL_CONVERSATION" | tail -n 20 | head -c 2500)

        if [ -z "$CONVERSATION_SUMMARY" ]; then
            CONVERSATION_SUMMARY="No conversation messages found"
        elif [ "$TRUNCATED" = true ]; then
            CONVERSATION_SUMMARY="(earlier messages truncated)...\n${CONVERSATION_SUMMARY}"
        fi
    fi
fi

# Escape special characters for JSON (without surrounding quotes)
escape_json() {
    printf '%s' "$1" | python3 -c 'import json,sys; s=json.dumps(sys.stdin.read()); print(s[1:-1])'
}

FEEDBACK_ESCAPED=$(escape_json "$FEEDBACK")
USER_ESCAPED=$(escape_json "$USER_ID")
MACHINE_ESCAPED=$(escape_json "$MACHINE_TYPE")
MODEL_ESCAPED=$(escape_json "$MODEL_INFO")
CONVERSATION_ESCAPED=$(escape_json "$CONVERSATION_SUMMARY")

# Build the Slack message payload with blocks
PAYLOAD=$(cat <<EOF
{
    "blocks": [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": "📬 Rosie Feedback",
                "emoji": true
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Feedback:*\n${FEEDBACK_ESCAPED}"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": "*User:*\n${USER_ESCAPED}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Machine:*\n${MACHINE_ESCAPED}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Model:*\n${MODEL_ESCAPED}"
                }
            ]
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Recent Conversation:*\n\`\`\`${CONVERSATION_ESCAPED}\`\`\`"
            }
        }
    ]
}
EOF
)

# Send to Slack
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    "$ROSIE_FEEDBACK_WEBHOOK")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    echo "✓ Feedback sent successfully!"
else
    echo "Error: Failed to send feedback (HTTP $HTTP_CODE)"
    echo "$BODY"
    exit 1
fi

