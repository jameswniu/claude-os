#!/bin/bash
# 2-distill.sh — Runs every 8 hours (test) / daily (prod)
# Reads recent log entries and distills patterns into MEMORY.md

LOG_DIR="$HOME/claude-os/output"

# Use MEMORY_FILE if passed (e.g. from launchd), otherwise auto-detect
MEMORY_FILE="${MEMORY_FILE:-$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null | head -1)}"
if [ -z "$MEMORY_FILE" ]; then
    echo "$(date): No MEMORY.md found, skipping" >> "$LOG_DIR/2-distill.log"
    exit 0
fi
MEMORY_DIR=$(dirname "$MEMORY_FILE")
PROJECT_DIR=$(echo "$MEMORY_DIR" | sed 's|.*/projects/||; s|/memory||; s|-|/|g; s|^/||')

mkdir -p "$LOG_DIR"

echo "$(date): Starting distill..." >> "$LOG_DIR/2-distill.log"

cd "$PROJECT_DIR"
unset CLAUDECODE

(claude -p "You are a memory distiller. Read both files:
1. $MEMORY_DIR/history/logs.md (session history)
2. $MEMORY_DIR/MEMORY.md (topical patterns)

Your job:
- Look at log entries from the last 3 days
- Identify any NEW patterns, facts, or learnings not already in MEMORY.md
- Update MEMORY.md by adding new entries under the appropriate topic section
- If a new topic is needed, create a section for it
- Do NOT delete existing entries unless they are contradicted by newer data
- Do NOT add duplicate information
- Keep MEMORY.md under 200 lines total

Output what you changed." \
  --allowedTools "Read,Edit" \
  --permission-mode bypassPermissions \
  --max-budget-usd 0.25 \
  < /dev/null) >> "$LOG_DIR/2-distill.log" 2>&1

echo "$(date): Distill complete" >> "$LOG_DIR/2-distill.log"
