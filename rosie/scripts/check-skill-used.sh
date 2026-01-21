#!/bin/bash
# Check if the appropriate skill has been invoked before allowing file operations

# File pattern to required skills mapping
# Format: "glob_pattern:skill1|skill2|skill3"

# Requirements for write/edit/create operations
declare -a WRITE_REQUIREMENTS=(
    "*.lua:rosie:create-highrise-studio-ui|rosie:write-highrise-studio-lua"
    "*.uxml:rosie:create-highrise-studio-ui"
    "*.uss:rosie:create-highrise-studio-ui"
)

# Requirements for read/search operations
declare -a READ_REQUIREMENTS=(
    "*.unity:rosie:use-unity-editor"
    "*.prefab:rosie:use-unity-editor"
)

# Read stdin once and store it
HOOK_INPUT=$(cat)

SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id')
LOG_FILE="/tmp/rosie_skill_usage_${SESSION_ID}.log"

# Read all potential file paths from the tool input
# Write tools use: file_path, path
# Read tools use: target_file, path
# Search tools use: target_directories (array)
FILE_PATHS=$(echo "$HOOK_INPUT" | jq -r '
    .tool_input |
    [
        .file_path,
        .target_file,
        .path,
        (.target_directories // [] | .[])
    ] |
    map(select(. != null and . != "")) |
    .[]
' 2>/dev/null)

# Determine operation type based on the tool name
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // ""' 2>/dev/null)

IS_READ_OP="false"
case "$TOOL_NAME" in
    Read|Grep|Search|Glob)
        IS_READ_OP="true"
        ;;
esac

# Select the appropriate requirements array
if [[ "$IS_READ_OP" == "true" ]]; then
    REQUIREMENTS=("${READ_REQUIREMENTS[@]}")
    OPERATION="read or search"
else
    REQUIREMENTS=("${WRITE_REQUIREMENTS[@]}")
    OPERATION="modify"
fi

# Check each file path against requirements
while IFS= read -r file_path; do
    [[ -z "$file_path" ]] && continue

    # Get just the filename for pattern matching
    filename=$(basename "$file_path")

    for requirement in "${REQUIREMENTS[@]}"; do
        pattern="${requirement%%:*}"
        skills="${requirement#*:}"

        # Check if filename matches the glob pattern
        if [[ "$filename" == $pattern ]]; then
            # This file type requires a skill check
            if [[ -f "$LOG_FILE" ]] && grep -qE "$skills" "$LOG_FILE"; then
                # Skill was used, allow the operation
                continue 2
            fi
            
            # Format skills for display
            skill_list=$(echo "$skills" | tr '|' '\n' | sed 's/^/  - /' | tr '\n' ',' | sed 's/,$//' | tr ',' '\n')
            
            echo "BLOCKED: Cannot $OPERATION $pattern files without first using one of these skills:" >&2
            echo "$skill_list" >&2
            exit 2
        fi
    done
done <<< "$FILE_PATHS"

# No matching pattern or skill was used, allow the operation
exit 0
