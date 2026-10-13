# Highrise Studio agent guide

This folder is the knowledge an AI agent needs to build Highrise worlds. Highrise Studio serves it to agents through its command line. The agent never reads this repository directly. Studio downloads this folder from `main` and caches it in the project's `Library/`, refreshing it at most hourly. So a change merged here reaches every Studio user within the hour, with no Studio release.

| Command | Serves |
|---------|--------|
| `hr_guide [--topic <name>]` | `topics/<name>.md`. With no topic, `topics/index.md`. |
| `hr_examples_search --query <words>`, `hr_examples_show --path <path>` | Files under `examples/`. |
| `hr_new_script`, `hr_new_ui` | `templates/`. |

The Lua API reference is not here. It ships with Studio, generated from the C# sources, and is served by `hr_docs_search` and `hr_docs_show`.

## Layout contract

Studio's `Highrise.Studio.Agent.AgentGuide` depends on this layout. Renaming or removing any of these paths breaks the Studio versions users already have. Add files freely, but keep the following in place:

- `topics/index.md`: the entry point. Topic names are lowercase words joined by hyphens (`[a-z0-9-]+`).
- `{{RUN}}` in a topic: Studio replaces it with what an agent types to run a Studio command (`unity command --format human`), so write a command as `{{RUN}} hr_status`, and a listing of the commands matching a word as `{{RUN}} --query <word>`.
- `templates/Script.lua`: the Lua script template. `{{TYPE}}` is replaced with the script type (`Client`, `Server`, `ClientAndServer`, or `Module`), and `{{NAME}}` with the script name.
- `templates/UI/UI.lua`, `templates/UI/UI.uxml`, `templates/UI/UI.uss`: the UI component templates. `{{NAME}}` is replaced with the component name.
- The sentence "Only include sections that have something in them." in the Lua templates: Studio warns about scripts that still contain it, to make agents replace the templates' guidance.
- `examples/`: any files. They are searched as plain text.

Studio imports a new script or UI component as soon as it creates it, so the templates must compile and pass Studio's Lua checks (lints and validation) unedited, for every script type. Studio's `AgentGuideTests` check this, and that every example imports without errors. Keep `require` examples commented out, since the modules they name don't exist in a new project. Agents copy the examples too, so keep their scripts passing the same checks (a reference to a script that isn't in `examples/` is fine).

## Writing topics

Agents read guides unreliably, so keep them as rare as possible. Before writing guidance, put the knowledge somewhere an agent can't miss it, in this order of preference:

1. A Studio check that blocks commands when the rule is broken (a Lua lint or a validation rule).
2. A command that does the job correctly.
3. Nowhere, if the agent gets it right without being told.
4. The context where the agent needs it: command help and results, templates, or the Lua API docs (XML comments in Studio's C# sources).
5. A topic, only for knowledge that fits none of the above.

When you do write a topic, write for an agent that knows nothing about Highrise, and say which command to run, as `{{RUN}} <name>`. A command it names must exist in every Studio version that could fetch it; when it depends on a newer command, say which Studio version introduced it.

## Previewing changes

To try content before merging it, set the `HIGHRISE_GUIDE_PATH` environment variable to this folder's absolute path before launching Unity (e.g. launch Unity from a terminal). Studio then reads the files directly and skips the download.
