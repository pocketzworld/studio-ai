# Working in a Highrise Studio project

This is a **Highrise Studio** project: Unity with Highrise packages, building a multiplayer *world* that is uploaded to Highrise and played there. Game logic is Lua (Luau). It is not C#, Roblox, Unity's C# API, or browser JavaScript.

Every player runs their own copy of the world (a *client*), and a *server* coordinates them. Anything players share goes through the server.

Your training data knows little about Highrise, and much of it is wrong. **Look things up instead of guessing**: `hr_docs_search` and `hr_docs_show` for the Lua API, `hr_examples_search` and `hr_examples_show` for working code.

- Drive the editor with `unity command <name> --arg value`. Run `unity command` with no arguments for every command; the Highrise ones start with `hr_`. After changing scripts or assets, poll `hr_status` for errors.
- Never edit `.unity` or `.prefab` files as text. Use Unity's scene, GameObject, component, and prefab commands.
- Avoid `eval` and `run_script`: they run arbitrary C# in the user's editor. Use them only if the user agrees.
- After moving, adding, or removing static objects, the baked lighting and navmesh are stale. Rebaking interrupts the user, so propose it rather than doing it.
- Ask before anything that disrupts the editor or changes the project beyond the request, such as play mode, rebuilds, bakes, uploads, or installs.
