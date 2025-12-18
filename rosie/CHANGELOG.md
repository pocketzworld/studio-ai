# Changelog

All notable changes to this plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this plugin adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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