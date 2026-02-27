# Using Bash Mode

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1588723799

Say you need to run a command, and that command results in an error. You want AI (Claude Code or Copilot CLI) to help you troubleshoot the error, so you want the AI to see the output of that command. You have 3 options in order of least efficient to most efficient:

### 1. Paste the output into the AI (least efficient)

Run the command in your terminal, copy the output, paste it into the AI. It works, but it's cumbersome.

### 2. Ask the AI to run the command (medium efficiency)

The AI reasons about your request and asks for confirmation. It may misinterpret what the command is. Say you wanted it to run `bundle install` safely. How does it know whether `safely` is part of the command or an instruction to be careful?

### 3. Run the command in the AI's context using Bash mode (most efficient)

Using the `!` shortcut (Claude Code, GitHub Copilot CLI) you can enable Bash mode, which lets you run commands directly within the AI's context.

1. Run the exact command you want
2. Review the output. If successful, you're done
3. If there's a failure, ask the AI to investigate with a simple "fix" prompt

This also lets you run multiple commands in sequence. When you encounter an error, then engage the AI to resolve it.
