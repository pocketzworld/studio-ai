#!/bin/bash

# Accept a plugin root directory as an argument
PLUGIN_ROOT="$1"

if [ -d "Packages/com.pz.studio.generated" ]; then
    # If there is no .claude folder or the .claude folder does not contain a version.txt file, ask the user to restart
    if [ ! -d ".claude" ] || [ ! -f ".claude/version.txt" ]; then
        echo "{\"systemMessage\": \"\nPlease /exit and restart Claude Code to initialize the project's .claude folder.\"}"
        exit 1
    fi

    # Get the plugin version from ../.claude-plugin/plugin.json
    PLUGIN_VERSION=$(cat "${PLUGIN_ROOT}/.claude-plugin/plugin.json" | jq -r '.version')
    PROJECT_VERSION="$(cat ".claude/version.txt")"
    # If the .version file is different than the plugin version, ask the user to restart
    if [ "$PROJECT_VERSION" != "$PLUGIN_VERSION" ]; then
        echo "{\"systemMessage\": \"\nPlease /exit and restart Claude Code to update the project's .claude folder.\"}"
        exit 1
    fi

    echo "{\"systemMessage\": \"\nThis project is using plugin version $PROJECT_VERSION.\"}"
    exit 0
fi