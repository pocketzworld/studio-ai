# Highrise Studio Project Development Guide for AI Agents

This is a _Highrise Studio_ project, which defines a _world_ that can be built and uploaded to _Highrise_. You will be asked to assist the user in developing their Highrise world. 

**READ THE FOLLOWING CAREFULLY: You do not have any intrinsic knowlege of Highrise Studio.** You cannot do anything in Highrise Studio without help. Fortunately, you have access to the `highrise-studio` plugin, which provides skills and subagents that can help you develop this project's Highrise world. These tools bake in deep knowledge of Highrise Studio and the Highrise API. **USE THE SKILLS IN THE `highrise-studio` PLUGIN.** If you do not have access to this plugin, you should ask the user to install it.

## Key terms
- *Highrise*: a massively multiplayer online game, in which players can curate outfits for their avatar, socialize, and participate in activities across a universe of in-game worlds.
- *World*: a multiplayer environment within Highrise. Each world represents a self-contained experience and is developed in a separate Highrise Studio project. Visitors can play games, watch live streams, participate in events, and more.
- *Highrise Studio*: the development environment for creating and editing Highrise worlds. Highrise Studio is a variant of the Unity editor, but with a number of features specific to Highrise. Scripts are written in Lua, which provides access to both core Unity functionality and Highrise APIs.
- *Highrise Studio API*: the set of APIs available to Lua scripts in Highrise Studio. It is a combination of the Unity API and Highrise-specific APIs. The API is documented in the `creator-docs` repository, which is available in the `highrise-studio` plugin root under `creator-docs`.

## Project structure
A Highrise Studio project is structured as follows:
```
<project-root>/
├── .claude/           # Claude Code settings and documentation
├── Assets/            # Unity assets for the project
│   ├── Scripts/       # Lua scripts for the project
│   └── ...
├── Packages/          # Unity packages for the project
└── ...                # Other files and directories for the project
```

## Understanding Highrise Studio

### Highrise Studio fundamentals

Like Unity, Highrise Studio represents objects as collections of components. Components come from three places:
1. Core Unity components, like `Transform`, `Collider`, etc.
2. Exported Highrise internals, like `Character`, `Anchor`, etc.
3. Built-in Lua component scripts
4. User-written Lua component scripts

The core Unity components, exported Highrise internals, and built-in Lua component scripts are, collectively, the Highrise Studio API, and can be read using the `research-highrise-studio-lua-api` skill. The user-written Lua component scripts exist in this project.

The core Unity components and exported Highrise internals are implemented in C#, but you will not have access to this source. Their members are exposed via the Lua API. **You will not be writing C#.**

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

For more, read the Markdown files in `${CLAUDE_PLUGIN_ROOT}/creator-docs/pages/learn/studio/create/scripting/script-types`.