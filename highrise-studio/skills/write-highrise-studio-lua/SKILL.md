---
name: write-highrise-studio-lua
description: Write Lua scripts for Highrise Studio projects. You can't write them without this skill.
---

# Write Highrise Studio Lua code

This guide covers how to write Highrise Studio Lua code.

## Instructions

Add the following steps to your todo list:
1. Search for and read any relevant scripts in the project, if needed.
2. Ask the user for any information that is needed to solve the request.
3. If starting a new script, copy the code from the [style guide](resources/STYLE_GUIDE.lua) as a starting template.
4. Write the code, following these imperatives:
    - Rely on the `research-highrise-studio-lua-api` skill to understand the Highrise Studio API.
    - Do **not** use Unity C#, MonoBehaviour, or Roblox APIs unless specified in the Highrise Studio API docs. **There is no such thing as `task`.**
    - Avoid browser or DOM references (`document`, `window`, `addEventListener`, etc.).
    - If you are ever unsure about how to do something, **read the docs.**
    - You may have access to the `mcp__ide__getDiagnostics` tool to read syntax errors in the Lua scripts you work with. Use it to check for errors, if available.
5. Remove section headers that have no content.
6. Remove guidance comments that were copied over from the template. Keep the section headers.

## TODO: examples