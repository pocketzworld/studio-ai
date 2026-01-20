#!/bin/bash

# Accept a plugin root directory as an argument
PLUGIN_ROOT="$1"

SERIALIZER_SOURCE="${PLUGIN_ROOT}/skills/use-unity-editor/resources/Serializer"
SERIALIZER_DEST="Assets/Editor/Serializer"

# Only proceed if the source directory exists and we're in a Unity project
if [ -d "$SERIALIZER_SOURCE" ] && [ -d "Assets" ]; then
    # Ensure the parent directory exists
    mkdir -p "Assets/Editor"

    if [ -L "$SERIALIZER_DEST" ]; then
        # It's a symlink - check if it points to the right place
        CURRENT_TARGET=$(readlink "$SERIALIZER_DEST")
        if [ "$CURRENT_TARGET" != "$SERIALIZER_SOURCE" ]; then
            # Points somewhere else - update it
            rm "$SERIALIZER_DEST"
            ln -s "$SERIALIZER_SOURCE" "$SERIALIZER_DEST"
        fi
    elif [ ! -e "$SERIALIZER_DEST" ]; then
        # Doesn't exist - create the symlink
        ln -s "$SERIALIZER_SOURCE" "$SERIALIZER_DEST"
    fi
    # If it exists and is a real directory, leave it alone

    # Add to .gitignore if not already present
    GITIGNORE_ENTRY="Assets/Editor/Serializer/"
    if [ -f ".gitignore" ]; then
        if ! grep -qxF "$GITIGNORE_ENTRY" .gitignore; then
            echo "$GITIGNORE_ENTRY" >> .gitignore
        fi
    fi
fi

exit 0
