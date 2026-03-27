# Changelog

All notable changes to this plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this plugin adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.14] - 2026-03-27

### Fixed

- Null components are now skipped during serialization to avoid serialization failures.

### Changed

- The `rosie-search-asset-catalog` skill now uses the `sonnet` model.

## [0.5.13] - 2026-03-27

### Added

- New skill: `rosie-search-asset-catalog`, which searches the Highrise Studio Asset Catalog to find and acquire assets.
- New agent: `rosie-layout-mode`, which lays out scenes.
- New agent: `rosie-bugfix-mode`, which fixes a specific bug in the project.

## [0.5.12] - 2026-03-23

### Fixed

- Upload trigger will no longer fail in Studio projects.

## [0.5.11] - 2026-03-18

### Changed

- The plugin hooks will not apply in projects called `life-unity`.

## [0.5.10] - 2026-03-16

### Added

- Lua scripting style guide now notes the max number of local state variables per script.

### Changed

- Codex backend: `AGENTS.md` is now the concatenation of `CLAUDE.md` and `ABOUT_HIGHRISE_STUDIO.md`, not just a pointer to `ABOUT_HIGHRISE_STUDIO.md`.

## [0.5.9] - 2026-03-13

### Fixed

- Rosie's instructions now correctly describe how component and object properties are serialized.

## [0.5.8] - 2026-03-10

### Added

- New trigger: `.upload`, which uploads the world to Highrise.

## [0.5.7] - 2026-03-03

### Fixed

- Some components' properties that write warnings and errors when read outside of runtime are now skipped.

### Changed

- Prefab serialization is now on-demand instead of running on every scene save. Rosie requests specific prefabs by writing `prefab_request.json`, and only those are serialized. Prefabs modified via `edit.json` are automatically re-serialized.

## [0.5.6] - 2026-02-25

### Fixed

- Rosie serialization no longer operates in our local dev environment to avoid a crash.

## [0.5.5] - 2026-02-20

### Changed

- Rosie is now instructed to only trigger editor manipulations (e.g., `.play`, `.stop`, `.rebuild`, `.rebake`) if the user has explicitly asked for them.
- Rebuilds will not fall back to a full asset refresh if they fail.

## [0.5.4] - 2026-02-19

### Changed

- Rosie will add the "read important instructions" line to `CLAUDE.md`, even if the file already exists.

## [0.5.3] - 2026-02-18

### Changed

- Rosie hooks now work in Windows PowerShell.
- Only non-PNG files are cloned from the creator-docs repository.

## [0.5.2] - 2026-02-18

### Fixed

- Properties like `NavMeshAgent.isStopped` that throw when read outside of runtime are now skipped rather than causing serialization failures.

### Changed

- Rosie is now less aggressive in executing tests itself, and instead waits for user confirmation.
- Rosie will now prefer to read the entire `console.json` file rather than just querying for specific log types.

## [0.5.1] - 2026-02-06

### Fixed

- Fields typed as `UnityEngine.Object` can now be serialized and deserialized via a new catch-all `UnityObjectParser`.
- Prefab serialization failures no longer crash the entire scene serialization loop.

## [0.5.0] - 2026-02-05

### Added

- `example-scenes` now includs prefab serializations and scripts that the scenes rely on.
- Added two new scenes to `example-scenes` and an `INDEX.md` file to describe what they contain.

### Fixed

- Rosie no longer serializes the scene when entering or exiting play mode.

### Changed

- Merged the two skills from version 0.4.15 with the `rosie-research-highrise-studio-lua-api` skill into the single `rosie-research-highrise-studio-docs` skill.
- Removed legacy NavMeshBuilder references from `EditorTriggers.cs` to suppress warnings.

## [0.4.15] - 2026-02-02

### Fixed

- When Rosie focuses the Unity editor, it will no longer change the open window.
- Triggering `.play` switches focus to a Simulator, if it exists, or otherwise to the Game view.

## [0.4.14] - 2026-01-30

### Added

- New skill: `rosie-find-existing-lua-solutions`, which looks for solutions in reference files.
- New skill: `rosie-check-example-scenes`, which looks for solutions in reference scene serializations.

### Fixed

- Triggering `.play` during play mode now correctly waits for any existing play mode to fully stop before starting a new one.
- Check for null Unity objects in `SceneWriter.GetId()` to suppress errors for destroyed or unassigned objects.
- Physics materials on colliders are no longer re-instantiated at every serialization.

### Changed

- update-docs.sh will only update the creator-docs repository if it has changed to avoid throttling.
- Testing instructions now discourage pointless screenshotting.
- Scene reading instructions now discourage using stale reference IDs.


## [0.4.13] - 2026-01-27

### Added

- Command to stop play mode.
- update-docs.sh script now adds .claude folder to .gitignore, except for CLAUDE.md.
- `active_scene.json` instructions now specify not to try using the `Read` tool directly.
- `isStatic` and `layer`/`layerName` properties are now serialized to `active_scene.json` and editable.
- Extra instructions to check the console and scene after enqueuing edits.
- Command to rebake lightmaps and NavMesh for the scene.
- Mesh and Material properties are now serializable.

### Changed

- Command to toggle play mode now always starts play mode (stops first if already playing).
- All logs from Lua scripts are now logged as "LuaRuntime" in `console.json`, and agent instructions have been updated to include "LuaRuntime" in their queries.d
- Non-MonoBehaviour components are now serialized to `active_scene.json` and editable.
- Field and Property inclusion rules can now correctly read types when the value is null (e.g., when generating the list of all components and their properties).

## [0.4.12] - 2026-01-22

### Fixed

- Lua VM logs are now captured to `console.json`.

### Changed

- Moved the `write-highrise-studio-lua`, `create-highrise-studio-ui`, and `use-unity-editor` skills into CLAUDE.md so they are always available.
- Removed skill usage checks, since the necessary knowledge is now incorporated into CLAUDE.md.
- Moved the remaining skills out of the plugin itself and into a directory that is copied into `.claude`, since plugin skills do not have `context: fork` enabled.
- `research-highrise-studio-lua-api` and `understand-networked-events` skills now use `context: fork` to execute them in a subagent.

## [0.4.11] - 2026-01-21

### Changed
- The `check-skill-used.sh` script now outputs error messages to stderr instead of stdout.

## [0.4.10] - 2026-01-20

### Added
- New capabilities for the `use-unity-editor` skill:
  - Focusing the Unity editor
  - Toggling play mode
  - Capturing a screenshot of the Unity editor
  - Triggering a Lua rebuild
  - Reading the Unity console
- CLAUDE.md files for working on the plugin.

### Changed
- Serializer scripts are now added via copy instead of symlink.
- Scene now automatically saves after consuming edits via `use-unity-editor`.
- Updated the `update-docs.sh` script to only copy over the creator-docs directory if it's changed.

## [0.4.9] - 2026-01-20

### Changed
- Serializer scripts are now added via hook instead of via the `use-unity-editor` skill.
- Serializer scripts are now added to the project's `Assets/Editor/` folder instead of the `Assets/Scripts/Editor/` folder.

## [0.4.8] - 2026-01-09

### Changed
- Skill use logs are no longer cleared before and after sessions so that they can persist across session resumes.

## [0.4.7] - 2026-01-06

### Fixed
- Skill logging hooks should now work correctly on Git Bash for Windows.

## [0.4.6] - 2025-12-18

### Fixed
- `use-unity-editor` skill: fixed a bug where prefab asset references could not be serialized or edited.

## [0.4.5] - 2025-12-18

### Fixed
- `use-unity-editor` skill: updated instructions to include a step to add the Serializer folder to the project's .gitignore file so that the symlinks are not committed to the repository.

## [0.4.4] - 2025-12-16

### Fixed
- `use-unity-editor` skill: fixed a bug where component properties and fields could not be serialized.
- `use-unity-editor` skill: updated instructions to warn Claude not to attach uncompiled Lua scripts to Game Objects.

## [0.4.3] - 2025-12-15

### Changed
- Initial public release.

## [0.4.2] - 2025-12-12

### Changed
- Fixed the settings.json file's directory permissions after changes to Claude Code's cache directory structure.
- Removed some unnecessary Unity debug logging.

## [0.4.0] - 2025-12-12

### Added
- Prefabs can now be edited using the same editing instructions as the scene.
- The plugin will block accessing certain files until the correct skill has been used.

### Changed
- Properties of Game Objects and Components can now be set at the time they are created.
- Updated some instructions from Drew's feedback.

## [0.3.0] - 2025-12-05

### Added
- Skill for manipulating the contents of the active scene.
- Minor instructions additions.

### Changed
- Renamed plugin to "rosie".
- Moved contents of CLAUDE.md to a separate file in the .claude folder so users can edit their CLAUDE.md file without it being overwritten.

## [0.2.0] - 2025-11-20

### Added
- Skill for writing Highrise Studio UI components.
- Skill for understanding and documenting networked events.
- Warning and instructions if project CLAUDE.md is out of date with the plugin version.

### Changed
- Moved creator-docs repository to the project's .claude folder to fix read permissions issues.

## [0.1.4] - 2025-11-17

### Changed
- Removed need for `/rosie` command to initialize docs and updating via hooks instead. CLAUDE.md and settings.json should now be updated automatically with new package versions.
- Moved creator-docs repository to the plugin root (instead of /tmp/creator-docs).

### Fixed
- Removed `additionalDirectories` from `settings.json` to fix compatibility with Windows.

## [0.1.2] - 2025-11-13

### Added
- Condensed style guide for Lua scripts.
- `write-highrise-studio-lua` skill.
- `research-highrise-studio-lua-api` skill.
- Initial test harness for MacOS.