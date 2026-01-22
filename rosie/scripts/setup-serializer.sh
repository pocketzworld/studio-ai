#!/bin/bash

# Accept a plugin root directory as an argument
PLUGIN_ROOT="$1"

SERIALIZER_SOURCE="${PLUGIN_ROOT}/scripts/Serializer"
SERIALIZER_DEST="Assets/Editor/Serializer"

# Only proceed if the source directory exists and we're in a Unity project
if [ -d "$SERIALIZER_SOURCE" ] && [ -d "Assets" ]; then
    # If it's a symlink, remove it first
    if [ -L "$SERIALIZER_DEST" ]; then
        rm "$SERIALIZER_DEST"
    fi
    
    mkdir -p "$SERIALIZER_DEST"

    # Clear all files in destination except .meta files
    find "$SERIALIZER_DEST" -type f ! -name "*.meta" -delete

    # Copy all files from source to destination
    cp -f "$SERIALIZER_SOURCE"/*.cs "$SERIALIZER_DEST/" 2>/dev/null || true

    # Add to .gitignore if not already present
    GITIGNORE_ENTRY="Assets/Editor/Serializer/"
    if [ -f ".gitignore" ]; then
        if ! grep -qxF "$GITIGNORE_ENTRY" .gitignore; then
            echo "$GITIGNORE_ENTRY" >> .gitignore
        fi
    fi
fi

exit 0
