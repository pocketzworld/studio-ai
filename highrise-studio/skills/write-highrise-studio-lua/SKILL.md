---
name: write-highrise-studio-lua
description: Read, create, and edit Highrise Studio Lua scripts.
---

# Write Highrise Studio Lua code

This guide covers how to write and understand Highrise Studio Lua code.

## Key information
### Highrise Studio fundamentals

Like Unity, Highrise Studio represents objects as collections of components. Components come from three places:
1. Core Unity components, like `Transform`, `Collider`, etc.
2. Exported Highrise internals, like `Character`, `Anchor`, etc.
3. Built-in Lua component scripts
4. User-written Lua component scripts

The core Unity components, exported Highrise internals, and built-in Lua component scripts are, collectively, the Highrise Studio API, and can be read using the `research-highrise-studio-api` skill. The user-written Lua component scripts exist in this project.

The core Unity components and exported Highrise internals are implemented in C#, but you will not have access to this source. Their members are exposed via the Lua API. **You will not be writing C#.**

Consult the Markdown files in `creator-docs/pages/learn/studio` to learn more about Highrise Studio.

### World architecture
Each player connected to a Highrise world has their own copy of the Unity scene; this is called the *client*. Manipulating the game objects in a client will only affect what that player sees, not any other players connected to that world.

To interact with each other, clients connect to a remote *server* that coordinates between them. A server can communicate back-and-forth with its connected clients. This allows the server to fire networked events (either on its own, or requested by a client) that its clients can listen to, enabling synchronzied behavior.

To balance load, a world can have one or more server instances at a time, each a copy of the other with different state and a different set of connected clients. Servers of the same world can communicate via world events and world storage.

Players also maintain a consistent inventory across different worlds, primarily consisting of outfits for their character.

### Script types
Each game object in Highrise Studio will be created on both the client-side and the server-side. Each Lua component script is tagged with a type at the top which determines how each side uses it:
- `--!Type(Client)` scripts only exist on the client-side version of the object. No version of the script will run on the server.
- `--!Type(Server)` scripts only exist on the server-side version of the object. No version of the script will run on the client.
- `--!Type(ClientAndServer)` scripts exist both on the client-side and server-side versions of the object. Each version executes its own lifecycle functions and maintains its own, separate state. The client- and server-side scripts can communicate via networked events declared at the top-level of the script.
- `--!Type(Module)` scripts are similar to `ClientAndServer` scripts, except (a) there can only be one of each in a scene and (b) they can be accessed from any script using `require("MODULE_NAME")`. Like `ClientAndServer` scripts, the client-side and server-side versions maintain separate state.

For more, read the Markdown files in `creator-docs/pages/learn/studio/create/scripting/script-types`.

## Instructions

- You do not know anything intrinsically about Highrise Studio Lua code. Consult the [style guide](resources/STYLE_GUIDE.md), use the `research-highrise-studio-api` skill, and read tutorials in `creator-docs/pages/learn/studio/` as needed.
- Do **not** use Unity C#, MonoBehaviour, or Roblox APIs unless specified in the Highrise Studio API docs.
- Avoid browser or DOM references (`document`, `window`, `addEventListener`, etc.).
- If you are ever unsure, **read the docs.**

## TODO: instructions (planning, writing, style, code review)

## TODO: examples