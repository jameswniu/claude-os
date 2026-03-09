# 03/05/2026 Claude Code with Chrome

Source: (internal URL)

<https://code.claude.com/docs/en/chrome>

Claude Code has a built-in browser tool that lets it open Chrome, take screenshots, read console errors, and interact with pages, all from your terminal.

#### You can either enable it in each Claude session by starting Claude with

wide760

#### You can also enable it by default using the `/chrome` command and setting `Enabled by default:` to `Yes`

This will eliminate the need to pass `--chrome` when starting every session.

### How to use it

To verify it works, start Claude Code and prompt it to do something in your browser; it will automatically know when to use it based on your prompt.

For example:

wide760

A window should pop up asking for permission to complete the requested task:

Be very careful with this tool; providing it access to websites with your signed-in accounts can be risky
