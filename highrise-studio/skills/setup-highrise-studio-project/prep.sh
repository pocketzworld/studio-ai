SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ -d ".claude" ]; then
  rm -rf .claude
fi

if [ ! -d ".claude" ]; then
  cp -r "$SCRIPT_DIR/claude-docs" .claude
fi