---
name: setup-highrise-studio-project
description: Initialize a Highrise Studio project with everything Claude needs. Use this skill only when explicitly requested via the /rosie command; do not use it automatically.
---

# Setup Highrise Studio Project

This skill updates a Highrise Studio project with everything Claude Code needs to function well. When this skill is invoked, here's what you'll do:

1. Run `prep.sh`.

2. Run `claude-docs/update-docs.sh`.

3. Tell the user to restart Claude Code, as the changes made by this skill require Claude Code to be restarted to take effect.