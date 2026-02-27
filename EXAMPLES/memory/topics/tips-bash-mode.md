# 01/26/2026 Using Bash mode

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1588723799


Say you need to run a command, and that command results in an error. You want AI (Claude Code or Copilot CLI) to help you troubleshoot the error, so you want the AI to see the output of that command. You have 3 options in order of least efficient to most efficient:

### 1. You can run the command in your terminal and paste the output into the AI (least efficient) 

then paste:

It works, but it's cumbersome.

### 2. You can ask the AI to run the specific command (medium efficiency)

However, doing this requires the AI to reason about your request and ask for confirmation to run the command.

It may also misinterpret what the command is based on your prompt. Say you wanted it to run `bundle install` safely. You give it the following prompt `run bundle install safely`. How does it know whether `safely` should be part of the bundle install command (ex. `bundle install safely`), or if you're telling it you want it to be careful how it runs the command? There's a use-case for being able to run exactly the command you want to run.

### 3. You can run the specific command in the AI's context using _Bash mode_ (most efficient)

Using the `!` Shortcut ([Claude Code](https://code.claude.com/docs/en/interactive-mode#quick-commands), [Github Copilot CLI](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli#run-shell-commands)) you can enable _Bash mode,_ which lets you run commands directly within the AI's context.

  1. You are able to run the exact command you want to run

  2. Review the output. If successful, then you're done

  3. If there's a failure, you can then ask the AI to investigate it with a simple "fix" prompt. "fix" is not a special keyword; any natural language way of asking it to solve the issue should work.

This also allows you to efficiently run multiple commands in sequence without errors. When you encounter an error, then engage the AI to help you resolve it:

With [method #2](https://basis.atlassian.net/wiki/spaces/BET/pages/1588723799/01+26+2026+Using+Bash+mode#2.-You-can-ask-the-AI-to-run-the-specific-command-\(medium\)), you would engage the AI after every command, even if there is no issue which in some cases is not as efficient:

### With GitHub Copilot CLI

The above examples are done with Claude Code. The feature works similarly with GitHub Copilot CLI, with one limitation: it doesn't see the output of the executed commands automatically, so copying and pasting the error message is required:

### With VSCode Github Copilot

The `runInTerminal` command provides similar functionality, but it always runs the output through the model. It is still useful for many use cases, but gives the user less control over when to engage the AI.

