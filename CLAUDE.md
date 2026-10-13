# studio-ai

What AI agents need to build Highrise worlds in Highrise Studio. The main part is the agent guide in `guide/`, which Studio serves to any agent through its commands (`hr_guide`, `hr_examples_*`, and the script and UI templates). Put new agent guidance there, following `guide/README.md`, rather than in the Rosie plugin.

This repository is public. Keep internal plans, unreleased projects and internal names out of its files and commit messages.

## Subprojects

- [guide/README.md](guide/README.md) - The agent guide. Studio downloads this folder from `main`, so follow its layout contract.
- [rosie/CLAUDE.md](rosie/CLAUDE.md) - Rosie, the earlier Claude Code plugin for Highrise Studio, kept for its existing users.
