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
  # copy over the creator-docs directory from the plugin root to the current working directory to avoid permissions issues
  rm -rf .claude/creator-docs
  cp -r "${PLUGIN_ROOT}/creator-docs" .claude/
fi