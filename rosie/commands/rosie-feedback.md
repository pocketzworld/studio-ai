---
description: Send feedback about Rosie to the development team.
allowed-tools: Bash
---

# Send Rosie Feedback

The user wants to send feedback about Rosie. Run the feedback script to collect context and send it to the development team.

Execute the following command with the user's feedback message as the argument. Set the CLAUDE_MODEL environment variable to your current model ID (e.g., claude-opus-4-5-20251101):

```bash
CLAUDE_MODEL="<your-model-id>" bash "${CLAUDE_PLUGIN_ROOT}/scripts/send-feedback.sh" "$ARGUMENTS"
```

After running the command, confirm to the user that their feedback has been sent.

