# Editing scenes and prefabs

Unity's general commands cover most scene editing. A few jobs have no command, or a command that does less than its name suggests. Here is how to do them.

## The sky, ambient light, and fog

`{{RUN}} hr_scene_lighting` reads the active scene's skybox material, ambient light, and fog. Change one at a time with `--name` and `--value`, then save the scene:

```
{{RUN}} hr_scene_lighting --name skybox --value Assets/Sky.mat
{{RUN}} hr_scene_lighting --name ambient_sky_color --value '#5C7A87'
```

## Prefabs

`save_prefab_contents` only renames a prefab's child or turns it on or off. To add or change a prefab's children or components, edit an instance of it in a scene, then push the edits to the prefab with `apply_prefab_overrides --instance <the instance's hierarchy path>`. Every other instance updates. Undo any edits you made to the instance that shouldn't reach the prefab, such as a child you turned on to look at it, before you apply.

## Art from another project

`import_asset` gives the copy a new GUID, which breaks every reference to it: a prefab copied that way loses its sprites and materials. To bring assets over from another Unity project (another world, say), run `{{RUN}} hr_import_from_project --project <its folder> --paths Assets/Art/Trees`. It copies them with their `.meta` files and everything they refer to, keeping their GUIDs, skips what this project already has, and lists what it couldn't copy. Then run `{{RUN}} --wait hr_status`, which waits until the editor has imported them, and check that they arrived with `find_assets`.

## Several edits at once

`batch` runs many commands in one call, and by default undoes them all if one fails. Its own `success` stays true even then. Check each operation's `success`, and `reverted` in the result.

Operations also let you pass an argument the command line can't: `get_serialized_fields` has a `format` argument (`value` returns just the values), but `--format` is the CLI's own option. Pass it in the operation's `params` instead:

```
{{RUN}} batch --operations '[{"command":"get_serialized_fields","params":{"target":"/Board","component":"Transform","format":"value"}}]'
```
