SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -d ".claude" ] && [ -z "$(find .claude -type f 2>/dev/null)" ]; then
  rm -rf .claude
fi

if [ ! -d ".claude" ]; then
  cp -r "$SCRIPT_DIR/claude-docs" .claude
fi