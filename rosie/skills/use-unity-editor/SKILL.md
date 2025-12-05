---
name: use-unity-editor
description: Read and edit scenes as you would in the Unity editor. You can't do anything in the Unity editor without this skill.
---

# Use Highrise Studio's Unity Editor

Highrise Studio is built on Unity, and uses a variant of the Unity editor to edit scenes. This guide covers how you can read and edit scenes as a user would in the Unity editor.

## Important information

### Reading the scene

Highrise Studio serializes the active scene to a JSON file for easier understanding. You can find the JSON file at `Temp/Highrise/Serializer/active_scene.json`. The JSON file should be up-to-date with the scene's current state.

The JSON file contains the scene's entire Game Object hierarchy. There will be a single top-level object called "SceneRoot", whose children are the root Game Objects in the scene. The JSON file is structured as follows:
```json
{
  "referenceId": "a GUID that uniquely identifies this Game Object within the scene. Not persistent across editor reloads.",
  "objectProperties": {
    "name": "the name of the game object, as it appears in the hierarchy.",
    "activeSelf": "whether the Game Object is enabled.",
    "tag": "the Game Object's tag.",
    "parentGameObject": "the GUID of the parent Game Object, or null if this is a root Game Object.",
  },
  "components": [
    {
      "componentType": "the type of the component (e.g., UnityEngine.Transform)",
      "referenceId": "a GUID that uniquely identifies this component within the scene. Not persistent across editor reloads.",
      "componentProperties": {
        "PROPERTY_NAME (e.g., position)": {
          "propertyName": "the name of the property (e.g., position, rotation, scale, etc.), matching the PROPERTY_NAME key.",
          "type": "the type of the property (e.g., UnityEngine.Vector3, String, etc.)",
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
  "value": "the GUID of the referenced Game Object or Component."
}
```

### Editing the scene

**Do not modify the active_scene.json file directly; this will not do anything.** Instead, you will submit a queue of changes to be applied to the scene in a file you will create called `Temp/Highrise/Serializer/edit.json`. The file consists of an array of objects. Each object is required to have an `editType` key, which will determine how to interpret the change and what other keys to expect in the object. The following are the possible edit types:
- `delete`: Remove a GameObject or Component from the scene. Requires the following key:
  - `referenceIdToDelete`: The GUID of the GameObject or Component to delete.
- `createGameObject`: Add a new GameObject to the scene. Requires the following keys:
  - `referenceIdOfParentGameObject`: The GUID of the parent Game Object to create the new Game Object under.
  - `nameOfGameObjectToCreate`: The name of the new Game Object.
- `addComponent`: Add a new Component to a Game Object. Requires the following keys:
  - `referenceIdOfGameObjectToAddComponent`: The GUID of the Game Object to add the new Component to.
  - `componentTypeToAdd`: The type of the Component to add (e.g., UnityEngine.Transform). The full list of available component types is available in `Temp/Highrise/Serializer/all_component_types.json`. **You do not know this list in advance; you will need to read the file to find it.**
- `setProperty`: Set the value of a property on a GameObject or Component. Requires the following keys:
  - `referenceIdOfObjectWithPropertyToSet`: The GUID of the GameObject or Component to set the property on.
  - `nameOfPropertyToSet`: The name of the property to set (e.g., position, tag, etc.). **This should already exist in the JSON file; do not invent a new property.**
  - `newPropertyValue`: The value of the property to set.

You can enqueue multiple edits in a single file, but create the file and write all edits to it in a single transaction. The edits will be applied in the order they are enqueued.

If you want to create a Game Object or Component and then set properties on it, do this in two separate edits, since you will not know the reference ID of the new object until it is created. Specifically:
1. Write the `createGameObject` or `addComponent` edit.
2. Ask the user to interact with their editor so that it serializes the edited scene.
3. Read the JSON file to get the reference ID of the new object.
4. Write the `setProperty` edit for the new object.

#### Adding Lua script components to Game Objects

When you have a built-in or project-specific Lua script that you want to add to a Game Object, you will create a component as normal following the steps above. The only point to keep in mind is that the `componentTypeToAdd` key will be the name of the script with the prefix `Highrise.Lua.Generated` (e.g., `Highrise.Lua.Generated.MyScript`). Properties on these components will generally be prefixed with `m_` (e.g., `m_MyProperty`).

## Instructions

Add the following steps to your todo list:
1. Check that `Temp/Highrise/Serializer/active_scene.json` exists. If it does not, follow these steps:
   a. Check whether the user has the required editor scripts in their project. Look in `Assets/Scripts/Editor` for the `Serializer` folder. If it does not exist or is empty, ask the user for permission to symlink that folder from this plugin's `resources/Serializer` folder.
   b. If the user has the required editor scripts, ask them to turn on JSON serialization in the Unity toolbar, under Highrise > Studio.
2. Use your tools (`jq`, `grep`, etc.) to read the relevant parts of the JSON file. For example, to list the names of the root Game Objects in the scene, you can use the following command: `jq -r '.SceneRoot.children[].properties.name' Temp/Highrise/Serializer/active_scene.json`. Do not make any changes to the JSON file.
3. If needed, create the `Temp/Highrise/Serializer/edit.json` file and write the edits to it.
4. Inform the user that edits have been submitted and will be applied when they interact with their editor.