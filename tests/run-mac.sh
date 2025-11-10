#!/bin/bash

# Check if arguments are provided
if [ -z "$1" ]; then
    echo "Usage: $0 <test-directory-name> [<test-directory-name> ...]"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGGREGATE_RESULTS_FILE="$(mktemp)"
echo "# Test Results Summary" > "$AGGREGATE_RESULTS_FILE"
echo "" >> "$AGGREGATE_RESULTS_FILE"
echo "Generated: $(date)" >> "$AGGREGATE_RESULTS_FILE"
echo "" >> "$AGGREGATE_RESULTS_FILE"

# Function to process a single test
process_test() {
    local TEST_DIR="$1"
    local RESULT_FILE="$2"

    START_DIR="$(pwd)"
    
    # Convert TEST_DIR to absolute path
    if [[ "$TEST_DIR" != /* ]]; then
        if [ -d "$TEST_DIR" ]; then
            TEST_DIR="$(cd "$TEST_DIR" && pwd)"
        fi
    fi
    
    echo "=========================================" >&2
    echo "Processing test: $TEST_DIR" >&2
    echo "=========================================" >&2
    
    local PROMPT_FILE="${TEST_DIR}/prompt.txt"
    local PREP_SCRIPT="${TEST_DIR}/prep.sh"
    local CRITERIA_FILE="${TEST_DIR}/criteria.md"
    local POST_SCRIPT="${TEST_DIR}/post.sh"
    
    # Validate test directory exists
    if [ ! -d "$TEST_DIR" ]; then
        echo "Error: Test directory '$TEST_DIR' does not exist" >&2
        echo "" > "$RESULT_FILE"
        echo "## $TEST_DIR" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        echo "❌ Error: Test directory does not exist" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        return
    fi
    
    # Validate prompt.txt exists
    if [ ! -f "$PROMPT_FILE" ]; then
        echo "Error: prompt.txt not found in '$TEST_DIR'" >&2
        echo "" > "$RESULT_FILE"
        echo "## $TEST_DIR" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        echo "❌ Error: prompt.txt not found" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        return
    fi
    
    # Validate criteria.md exists
    if [ ! -f "$CRITERIA_FILE" ]; then
        echo "Error: criteria.md not found in '$TEST_DIR'" >&2
        echo "" > "$RESULT_FILE"
        echo "## $TEST_DIR" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        echo "❌ Error: criteria.md not found" >> "$RESULT_FILE"
        echo "" >> "$RESULT_FILE"
        return
    fi
    
    # Create separate temp directory for this test
    local TEMP_DIR="$(mktemp -d)"
    echo "Created temp directory: $TEMP_DIR" >&2
    
    cp -r "$SCRIPT_DIR/../highrise-studio/skills/setup-highrise-studio-project/claude-docs" "$TEMP_DIR/.claude"
    cd "$TEMP_DIR"
    git clone https://github.com/pocketzworld/creator-docs.git > /dev/null 2>&1
    
    # Run prep.sh if it exists
    if [ -f "$PREP_SCRIPT" ]; then
        echo "Running prep.sh from $TEST_DIR..." >&2
        cd "$TEST_DIR"
        bash "$PREP_SCRIPT" "$TEMP_DIR"
        cd "$TEMP_DIR"
    fi
    
    echo "Working in $TEMP_DIR" >&2
    local OUTPUT_FILE="${TEMP_DIR}/answer.txt"
    echo "Writing output to $OUTPUT_FILE" >&2
    local PROMPT="$(cat $PROMPT_FILE)"
    
    # Generate a UUID for the session
    local SESSION_ID="$(uuidgen)"
    
    # Create a temporary file with the prompt text for easier handling
    local PROMPT_TEMP_FILE="$(mktemp)"
    echo "$PROMPT. Write your final response to this prompt to $OUTPUT_FILE." > "$PROMPT_TEMP_FILE"
    
    # Run claude in interactive mode in a separate terminal window
    # Wait 2 seconds, then type the prompt and press Enter
    osascript <<EOF
tell application "Terminal"
    activate
    set newWindow to do script "cd '$TEMP_DIR' && claude"
    delay 1.5
    tell application "System Events"
        tell process "Terminal"
            set frontmost to true
            key code 36  -- trust the folder
            delay 1
            set promptText to (read POSIX file "$PROMPT_TEMP_FILE")
            keystroke promptText
            delay 0.5
            key code 36  -- submit the message
        end tell
    end tell
end tell
EOF
    
    # Clean up temp file
    rm -f "$PROMPT_TEMP_FILE"
    
    # Wait for OUTPUT_FILE to be written (with 1 minute timeout)
    echo "Waiting for claude to write output to $OUTPUT_FILE..." >&2
    local TIMEOUT=300  # 5 minutes in seconds
    local ELAPSED=0
    local CHECK_INTERVAL=1  # Check every second
    
    while [ $ELAPSED -lt $TIMEOUT ]; do
        if [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
            echo "Output file written successfully after ${ELAPSED} seconds" >&2
            break
        fi
        sleep $CHECK_INTERVAL
        ELAPSED=$((ELAPSED + CHECK_INTERVAL))
    done
    
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "Warning: Timeout reached (${TIMEOUT}s) waiting for output file" >&2
        if [ ! -f "$OUTPUT_FILE" ]; then
            echo "Output file was never created" >&2
            touch "$OUTPUT_FILE"  # Create empty file to prevent errors
        elif [ ! -s "$OUTPUT_FILE" ]; then
            echo "Output file exists but is empty" >&2
        fi
    fi
    
    if [ -f "$POST_SCRIPT" ]; then
        echo "Running post.sh from $TEST_DIR..." >&2
        cd "$TEST_DIR"
        bash "$POST_SCRIPT" "$TEMP_DIR"
        cd "$TEMP_DIR"
    fi
    
    local CLAUDE_OUTPUT="$(cat $OUTPUT_FILE)"
    
    local CRITERIA="$(cat $CRITERIA_FILE)"
    
    # Capture evaluation results
    local EVAL_OUTPUT_FILE="$(mktemp)"
    claude --append-system-prompt "$(cat $SCRIPT_DIR/evaluator-prompt.txt)" --print "# Prompt
$PROMPT

---

# Claude Code output
$CLAUDE_OUTPUT

---

# Evaluation criteria
$CRITERIA" > "$EVAL_OUTPUT_FILE"
    
    # Write results to result file
    echo "" > "$RESULT_FILE"
    echo "## $TEST_DIR" >> "$RESULT_FILE"
    echo "" >> "$RESULT_FILE"
    cat "$EVAL_OUTPUT_FILE" >> "$RESULT_FILE"
    echo "" >> "$RESULT_FILE"
    echo "---" >> "$RESULT_FILE"
    echo "" >> "$RESULT_FILE"
    
    # Clean up temp directory
    rm -rf "$TEMP_DIR"
    rm -f "$OUTPUT_FILE" "$EVAL_OUTPUT_FILE"
    
    echo "Completed test: $TEST_DIR" >&2
    echo "" >&2

    cd "$START_DIR"
}

# Create result directory for parallel execution
RESULT_DIR="$(mktemp -d)"
RESULT_FILES=()
TEST_PIDS=()

# Launch all tests in parallel
for TEST_DIR in "$@"; do
    RESULT_FILE="$(mktemp -p "$RESULT_DIR")"
    RESULT_FILES+=("$RESULT_FILE")
    process_test "$TEST_DIR" "$RESULT_FILE" &
    # Wait until the previous test has had all of its inputs sent
    sleep 5
    TEST_PIDS+=($!)
done

# Wait for all tests to complete
echo "Waiting for all tests to complete..." >&2
for PID in "${TEST_PIDS[@]}"; do
    wait "$PID"
done

# Aggregate all results
for RESULT_FILE in "${RESULT_FILES[@]}"; do
    if [ -f "$RESULT_FILE" ] && [ -s "$RESULT_FILE" ]; then
        cat "$RESULT_FILE" >> "$AGGREGATE_RESULTS_FILE"
    fi
done

# Clean up result directory
rm -rf "$RESULT_DIR"

echo "========================================="
echo "All tests completed. Results aggregated in:"
echo "$AGGREGATE_RESULTS_FILE"
echo "========================================="

# Kill all claude processes
echo "Killing all claude processes..." >&2
pkill -f claude || true
