# Working in a Highrise Studio project

This is a **Highrise Studio** project: Unity with Highrise packages, building a multiplayer *world* that is uploaded to Highrise and played there. Game logic is Lua (Luau). It is not C#, Roblox, Unity's C# API, or browser JavaScript.

Every player runs their own copy of the world (a *client*), and a *server* coordinates them. Anything players share goes through the server.

Your training data knows little about Highrise, and much of it is wrong. **Look things up instead of guessing**: `hr_docs_search` and `hr_docs_show` for the Lua API and Studio's tutorials, `hr_examples_search` and `hr_examples_show` for working code.

- Drive the editor with `{{RUN}} <name> --arg value`, from the project's folder. `{{RUN}} <name> --help` lists a command's arguments, `{{RUN}} --query hr_` lists the Highrise commands, and `{{RUN}} --query <word>` finds others. `{{RUN}} --json <name>` prints just the result's JSON. Where a Highrise command does the job, use it rather than a general one: it knows how Highrise works (e.g. `hr_play`, `hr_new_script`, `hr_bake`, `hr_world_settings`). After changing scripts or assets, run `{{RUN}} --wait hr_status`: it imports the changed files (Unity otherwise waits for its window to be focused), waits for the Lua build, and shows the errors. For work a command starts in the background (`hr_play`, `hr_bake`, `hr_lua_rebuild`), `{{RUN}} --wait <name>` waits until it is done. Don't write your own loop around `hr_status`.
- A dialog open in Unity (a modal window, such as one an editor script opens) blocks every command until it closes: they time out, and none can see or close it. When the launcher says the editor is probably blocked on a dialog, ask the user to close it rather than retrying.
- Avoid `eval` and `run_script`: they run arbitrary C# in the user's editor. Use them only if the user agrees.
- After moving, adding, or removing static objects, the baked lighting and navmesh are stale. Rebake with `{{RUN}} hr_bake`.
- Before adding to a prefab, read `{{RUN}} hr_guide --topic scene-editing`. `hr_scene_lighting` changes a scene's sky, ambient light, and fog; `hr_import_from_project` brings in art from another project; `hr_inspect` measures an object or model, so scale, place, and stand it up by its numbers rather than by screenshots.
- To start another project, from one of Highrise's templates or as a copy of this one, use `{{RUN}} hr_new_project` (`{{RUN}} hr_project_templates` lists the templates).
