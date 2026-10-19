# Update Highrise Studio

This project's Highrise Studio is out of date. The agent guide now ships with Studio, and this version of Studio downloads an old copy that is no longer kept up to date: what it said may not match the commands you have.

Ask the user to update Highrise Studio (the `com.pz.studio` package) in this project to its latest version. After the update, `{{RUN}} hr_guide` serves the guide that matches it.

Until then, `{{RUN}} --query hr_` lists Studio's commands, `{{RUN}} <name> --help` explains one, and `hr_docs_search` and `hr_docs_show` serve the Lua API docs.
