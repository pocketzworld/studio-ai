# Editing scenes and prefabs

Unity's general commands cover most scene editing. A few jobs have no command, or a command that does less than its name suggests. Here is how to do them.

## The sky, ambient light, and fog

`{{RUN}} hr_scene_lighting` reads the active scene's skybox material, ambient light, and fog. Change one at a time with `--name` and `--value`, then save the scene:

```
{{RUN}} hr_scene_lighting --name skybox --value Assets/Sky.mat
{{RUN}} hr_scene_lighting --name ambient_sky_color --value '#5C7A87'
```

## Lua scripts on objects

`{{RUN}} hr_attach` attaches a Lua script to an object, in the scene or in a prefab (which it saves), and sets the script's fields. Don't write a script's component into prefab YAML by hand: it refers to Studio's generated component and to the script by GUIDs. A new script's component exists once `{{RUN}} --wait hr_status` has built it.

```
{{RUN}} hr_attach --script GameManager --target Assets/Board.prefab/Manager
{{RUN}} hr_attach --script ScoreUI --target /Board/ScoreUI --ui_output Hud
{{RUN}} hr_attach --script Launcher --target /Board/Launcher --properties '{"power": 12, "ball": "/Board/Ball"}'
```

If only the last object in the path is missing, `hr_attach` makes it, as `Manager` above. `--properties` names fields as the script declares them, and gives objects and assets as paths: `/Board/Ball` in the scene, `Assets/Board.prefab/Ball` in the prefab being edited, `Assets/Sounds/Coin.asset`. Run it again to change the fields of a script already attached. A UI script needs `--ui_output` to show: `Hud`, `AboveChat`, or `World`.

A ScriptableObject script's data goes in assets. Give `hr_attach` the asset's path: it makes the asset if it's missing (its folder must exist), sets its fields, and saves it. Run it again to change them.

```
{{RUN}} hr_attach --script LevelConfig --target Assets/Data/Level1.asset --properties '{"title": "Forest", "icons": ["Assets/Icons/Tree.png"]}'
```

## Other fields, and saving

`set_serialized_field` sets the fields of Unity's own components and assets. On the command line, give text bare, `--value Forest`: quotes stay part of the text. Numbers, `true` and `false`, and JSON objects and arrays are read as JSON.

Unity's commands leave what they change unsaved in the editor. `save_scene` and `save_all` save scenes but not assets, so an asset changed with `set_serialized_field` or another Unity command isn't on disk until you run `{{RUN}} hr_save`, which saves every changed asset and open scene.

## Prefabs

`save_prefab_contents` only renames a prefab's child or turns it on or off. To attach a Lua script inside a prefab, use `hr_attach`, above. To add or change a prefab's other children or components, edit an instance of it in a scene, then push the edits to the prefab with `apply_prefab_overrides --instance <the instance's hierarchy path>`. Every other instance updates. Undo any edits you made to the instance that shouldn't reach the prefab, such as a child you turned on to look at it, before you apply.

## Art from another project

`import_asset` gives the copy a new GUID, which breaks every reference to it: a prefab copied that way loses its sprites and materials. To bring assets over from another Unity project (another world, say), run `{{RUN}} hr_import_from_project --project <its folder> --paths Assets/Art/Trees`. It copies them with their `.meta` files and everything they refer to, keeping their GUIDs, skips what this project already has, and lists what it couldn't copy. Then run `{{RUN}} --wait hr_status`, which waits until the editor has imported them, and check that they arrived with `find_assets`.

## Several edits at once

`batch` runs many commands in one call, and by default undoes them all if one fails. Its own `success` stays true even then. Check each operation's `success`, and `reverted` in the result.

Operations also let you pass an argument the command line can't: `get_serialized_fields` has a `format` argument (`value` returns just the values), but `--format` is the CLI's own option. Pass it in the operation's `params` instead:

```
{{RUN}} batch --operations '[{"command":"get_serialized_fields","params":{"target":"/Board","component":"Transform","format":"value"}}]'
```
