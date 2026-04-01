#!/bin/bash

# UserPromptSubmit hook: resolve @ObjectName references to scene objects.
# Reads the user's prompt from stdin JSON, extracts @mentions, looks them up
# in active_scene.json, and outputs lightweight references (referenceId + jqPath)
# so Claude can quickly locate objects without reading the full scene.

SCENE_FILE="Temp/Highrise/Serializer/active_scene.json"

# Silent no-op if not a Highrise Studio project or scene isn't serialized
if [ ! -f "$SCENE_FILE" ]; then
    exit 0
fi

# Read the prompt from stdin JSON
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')

if [ -z "$PROMPT" ]; then
    exit 0
fi

# Extract @mentions from the prompt.
# Match @Word or @"Quoted Name" patterns.
# Exclude: file paths (@./foo, @scripts/foo), emails (word@word).
NAMES=()

# Quoted form: @"Some Name"
while IFS= read -r name; do
    [ -n "$name" ] && NAMES+=("$name")
done < <(echo "$PROMPT" | grep -oE '@"[^"]+"' | sed 's/^@"//;s/"$//')

# Unquoted form: @Word (must be preceded by start-of-line or whitespace, not a letter)
# Exclude patterns with / or . immediately after @ (file paths)
while IFS= read -r name; do
    [ -n "$name" ] && NAMES+=("$name")
done < <(echo "$PROMPT" | grep -oE '(^|[[:space:]])@[A-Za-z_][A-Za-z0-9_]*' | sed 's/^[[:space:]]*@//')

if [ ${#NAMES[@]} -eq 0 ]; then
    exit 0
fi

# Build a JSON array of names to search for
NAMES_JSON=$(printf '%s\n' "${NAMES[@]}" | jq -R . | jq -s .)

# Single-pass jq query: find all matching objects with referenceId and jqPath
RESULTS=$(jq --argjson names "$NAMES_JSON" '
  [path(.. | objects | select(.objectProperties?.name? as $n | $names | index($n) != null)) as $p |
   getpath($p) as $obj |
   {
     referenceId: $obj.referenceId,
     name: $obj.objectProperties.name,
     jqPath: ($p | map(if type == "number" then "[\(.)]\("")" else ".\(.)" end) | join(""))
   }]
' "$SCENE_FILE" 2>/dev/null)

# Silent no-op if jq failed or no results
if [ -z "$RESULTS" ] || [ "$RESULTS" = "[]" ]; then
    exit 0
fi

# Format output for Claude's context
echo "The user referenced scene objects with @. Here are their locations in $SCENE_FILE:"
echo ""
echo "$RESULTS" | jq -r '.[] | "@\(.name): referenceId=\"\(.referenceId)\", jqPath=\"\(.jqPath)\""'

exit 0
