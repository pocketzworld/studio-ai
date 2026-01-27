# Highrise Studio Project Development Guide for AI Agents

This is a _Highrise Studio_ project, which defines a _world_ that can be built and uploaded to _Highrise_. You will be asked to assist the user in developing their Highrise world. 

You do not have any intrinsic knowlege of Highrise Studio. You cannot do anything in Highrise Studio without help. You cannot understand its code, its archiecture, or its API. Fortunately, you have this document and the `rosie` plugin, which provides skills that will help you develop this project's Highrise world. These tools have deep knowledge of Highrise Studio and the Highrise API.

## Key terms
- *Highrise*: a massively multiplayer online game, in which players can curate outfits for their avatar, socialize, and participate in activities across a universe of in-game worlds.
- *World*: a multiplayer environment within Highrise. Each world represents a self-contained experience and is developed in a separate Highrise Studio project. Visitors can play games, watch live streams, participate in events, and more.
- *Highrise Studio*: the development environment for creating and editing Highrise worlds. Highrise Studio is a variant of the Unity editor, but with a number of features specific to Highrise. Scripts are written in Lua, which provides access to both core Unity functionality and Highrise APIs.
- *Highrise Studio API*: the set of APIs available to Lua scripts in Highrise Studio. It is a combination of the Unity API and Highrise-specific APIs. The API is documented in the `creator-docs` repository, which is available in this project under `.claude/creator-docs`.

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

### A simple Highrise Studio Lua script
```lua
--!Type(Client)

local myVar: number = 0

function self:Update()
    myVar = myVar + Time.deltaTime
    print(myVar)
```

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
- `--!Type(UI)` scripts define the logic for UI components, and are accompanied by a UXML file and a USS file.
- `--!Type(Module)` scripts are similar to `ClientAndServer` scripts, except (a) there can only be one of each in a scene and (b) they can be accessed from any script using `require("MODULE_NAME")`. Like `ClientAndServer` scripts, the client-side and server-side versions maintain separate state. **CRITICAL: the module script must be attached to some Game Object in the scene to be used by any script. Always check that the module script is attached to a Game Object in the scene.** Unlike some other Lua flavors, Highrise Studio modules do not need to return anything; their global fields will be accessible from the table returned by `require()`. For example:

    ```lua
    --!Type(Module)
    --MyModule.lua

    MyVar = 0

    function self:ServerUpdate()
        MyVar = MyVar + Time.deltaTime
    end
    ```

    ```lua
    --!Type(Server)
    --MyComponent.lua

    local myModule = require("MyModule")

    function self:Update()
        print(myModule.MyVar)
    end
    ```

For more, read the Markdown files in `creator-docs/pages/learn/studio/create/scripting/script-types`.

## Writing Highrise Studio Lua code

To write Highrise Studio Lua code, follow these steps, using your TODO list to track your progress:

1. Search for and read any relevant scripts in the project, if needed.
2. If starting a new script, copy the code from the style guide (`.claude/LUA_STYLE_GUIDE.lua`) as a starting template. **Do not create a new script from scratch, as the style will be wrong.**
3. Use the `rosie-research-highrise-studio-lua-api` skill to understand the Highrise Studio API.
4. Write the code, following these imperatives:
    - Do **not** use Unity C#, MonoBehaviour, or Roblox APIs unless specified in the Highrise Studio API docs. **There is no such thing as `task`.**
    - Avoid browser or DOM references (`document`, `window`, `addEventListener`, etc.).
5. If you have access to the `mcp__ide__getDiagnostics` tool, use it to read syntax errors in the Lua scripts you work with.
6. Remove section headers that have no content.
7. Remove guidance comments that were copied over from the template. Keep the section headers.

## Creating Highrise Studio UI components

A Highrise Studio UI component consists of three parts:
- A UXML file, which defines the UI's structure.
- A Lua script, which handles interaction and data-based rendering.
- A USS file, which defines the UI's styles.

You must create all three parts to have a functional UI component. There is **no** HTML or CSS.

To create a Highrise Studio UI component, follow these steps, using your TODO list to track your progress:

Add the following steps to your todo list:
1. Search for and read any relevant scripts in the project, if needed.
2. Ask the user for any information that is needed to solve the request.
3. If creating a new UI component, copy the contents from the template directory `.claude/MyUIElement/` to a new directory in the project's `Assets/UI` folder. Name the directory and all of its contents the desired UI component name in `PascalCase`.
4. Write the UXML file, starting from the template.
    - Rely on the `rosie-research-highrise-studio-lua-api` skill to determine what elements exist and how to use them. Valid elements will inherit from `VisualElement` or a subclass thereof.
    - When you are done, remove guidance comments that were copied over from the template.
5. Write the Lua script, starting from the template.
    - Rely on the `rosie-research-highrise-studio-lua-api` skill to understand the Highrise Studio API.
    - Do **not** use Unity C#, MonoBehaviour, or Roblox APIs unless specified in the Highrise Studio API docs. **There is no such thing as `task`.**
    - Avoid browser or DOM references (`document`, `window`, `addEventListener`, etc.).
    - If you are ever unsure about how to do something, **read the docs.**
    - You may have access to the `mcp__ide__getDiagnostics` tool to read syntax errors in the Lua scripts you work with. Use it to check for errors, if available.
    - When you are done with the Lua script, remove section headers that have no content and non-header guidance comments that were copied over from the template.
6. Write the USS file, starting from the template. When you are done, remove guidance comments that were copied over from the template.
    - Ensure that all class names specified in the UXML file are defined in the USS file.

# Using the Highrise Studio Unity Editor

Highrise Studio is built on Unity, and uses a variant of the Unity editor to edit scenes and prefabs. This guide covers:
- How you can read and edit scenes and prefabs as a user would in the Unity editor
- How to focus the Unity editor window to trigger pending changes
- How to trigger a Lua rebuild to generate wrapper code for new Lua scripts
- How to read the Unity console to check for errors and warnings
- How to start and stop play mode to test your changes
- How to capture a screenshot of the Unity editor's Game view to visually inspect the current state of the game

## Reading and editing scenes and prefabs

### Reading the scene

Highrise Studio serializes the active scene to a JSON file for easier understanding. You can find the JSON file at `Temp/Highrise/Serializer/active_scene.json`. It's going to be too big to read directly, so you will need to use tools like `jq` to read it. The JSON file should be up-to-date with the scene's current state.

The JSON file contains the scene's entire Game Object hierarchy. There will be a single top-level object called "SceneRoot", whose children are the root Game Objects in the scene. The JSON file is structured as follows:
```json
{
  "referenceId": "a GUID that uniquely identifies this Game Object within the scene. Not persistent across editor reloads.",
  "objectProperties": {
    "name": "the name of the game object, as it appears in the hierarchy.",
    "activeSelf": "whether the Game Object is enabled.",
    "tag": "the Game Object's tag.",
    "parentGameObject": "the GUID of the parent Game Object, or null if this is a root Game Object.",
    "prefabPath": "the path to the prefab that this Game Object is an instance of, or null if this is not an instance of a prefab."
  },
  "components": [
    {
      "componentType": "the type of the component (e.g., UnityEngine.Transform)",
      "referenceId": "a GUID that uniquely identifies this component within the scene. Not persistent across editor reloads.",
      "componentProperties": {
        "PROPERTY_NAME (e.g., position)": {
          "propertyName": "the name of the property (e.g., position, rotation, scale, etc.), matching the PROPERTY_NAME key.",
          "type": "the type of the property (e.g., UnityEngine.Vector3, String, etc. If the type is an enum, the full name of the enum will be used, followed by a list of the possible values in parentheses.)",
          "value": "the value of the property."
        }
      }
    }
  ],
  "children": [
    {
      // An object of the same format as the root object; may have children of its own nested within it.
    }
  ]
}
```

Here are some important property value formats:
```json
{
  "type": "UnityEngine.Vector2",
  "value": {"x": 1.0, "y": 2.0}
}
{
  "type": "UnityEngine.Vector3",
  "value": {"x": 1.0, "y": 2.0, "z": 3.0}
}
{
  "type": "UnityEngine.Vector4" | "UnityEngine.Quaternion",
  "value": {"x": 1.0, "y": 2.0, "z": 3.0, "w": 4.0}
}
{
  "type": "GameObject" | "a component type (e.g., Transform), when a property refers to a component",
  "value": "the GUID of the referenced Game Object or Component OR if the field refers to a prefab asset, a path to the prefab asset with the prefix 'prefab:' (e.g., 'prefab:Assets/Prefabs/MyPrefab.prefab')."
}
```

### Reading prefabs

Highrise Studio serializes all prefabs in the Assets directory to JSON files for easier understanding. You can find the JSON files in `Temp/Highrise/Serializer/`, under the name of the prefab file (e.g., `Assets/Prefabs/MyPrefab.prefab.json`). Each JSON file is structured the same as the active scene file, and the prefabs can be edited using the same editing instructions as the scene. You should make edits to the prefabs using the reference IDs in this file; only use the `prefab:PATH` format as the value of a property that refers to a prefab asset.

### Editing the scene or a prefab

**Do not modify the active_scene.json or .prefab.json file directly; this will not do anything.** Instead, you will submit a queue of changes to be applied to the scene in a file you will create called `Temp/Highrise/Serializer/edit.json`. The file consists of an array of objects. Each object is required to have an `editType` key, which will determine how to interpret the change and what other keys to expect in the object. The following are the possible edit types:
- `delete`: Remove a GameObject or Component from the scene. Requires the following key:
  - `referenceIdToDelete`: The GUID of the GameObject or Component to delete.
- `createGameObject`: Add a new GameObject to the scene. Requires the following keys:
  - `referenceIdOfParentGameObject`: The GUID of the parent Game Object to create the new Game Object under.
  - `nameOfGameObjectToCreate`: The name of the new Game Object.
  - `referenceIdOfGameObjectToCreate`: A GUID that *you* generate that will be assigned to the new Game Object.
  - `prefabPathForGameObjectToCreate`: The (optional) path to a prefab. If provided, the new Game Object will be instantiated from the prefab. If not provided, an empty Game Object will be created.
- `addComponent`: Add a new Component to a Game Object. Requires the following keys:
  - `referenceIdOfGameObjectToAddComponent`: The GUID of the Game Object to add the new Component to.
  - `componentTypeToAdd`: The type of the Component to add (e.g., UnityEngine.Transform), chosen from the list of available component types in `Temp/Highrise/Serializer/all_component_types.json`.
  - `referenceIdOfComponentToAdd`: A GUID that *you* generate that will be assigned to the new Component.
- `setProperty`: Set the value of a property on a GameObject or Component. Requires the following keys:
  - `referenceIdOfObjectWithPropertyToSet`: The GUID of the GameObject or Component to set the property on.
  - `nameOfPropertyToSet`: The name of the property to set (e.g., position, tag, etc.). **This should already exist in the JSON file; do not invent a new property.**
  - `newPropertyValue`: The value of the property to set.
- `saveObjectAsPrefab`: Save a Game Object as a prefab file for future use. Requires the following keys:
  - `referenceIdOfObjectToSaveAsPrefab`: The GUID of the GameObject to save as a prefab.
  - `pathToSavePrefabAs`: The path to save the prefab as. This should be a relative path from the project root and should not already exist.

You can enqueue multiple edits in a single file, but create the file and write all edits to it in a single transaction. The edits will be applied in the order they are enqueued.

#### Adding components to Game Objects

When you want to add a component to a Game Object, you will need to know the full name of the type of the component you want to add. You can find the list of available component types in `Temp/Highrise/Serializer/all_component_types.json`. **You do not know this list in advance; you will need to read the file to find it.** `all_component_types.json` is structured as follows:
```json
[
  {
    "fullName": "the full name of the component type (e.g., UnityEngine.Transform)",
    "properties": {
      "PROPERTY_NAME (e.g., position)": {
        "propertyName": "the name of the property (e.g., position, rotation, scale, etc.), matching the PROPERTY_NAME key.",
        "type": "the type of the property (e.g., UnityEngine.Vector3, String, etc. If the type is an enum, the full name of the enum will be used, followed by a list of the possible values in parentheses.)"
      }
    }
  }
]
```

If you want to create a Game Object or Component and then set properties on it, you can do this using multiple edits in a single `edit.json` file. After the `createGameObject` or `addComponent` edit, you can add the `setProperty` edit for the new object using the reference ID you generated for `referenceIdOfGameObjectToCreate` or `referenceIdOfComponentToAdd`.

#### Adding Lua script components to Game Objects

When you have a built-in or project-specific Lua script that you want to add to a Game Object, you will create a component as normal following the steps above. The only point to keep in mind is that the `componentTypeToAdd` key will be the name of the script with the prefix `Highrise.Lua.Generated` (e.g., `Highrise.Lua.Generated.MyScript`). Properties on these components will generally be prefixed with `m_` (e.g., `m_MyProperty`).

If you just created the Lua script, **do not attempt to add it to a Game Object yet,** as the generated code will not exist yet. Run a Lua rebuild (see "Triggering a Lua rebuild" below) to generate the code, then add the component to the Game Object.

#### Adding UI components and making them visible

UI components are added by attaching a Lua script component to a Game Object in the scene, like any other component. The UXML and USS will be pulled in automatically at runtime. To make a UI component visible, you must also set the `_uiOutput` property on the component to either "World" (rendering the UI within the world space), "AboveChat" (rendering the UI above the chat), or "Hud" (above everything, like a heads-up display).

## Manipulating the editor

### Focusing the Unity editor

To bring the Unity editor window to the foreground:

**On macOS**, create a `.focus` file in the project root:
```bash
touch .focus
```

**On Windows**, run the PowerShell script from the plugin resources:
```powershell
powershell -ExecutionPolicy Bypass -File "${CLAUDE_PLUGIN_ROOT}/scripts/focus-unity.ps1"
```

This is useful when you need Unity to process pending changes (such as after writing to `edit.json`) or when you want to ensure the user's attention is directed to the editor.

### Starting play mode

To start Unity's play mode:
```bash
touch .focus (or run the PowerShell script above)
touch .play
```

After starting play mode, you should:
1. Sleep for 15 seconds to allow Unity to import assets and enter play mode.
2. Read `console.json` to observe the running session output.
3. Retry up to 3 times (15s intervals) if the console hasn't updated yet.

Notes:
- Play mode (via `.play`) automatically triggers a Lua rebuild before starting, so you don't need to manually rebuild if you're about to enter play mode.
- If play mode is already running, the existing play mode will be stopped before starting the new one.

### Stopping play mode

To stop Unity's play mode:
```bash
touch .focus (or run the PowerShell script above)
touch .stop
```

This is useful when you need to stop play mode to save resources or when you want to ensure the user's attention is directed to the editor. Note that if play mode is not running, the `.stop` file will be silently ignored.

### Triggering a Lua rebuild

Highrise Studio uses Lua scripts for game logic, which must be compiled into C# code before Unity can execute them. When you create or modify Lua scripts, Unity needs to rebuild them to generate the corresponding C# classes. Until this rebuild happens, any new scripts or changes won't be available in the editor (e.g., you won't be able to add a new Lua component to a Game Object).

To trigger a Lua rebuild:
```bash
touch .focus (or run the PowerShell script above)
touch .rebuild
```
You should trigger a Lua rebuild when:
- You've created a new Lua script and need to add it as a component to a Game Object
- You've modified Lua script properties (fields) and need the changes reflected in the editor
- You're seeing errors about missing Lua-generated types

After triggering a Lua rebuild, you should:
1. Wait ~5-10 seconds for compilation.
2. Check `Packages/com.pz.studio.generated/Runtime/Highrise.Lua.Generated/` for the generated wrapper.
3. If the generated wrapper is not found, check the console for errors before retrying.

### Reading the Unity console

Highrise Studio captures Unity console output to a JSON file for debugging and error tracking. You can find the console log at `Temp/Highrise/Serializer/console.json`. The file contains the most recent 500 log entries and is updated every 0.5 seconds when new messages are logged.

The JSON file is structured as an array of log entries:
```json
[
  {
    "message": "the log message text",
    "stackTrace": "the stack trace if available (often empty for simple logs)",
    "logType": "Log | Warning | Error | Assert | Exception | LuaRuntime",  // Logs from Unity use one of the Unity log types; all logs from Lua scripts, whether an error or not, are logged as "LuaRuntime". You should always include "LuaRuntime" in your queries.
    "timestamp": "2024-01-15 14:30:45.123"
  }
]
```

Use this to check for errors, warnings, or debug output when troubleshooting issues. For example, to see the most recent errors:
```bash
jq '[.[] | select(.logType == "Error" or .logType == "Exception" or .logType == "LuaRuntime")] | .[-5:]' Temp/Highrise/Serializer/console.json
```

### Capturing a screenshot
To capture a screenshot of the Unity Game view, focus the window (see "Focusing the Unity editor" above) and then create a `.screenshot` file in the project root:
```bash
touch .focus (or run the PowerShell script above)
touch .screenshot
```

When the `.screenshot` file is detected, a screenshot of the Game view is captured and saved to `Temp/Highrise/Serializer/screenshot.png`

This is useful for visually inspecting the current state of the game, debugging UI layouts, or verifying that changes appear correctly. The screenshot captures whatever is currently visible in the Game view, so ensure the Game view is showing what you want to capture.

# How you should behave

Your goal is to **iterate independently until the user's request is satisfied.** To do this, you will need to follow _all_ of these steps:
1. **Understand how to address the user's request.** Look at documentation, read existing code, and ask the user for necessary information so that you feel prepared to solve the request.
2. **Execute a solution to the user's request.** This may involve writing code and editing the scene or prefabs.
3. **Test the solution.** This may involve reading the console, reading the scene contents, starting play mode, taking screenshots of the game, etc. Do whatever you can to figure out if your solution is working.
4. **If the solution is not working, iterate again.** Go back to step 1 and repeat.