# Editing scenes and prefabs

Unity's general commands cover most scene editing. A few jobs have no command, or a command that does less than its name suggests. Here is how to do them.

## The sky, ambient light, and fog

A scene's skybox material, ambient light, and fog are its RenderSettings, which no command names. Read and set them with `get_serialized_fields` and `set_serialized_field`. The target is the scene's RenderSettings object, whose global ID is `GlobalObjectId_V1-2-<scene GUID>-2-0`. Take the scene GUID from any object in that scene: it is the third part of the object's `globalId`, e.g. `GlobalObjectId_V1-2-3d97b014f52721147ba461f2a8133078-...`.

```
{{RUN}} get_serialized_fields --target '{"globalId":"GlobalObjectId_V1-2-<scene GUID>-2-0"}'
{{RUN}} set_serialized_field --target '{"globalId":"GlobalObjectId_V1-2-<scene GUID>-2-0"}' --field m_SkyboxMaterial --value '{"path":"Assets/Sky.mat"}'
{{RUN}} set_serialized_field --target '{"globalId":"GlobalObjectId_V1-2-<scene GUID>-2-0"}' --field m_AmbientSkyColor --value '{"r":0.36,"g":0.48,"b":0.53,"a":1}'
```

`get_serialized_fields` has a `format` argument that the command line can't pass, because `--format` is the CLI's own option. Leave it out.

## Prefabs

`save_prefab_contents` only renames a prefab's child or turns it on or off. To add or change a prefab's children or components, edit an instance of it in a scene, then push the edits to the prefab with `apply_prefab_overrides --instance <the instance's hierarchy path>`. Every other instance updates. Undo any edits you made to the instance that shouldn't reach the prefab, such as a child you turned on to look at it, before you apply.

## Art from another project

`import_asset` gives the copy a new GUID, which breaks every reference to it: a prefab copied that way loses its sprites and materials. To bring assets over from another Unity project (another world, say), copy the files together with their `.meta` files into this project's `Assets/` folder, and include what they depend on. A dependency is any `guid:` in a prefab, material, or scene that isn't already in this project. Then poll `{{RUN}} hr_status` until `busy` is empty so the editor imports them, and check that they arrived with `find_assets`.

## Several edits at once

`batch` runs many commands in one call, and by default undoes them all if one fails. Its own `success` stays true even then. Check each operation's `success`, and `reverted` in the result.
