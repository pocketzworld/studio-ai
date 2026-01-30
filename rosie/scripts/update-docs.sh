#!/bin/bash

# Accept a plugin root directory as an argument
PLUGIN_ROOT="$1"

# Check if creator-docs needs updating by comparing local HEAD to remote via GitHub API
# The API is lightweight and less likely to be throttled than git fetch
SHOULD_UPDATE=false

if [ ! -d "${PLUGIN_ROOT}/creator-docs" ]; then
  SHOULD_UPDATE=true
else
  LOCAL_SHA=$(git -C "${PLUGIN_ROOT}/creator-docs" rev-parse HEAD 2>/dev/null || echo "")
  # GitHub API: get latest commit SHA on main branch (single small request)
  REMOTE_SHA=$(curl -sf --max-time 5 \
    "https://api.github.com/repos/pocketzworld/creator-docs/commits/main" \
    | grep -m1 '"sha"' | cut -d'"' -f4)

  if [ -n "$REMOTE_SHA" ] && [ "$LOCAL_SHA" != "$REMOTE_SHA" ]; then
    SHOULD_UPDATE=true
  fi
fi

# Clone or pull only if there are actual changes
if [ "$SHOULD_UPDATE" = true ]; then
  if [ ! -d "${PLUGIN_ROOT}/creator-docs" ]; then
    git clone https://github.com/pocketzworld/creator-docs.git "${PLUGIN_ROOT}/creator-docs"
  else
    git -C "${PLUGIN_ROOT}/creator-docs" pull
  fi
fi

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
  CURRENT_HASH=$(git -C "${PLUGIN_ROOT}/creator-docs" rev-parse HEAD 2>/dev/null || echo "")
  DEPLOYED_HASH=$(git -C ".claude/creator-docs" rev-parse HEAD 2>/dev/null || echo "")
  if [ "$CURRENT_HASH" != "$DEPLOYED_HASH" ]; then
    rm -rf .claude/creator-docs
    cp -r "${PLUGIN_ROOT}/creator-docs" .claude/
  fi
  # copy the skills directory, deleting only rosie-* skills
  rm -rf .claude/skills/rosie-*
  mkdir -p .claude/skills
  cp -r "${PLUGIN_ROOT}/scripts/skills"/* .claude/skills/

  # Update .gitignore to exclude .claude/* except CLAUDE.md
  if [ -f .gitignore ]; then
    # Check if the gitignore rules are already present
    if ! grep -q "^\.claude/\*$" .gitignore; then
      echo "" >> .gitignore
      echo "# Claude Code plugin files (auto-generated)" >> .gitignore
      echo ".claude/*" >> .gitignore
      echo "!.claude/CLAUDE.md" >> .gitignore
    fi
  fi
fi