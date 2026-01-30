---
name: rosie-check-example-scenes
description: Explore the serializations of example Highrise Studio scenes to find patterns that can be used to solve the user's request.
context: fork
agent: Explore
---

# Check example scenes

This skill will help you solve problems with Highrise Studio scenes by comparing to high-quality reference scenes. This is less about style and more about solutions to common and important problems that Highrise Studio developers face.

## Instructions
### 1. Find relevant examples from the project's existing scene
Explore the existing scene JSON (`active_scene.json`) to see if there is already a solution to the user's request. If there is a relevant pattern but the user's question indicates that it is not functioning as expected, do not use it to shape your answer.

### 2. Find relevant examples from the reference scenes
A collection of Highrise Studio reference scenes should exist in the project's `./claude/example-scenes` directory. The scenes are represented as JSON files, serialized using the same process as the active scene (read your CLAUDE.md for more information). Search the collection of scenes for any content that might be relevant to the user's request until you have a confident answer, or are confident that no relevant content exists. Note that the reference IDs in the JSON files are internally consistent, but do not map to any objects in the actual active scene.

### 3. Provide a succient list of patterns and examples
Synthesize the relevant content into a terse, precise answer to the user's request. Provide reference snippets verbatim and summarize the patterns as best you can. If you cannot find any relevant content, tell the user rather than making up an answer.
