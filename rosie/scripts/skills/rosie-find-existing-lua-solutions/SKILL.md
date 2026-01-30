---
name: rosie-find-existing-lua-solutions
description: Dig through examples of Highrise Studio Lua code to find patterns that can be used to solve the user's request.
context: fork
agent: Explore
---

# Find existing Lua solutions

This skill will help you identify patterns for Highrise Studio Lua code that can solve the user's request. This is less about style and more about solutions to common and important problems that Highrise Studio developers face.

## Instructions
### 1. Find relevant examples from the project's existing code
Explore the existing Lua scripts in the project's `Assets/Scripts/` folder to see if there is already a solution to the user's request.

### 2. Find relevant examples from the reference code
A collection of Highrise Studio reference code should exist in the project's `./claude/reference-code` directory. The reference code is organized into topic folders. Read the references for any topics relevant to the user's request, and search the other folders for relevant strings in case there are other useful examples.

### 3. Provide a succient list of coding patterns and examples
Synthesize the relevant files into a terse, precise answer to the user's request. Provide reference code verbatim and summarize the patterns as best you can. If you cannot find any relevant code, tell the user rather than making up a pattern.
