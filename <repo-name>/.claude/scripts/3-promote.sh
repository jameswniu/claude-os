#!/bin/bash
# 3-promote.sh — Runs every ~2.3 days (test) / weekly (prod)
# Reads MEMORY.md for stable patterns and promotes them to .claude/CLAUDE.md
# Loops over all projects with a MEMORY.md

LOG_DIR="$HOME/claude-os/output"

mkdir -p "$LOG_DIR"

# Find all project MEMORY.md files
MEMORY_FILES=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null)
if [ -z "$MEMORY_FILES" ]; then
    echo "$(date): No MEMORY.md files found, skipping" >> "$LOG_DIR/3-promote.log"
    exit 0
fi

ERRORS=0

while IFS= read -r MEMORY_FILE; do
    MEMORY_DIR=$(dirname "$MEMORY_FILE")
    PROJECT_DIR=$(echo "$MEMORY_DIR" | sed 's|.*/projects/||; s|/memory||; s|-|/|g; s|^/||')
    CLAUDE_MD="/$PROJECT_DIR/.claude/CLAUDE.md"

    echo "$(date): [$PROJECT_DIR] Starting promote..." >> "$LOG_DIR/3-promote.log"

    (
        cd "$PROJECT_DIR" || exit 1
        unset CLAUDECODE

        claude -p "You are a rule promoter. Read both files:
1. $MEMORY_DIR/MEMORY.md (learned patterns)
2. $CLAUDE_MD (current personal rules)

Your job:
- Look for patterns in MEMORY.md that are stable and recurring (appeared 3+ times or confirmed across multiple sessions)
- Check if these patterns are already captured as rules in .claude/CLAUDE.md
- If a pattern is stable but NOT yet a rule, add it to the appropriate section in .claude/CLAUDE.md
- If a pattern contradicts an existing rule, flag it but do NOT change the rule (leave a comment in your output)
- Do NOT remove existing rules
- Do NOT add speculative or single-occurrence patterns
- Keep .claude/CLAUDE.md concise and actionable

Output what you promoted (or 'No new promotions' if nothing qualified)." \
          --allowedTools "Read,Edit" \
          --permission-mode bypassPermissions \
          --max-budget-usd 0.25 \
          < /dev/null
    ) >> "$LOG_DIR/3-promote.log" 2>&1

    if [ $? -ne 0 ]; then
        echo "$(date): [$PROJECT_DIR] ERROR: promote failed (exit code $?)" >> "$LOG_DIR/3-promote.log"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    echo "$(date): [$PROJECT_DIR] Promote complete" >> "$LOG_DIR/3-promote.log"

done <<< "$MEMORY_FILES"

if [ "$ERRORS" -gt 0 ]; then
    echo "$(date): Finished with $ERRORS error(s)" >> "$LOG_DIR/3-promote.log"
    exit 1
fi
