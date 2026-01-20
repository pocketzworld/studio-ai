#!/bin/bash

# Accept a plugin root directory as an argument
PLUGIN_ROOT="$1"

# Clone and update the creator-docs repo at plugin root
if [ ! -d "${PLUGIN_ROOT}/creator-docs" ]; then
  git clone https://github.com/pocketzworld/creator-docs.git "${PLUGIN_ROOT}/creator-docs"
fi

git -C "${PLUGIN_ROOT}/creator-docs" pull

# Only copy to .claude if we're in a Highrise Studio project
if [ -d "Packages/com.pz.studio.generated" ]; then
  mkdir -p .claude
  # if there is a version.txt file that contains anything less than 0.3.0, delete .claude/CLAUDE.md if it exists
  if [ -f .claude/version.txt ] && [[ "$(cat .claude/version.txt)" < "0.3.0" ]]; then
    rm -f .claude/CLAUDE.md
  fi
  # if there is no CLAUDE.md file in .claude, create it
  if [ ! -f .claude/CLAUDE.md ]; then
    touch .claude/CLAUDE.md
    echo "# About this Highrise Studio project" > .claude/CLAUDE.md
    echo "**Read the important instructions in @ABOUT_HIGHRISE_STUDIO.md before you start.**" >> .claude/CLAUDE.md
  fi
  # copy the contents of the claude-docs directory from the plugin root to the current working directory as .claude, overwriting any existing files
  cp -r "${PLUGIN_ROOT}/scripts/claude-docs"/* .claude/
  # create a version.txt file in the .claude folder with the plugin version
  PLUGIN_VERSION=$(cat "${PLUGIN_ROOT}/.claude-plugin/plugin.json" | jq -r '.version')
  echo "$PLUGIN_VERSION" > .claude/version.txt
  # copy over the creator-docs directory only if it's changed
  CURRENT_HASH=$(git -C "${PLUGIN_ROOT}/creator-docs" rev-parse HEAD)
  DEPLOYED_HASH=$(git -C ".claude/creator-docs" rev-parse HEAD 2>/dev/null || echo "")
  if [ "$CURRENT_HASH" != "$DEPLOYED_HASH" ]; then
    rm -rf .claude/creator-docs
    cp -r "${PLUGIN_ROOT}/creator-docs" .claude/
  fi
fi