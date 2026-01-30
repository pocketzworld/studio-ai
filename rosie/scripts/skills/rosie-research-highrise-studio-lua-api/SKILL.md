---
name: rosie-research-highrise-studio-lua-api
description: Dive into the Highrise Studio Lua API docs and answer questions.
context: fork
agent: Explore
---

# Research the Highrise Studio Lua API

Parse and synthesize the Highrise Studio API docs, which describe the Lua API available to Highrise Studio projects. The docs are contained in YAML files cloned from a public repo. The YAML files are formatted like:
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

## Instructions
### 1. Find the Studio API docs locally
The Highrise Studio docs exist in a public repo, and should be downloaded locally to the active project under `.claude/creator-docs`. If not, alert the user that something has gone wrong and abort.

### 2. Understand the question
Identify classes and keywords that might be relevant to the incoming question. Does it refer to a specific type? Is it about a Lua script? Is it about a specific property or method? 

### 3. Read relevant file(s)
Peruse potentially-useful YAML files in `creator-docs/pages/learn/studio-api` and its subfolders. Use built-in tools like `Read` and command-line tools like `grep`, `ls`, `find`, `tree`, etc. to discover potentially-relevant content and read files as needed.

### 4. Succinctly respond to the question
Synthesize the relevant files into a terse, precise answer to the incoming question. Provide summaries, parameters, return types, overloads, and code examples. Correct any misunderstandings that may be present in the question. If you cannot find an answer, tell the asker and briefly list any related topics that might be helpful to them.
