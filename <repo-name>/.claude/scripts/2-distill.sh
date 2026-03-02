#!/bin/bash
# 2-distill.sh — Runs every 8 hours (test) / daily (prod)
# Reads recent log entries and distills patterns into MEMORY.md
# Loops over all projects with a MEMORY.md

LOG_DIR="$HOME/claude-os/output"

mkdir -p "$LOG_DIR"

# Find all project MEMORY.md files
MEMORY_FILES=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null)
if [ -z "$MEMORY_FILES" ]; then
    echo "$(date): No MEMORY.md files found, skipping" >> "$LOG_DIR/2-distill.log"
    exit 0
fi

ERRORS=0

while IFS= read -r MEMORY_FILE; do
    MEMORY_DIR=$(dirname "$MEMORY_FILE")
    PROJECT_DIR=$(echo "$MEMORY_DIR" | sed 's|.*/projects/||; s|/memory||; s|-|/|g; s|^/||')

    echo "$(date): [$PROJECT_DIR] Starting distill..." >> "$LOG_DIR/2-distill.log"

    (
        cd "$PROJECT_DIR" || exit 1
        unset CLAUDECODE

        claude -p "You are a memory distiller. Read both files:
1. $MEMORY_DIR/history/logs.md (session history)
2. $MEMORY_DIR/MEMORY.md (topical patterns)

Your job:
- Look at log entries from the last 3 days
- Identify any NEW patterns, facts, or learnings not already in MEMORY.md
- Update MEMORY.md by adding new entries under the appropriate topic section
- If a new topic is needed, create a section for it
- Do NOT delete existing entries unless they are contradicted by newer data
- Do NOT add duplicate information
- Do NOT remove or modify entries in the '## Topic Files' section — these are managed by sync scripts
- Keep MEMORY.md under 200 lines total

Output what you changed." \
          --allowedTools "Read,Edit" \
          --permission-mode bypassPermissions \
          --max-budget-usd 0.25 \
          < /dev/null
    ) >> "$LOG_DIR/2-distill.log" 2>&1

    if [ $? -ne 0 ]; then
        echo "$(date): [$PROJECT_DIR] ERROR: distill failed (exit code $?)" >> "$LOG_DIR/2-distill.log"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    echo "$(date): [$PROJECT_DIR] Distill complete" >> "$LOG_DIR/2-distill.log"

done <<< "$MEMORY_FILES"

if [ "$ERRORS" -gt 0 ]; then
    echo "$(date): Finished with $ERRORS error(s)" >> "$LOG_DIR/2-distill.log"
    exit 1
fi
