# Changelog

All notable changes to this plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this plugin adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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