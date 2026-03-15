#!/bin/bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

[ -z "$CMD" ] && exit 0

# Block rm commands that target .claude/ paths
if echo "$CMD" | grep -qE '(^|\s)(rm|git\s+clean|git\s+rm)\s' && echo "$CMD" | grep -qE '\.claude(/|$|\s|")'; then
  echo "Blocked: command targets .claude/ directory. This directory contains Claude Code config and must not be deleted." >&2
  exit 2
fi

# Block git checkout --orphan (which wipes the working tree including .claude/)
# Only block when git checkout --orphan is the actual command (not inside grep/echo/python args)
if echo "$CMD" | grep -qE '^(git[[:space:]]+checkout[[:space:]]+--orphan|.*\|[[:space:]]*git[[:space:]]+checkout[[:space:]]+--orphan)'; then
  echo "Blocked: git checkout --orphan wipes the working tree (including .claude/). Use git worktree instead." >&2
  exit 2
fi

exit 0
