#!/bin/bash

# Accept a plugin root directory as an argument
PLUGIN_ROOT="$1"

# Clone and update the creator-docs repo
if [ ! -d "${PLUGIN_ROOT}/creator-docs" ]; then
  git clone https://github.com/pocketzworld/creator-docs.git "${PLUGIN_ROOT}/creator-docs"
fi

git -C "${PLUGIN_ROOT}/creator-docs" pull

# Only copy to .claude if we're in a Highrise Studio project
if [ -d "Packages/com.pz.studio.generated" ]; then
  # make .claude if it doesn't exist
  mkdir -p .claude
  # copy the contents of the claude-docs directory from the plugin root to the current working directory as .claude, overwriting any existing files
  cp -r "${PLUGIN_ROOT}/scripts/claude-docs"/* .claude/
fi