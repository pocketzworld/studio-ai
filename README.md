# studio-ai

A Claude Code plugin for studio-ai.

## Installation

To install this plugin in Claude Code:

1. Clone this repository
2. Add the plugin path to your Claude Code configuration:
   ```bash
   claude-code plugins add /path/to/studio-ai
   ```

Or install from a marketplace:
```bash
claude-code plugins add github:yourusername/studio-ai
```

## Features

### Commands
- Custom slash commands for specific workflows

### Agents
- Specialized agents for domain-specific tasks

### Skills
- Reusable capabilities for agents

## Development

This plugin follows the [Claude Code plugin structure](https://docs.claude.com/en/docs/claude-code/plugins.md).

### Directory Structure
```
studio-ai/
├── .claude-plugin/
│   └── plugin.json      # Plugin manifest
├── commands/            # Slash commands
├── agents/              # Custom agents
├── skills/              # Agent skills
└── README.md
```

## License

MIT
