#!/bin/bash

# Accept a plugin root directory as an argument
PLUGIN_ROOT="$1"

if [ -d "Packages/com.pz.studio.generated" ] && [ "$(basename "$(pwd)")" != "life-unity" ]; then
    # If there is no .claude folder or the .claude folder does not contain a version.txt file, set it up and ask the user to restart.
    # Setup runs here (not in SessionEnd) because SessionEnd is skipped when the user closes the terminal, kills the process, or crashes,
    # which would otherwise trap the user in a permanent "please restart" loop. Output is sent to stderr to keep stdout clean for the JSON message.
    if [ ! -d ".claude" ] || [ ! -f ".claude/version.txt" ]; then
        "${PLUGIN_ROOT}/scripts/update-docs.sh" "${PLUGIN_ROOT}" >&2
        echo "{\"systemMessage\": \"\nPlease /exit and restart Claude Code to initialize the project's .claude folder.\"}"
        exit 1
    fi

    # Get the plugin version from ../.claude-plugin/plugin.json
    PLUGIN_VERSION=$(cat "${PLUGIN_ROOT}/.claude-plugin/plugin.json" | jq -r '.version')
    PROJECT_VERSION="$(cat ".claude/version.txt")"
    # If the .version file is different than the plugin version, update the docs and ask the user to restart
    if [ "$PROJECT_VERSION" != "$PLUGIN_VERSION" ]; then
        "${PLUGIN_ROOT}/scripts/update-docs.sh" "${PLUGIN_ROOT}" >&2
        echo "{\"systemMessage\": \"\nPlease /exit and restart Claude Code to update the project's .claude folder.\"}"
        exit 1
    fi

    echo "{\"systemMessage\": \"\nThis project is using plugin version $PROJECT_VERSION.\"}"
    exit 0
fi