#!/bin/bash

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <test-directory-name>"
    exit 1
fi

TEST_DIR_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="${SCRIPT_DIR}/${TEST_DIR_NAME}"
PROMPT_FILE="${TEST_DIR}/prompt.txt"
PREP_SCRIPT="${TEST_DIR}/prep.sh"
CRITERIA_FILE="${TEST_DIR}/criteria.md"

# Validate test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo "Error: Test directory '$TEST_DIR' does not exist"
    exit 1
fi

# Validate prompt.txt exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: prompt.txt not found in '$TEST_DIR'"
    exit 1
fi

TEMP_DIR="$(mktemp -d)"

cp -r "$SCRIPT_DIR/../highrise-studio/skills/setup-highrise-studio-project/claude-docs" "$TEMP_DIR/.claude"
cd "$TEMP_DIR"
git clone https://github.com/pocketzworld/creator-docs.git

# Run prep.sh if it exists
if [ -f "$PREP_SCRIPT" ]; then
    echo "Running prep.sh from $TEST_DIR..."
    cd "$TEST_DIR"
    bash "$PREP_SCRIPT"
fi

echo "working in $TEMP_DIR"
OUTPUT_FILE="$(mktemp)"
echo "writing output to $OUTPUT_FILE"
PROMPT="$(cat $PROMPT_FILE)"

# The wait part delays the execution of the actual payload, which gives time for plugins to actually load into context
claude "wait 2 seconds. then, after completing that command, follow this prompt: $PROMPT" --print --verbose > "$OUTPUT_FILE"

CLAUDE_OUTPUT="$(cat $OUTPUT_FILE)"
echo "$CLAUDE_OUTPUT"
echo ""

CRITERIA="$(cat $CRITERIA_FILE)"

claude --append-system-prompt "$(cat $SCRIPT_DIR/evaluator-prompt.txt)" --print "# Prompt
$PROMPT

---

# Claude Code output
$CLAUDE_OUTPUT

---

# Evaluation criteria
$CRITERIA"