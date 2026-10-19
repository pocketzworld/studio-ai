# Highrise Studio agent guide (retired)

The agent guide now ships with Highrise Studio, so it always matches the commands of the Studio that serves it. Change it there, not here.

Earlier Studio versions still download this folder from `main` and serve it through `hr_guide`, `hr_examples_*`, `hr_new_script` and `hr_new_ui`. It stays for them:

- `topics/`: each topic those versions knew tells the agent to have the user update Studio. `{{RUN}}` is replaced with the command an agent types to run a Studio command.
- `templates/`: kept unchanged, because those versions create every new Lua script and UI component from them.
- `examples/`: removed. Those versions' example search finds nothing.

Keep these paths in place, and don't add guidance here.
