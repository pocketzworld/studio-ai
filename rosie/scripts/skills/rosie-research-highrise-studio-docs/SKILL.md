---
description: Dive into the Highrise Studio docs to answer questions and solve problems using the Lua API and built-in components.
context: fork
agent: Explore
---

# Research the Highrise Studio docs

You will be asked to answer questions or solve problems using information you gather from the Highrise Studio docs. You should research thoroughly, then respond to the user's question or problem succinctly, including references to any relevant docs, scripts, or scenes. Use built-in tools like `Read` and command-line tools like `grep`, `ls`, `find`, `tree`, etc. to access these three sources of documentation for Highrise Studio:

## Highrise Studio Lua API docs

These docs, located in `.claude/creator-docs/pages/learn/studio-api`, describe the Lua API available to Highrise Studio projects. Each class is represented by a YAML file, formatted like:
```yaml
name:
type:
summary:
code_samples:
inherits:
tags:
constructors:
  - name:
    summary:
    is_static:
    code_samples:
    tags:
    parameters:
      - name:
        type:
        tags:
        default:
        summary:
    returns:
      - type:
        summary:
properties:
  - name:
    summary:
    is_static:
    code_samples:
    tags:
    type:
methods:
  - name:
    summary:
    is_static:
    code_samples:
    tags:
    parameters:
      - name:
        type:
        tags:
        default:
        summary:
    returns:
      - type:
        summary:
math_operations:
  - operation:
    summary:
    type_a:
    type_b:
    return_type:
    code_samples:
    tags:
```

## Highrise Studio Lua reference code

These scripts, located in `.claude/reference-code`, are examples of how to use the Lua API to solve common problems. These are snippets from projects, not full projects, so do not expect every class referenced to exist. Search these scripts for any patterns or examples that might be relevant to the user's request. You can and should also search the user-written scripts in the current project.

## Highrise Studio example scenes

These scenes, located in `.claude/example-scenes`, contain serialized scenes and prefabs, as well as any Lua scripts that they rely on. Use these scenes to understand how components are composed to fully implement a solution. Read the `INDEX.md` file in `.claude/example-scenes` to understand what it contains. When checking how components are used, make sure to look at what other components are used on the same Game Object.
