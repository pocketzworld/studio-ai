# Working in a Highrise Studio project

This is a **Highrise Studio** project: Unity with Highrise packages, building a multiplayer *world* that is uploaded to Highrise and played there. Game logic is Lua (Luau). It is not C#, Roblox, Unity's C# API, or browser JavaScript.

Every player runs their own copy of the world (a *client*), and a *server* coordinates them. Anything players share goes through the server.

Your training data knows little about Highrise, and much of it is wrong. **Look things up instead of guessing**: `hr_docs_search` and `hr_docs_show` for the Lua API and Studio's tutorials, `hr_examples_search` and `hr_examples_show` for working code.

- Drive the editor with `{{RUN}} <name> --arg value`, from the project's folder. `{{RUN}} <name> --help` lists a command's arguments, `{{RUN}} --query hr_` lists the Highrise commands, and `{{RUN}} --query <word>` finds others. `{{RUN}} --json <name>` prints just the result's JSON. Where a Highrise command does the job, use it rather than a general one: it knows how Highrise works (e.g. `hr_play`, `hr_new_script`, `hr_bake`, `hr_world_settings`). After changing scripts or assets, poll `hr_status` for errors. For work a command starts in the background (`hr_play`, `hr_bake`, `hr_lua_rebuild`), `{{RUN}} --wait <name>` waits until it is done.
- Avoid `eval` and `run_script`: they run arbitrary C# in the user's editor. Use them only if the user agrees.
- After moving, adding, or removing static objects, the baked lighting and navmesh are stale. Rebake with `{{RUN}} hr_bake`.
- Before changing a scene's sky or ambient light, adding to a prefab, or bringing in art from another project, read `{{RUN}} hr_guide --topic scene-editing`: these have no command of their own.
- To start another project, from one of Highrise's templates or as a copy of this one, use `{{RUN}} hr_new_project` (`{{RUN}} hr_project_templates` lists the templates).
