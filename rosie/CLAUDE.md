# Rosie Plugin

A Claude Code plugin that transforms Claude into a Highrise Studio expert, enabling developers to build multiplayer worlds in Highrise Studio.

## Project Structure

```
rosie/
├── .claude-plugin/plugin.json    # Plugin metadata and version
├── hooks/hooks.json              # Event hook definitions
├── scripts/                      # Hook scripts
│   └── claude-docs/              # Docs synced to user projects. Also contains the ABOUT_HIGHRISE_STUDIO.md file, which you can use to understand Highrise Studio
├── skills/                       # Claude Code skills
│   ├── research-highrise-studio-docs/
│   └── understand-networked-events/
└── tests/                        # Test harness and scenarios
```

## Skills

| Skill | Purpose |
|-------|---------|
| `research-highrise-studio-docs` | Query Highrise Studio API docs and example scenes |
| `understand-networked-events` | Debug networked event flows |

Each skill has a `SKILL.md` file with instructions and a `resources/` folder with templates and guides.

## Hook System

Defined in `hooks/hooks.json`:

- **SessionStart**: Version check, Serializer copy setup
- **SessionEnd**: Sync docs to user projects

## Development

- Track all changes in the `[Unreleased]` section of `CHANGELOG.md` as they are implemented
- Always bump the version number in `.claude-plugin/plugin.json` when releasing a new version
- Update this `CLAUDE.md` file when you make changes that affect future development of the plugin

## Notes

- Hook scripts must handle both macOS and Windows (Git Bash)
- Skill logging uses session ID from `$CLAUDE_CODE_SESSION_ID` env var
- Serializer C# scripts are symlinked to `Assets/Editor/` in user projects
- Unity scene/prefab edits go through JSON serialization in `Temp/Highrise/Serializer/`
