#!/bin/bash

# Sets up a Highrise Studio project for use with OpenAI Codex.
# Run with cwd = the user's project directory.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="${SCRIPT_DIR}/../rosie"

# 1. Run update-docs.sh to set up .claude/ folder with docs, creator-docs, skills, version, gitignore rules
bash "${PLUGIN_ROOT}/scripts/update-docs.sh" "$PLUGIN_ROOT"

# 2. Create/update AGENTS.md with instruction line
AGENTS_INSTRUCTION="**Read the important instructions in @.claude/ABOUT_HIGHRISE_STUDIO.md before you start.**"
if [ ! -f AGENTS.md ]; then
  echo "" > AGENTS.md
fi
if ! grep -qF "Read the important instructions in @.claude/ABOUT_HIGHRISE_STUDIO.md before you start." AGENTS.md; then
  sed -i.bak '1 a\
'"$AGENTS_INSTRUCTION"'' AGENTS.md
  rm -f AGENTS.md.bak
fi

# 3. Copy skills to .agents/skills/ (Codex skill format)
rm -rf .agents/skills/rosie-*
mkdir -p .agents/skills
cp -r "${PLUGIN_ROOT}/scripts/skills"/* .agents/skills/

# 4. Run setup-serializer.sh to copy Serializer C# scripts
bash "${PLUGIN_ROOT}/scripts/setup-serializer.sh" "$PLUGIN_ROOT"
