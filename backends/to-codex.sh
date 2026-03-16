#!/bin/bash

# Sets up a Highrise Studio project for use with OpenAI Codex.
# Run with cwd = the user's project directory.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="${SCRIPT_DIR}/../rosie"

# 1. Run update-docs.sh to set up .claude/ folder with docs, creator-docs, skills, version, gitignore rules
bash "${PLUGIN_ROOT}/scripts/update-docs.sh" "$PLUGIN_ROOT"

# 2. Build AGENTS.md from ABOUT_HIGHRISE_STUDIO.md, prepending any user content from CLAUDE.md
AGENTS_CONTENT=""
if [ -f .claude/CLAUDE.md ]; then
  # Remove the exact reference line and trim leading/trailing whitespace
  REFERENCE_LINE='**Read the important instructions in @ABOUT_HIGHRISE_STUDIO.md before you start.**'
  USER_CONTENT=$(awk -v ref="$REFERENCE_LINE" '{idx=index($0,ref); while(idx){$0=substr($0,1,idx-1) substr($0,idx+length(ref)); idx=index($0,ref)}} 1' .claude/CLAUDE.md | awk 'NF{found=1} found' | awk 'NF{last=NR} {lines[NR]=$0} END{for(i=1;i<=last;i++) print lines[i]}')
  if [ -n "$USER_CONTENT" ]; then
    AGENTS_CONTENT="${USER_CONTENT}
"
  fi
fi
{ printf '%s\n' "$AGENTS_CONTENT"; cat .claude/ABOUT_HIGHRISE_STUDIO.md; } > AGENTS.md

# 3. Copy skills to .agents/skills/ (Codex skill format)
rm -rf .agents/skills/rosie-*
mkdir -p .agents/skills
cp -r "${PLUGIN_ROOT}/scripts/skills"/* .agents/skills/

# 4. Run setup-serializer.sh to copy Serializer C# scripts
bash "${PLUGIN_ROOT}/scripts/setup-serializer.sh" "$PLUGIN_ROOT"
