---
name: setup-highrise-studio-project
description: Initialize a Highrise Studio project with everything Claude needs. Use this skill only when explicitly requested via the /rosie command; do not use it automatically.
---

# Setup Highrise Studio Project

This skill updates a Highrise Studio project with everything Claude Code needs to function well. When this skill is invoked, here's what you'll do:

## 1. Import `claude-docs`
There is a directory called `claude-docs/` in this skill's folder. Copy this directory into the current project and name it `.claude/`. This will initialize future Claude Code sessions in this project with the settings and information they need to work effectively with Highrise Studio.

## 2. Prepare `creator-docs`
The Highrise Studio docs exist in the public `pocketzworld/creator-docs` repo, on the `main` branch. If this project does not already contain a local copy, download one with `git clone https://github.com/pocketzworld/creator-docs.git`.

Make sure that this directory is not captured by any git tracking of the current project.

## 3. Tell the user to restart Claude Code
The changes made by this skill require Claude Code to be restarted to take effect. Tell the user to restart their Claude Code session before proceeding.