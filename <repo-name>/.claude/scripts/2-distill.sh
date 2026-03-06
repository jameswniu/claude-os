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
    SLUG=$(echo "$MEMORY_DIR" | sed 's|.*/projects/||; s|/memory.*||')
    PROJECT_DIR=$(python3 -c "
import json, os
slug = '$SLUG'
with open(os.path.expanduser('~/.claude/history.jsonl')) as f:
    for line in f:
        try:
            proj = json.loads(line.strip()).get('project', '')
            if proj and proj.replace('/', '-').replace('.', '-') == slug:
                print(proj)
                break
        except:
            pass
" 2>/dev/null)
    if [ -z "$PROJECT_DIR" ]; then
        echo "$(date): [$SLUG] Could not resolve project directory, skipping" >> "$LOG_DIR/2-distill.log"
        continue
    fi

    echo "$(date): [$PROJECT_DIR] Starting distill..." >> "$LOG_DIR/2-distill.log"

    # Archive entries older than 30 days to keep logs.md bounded
    ARCHIVE_DIR="$MEMORY_DIR/history/archive"
    CUTOFF_30D=$(date -v-30d +%Y-%m-%d)
    python3 -c '
import sys, os
from datetime import datetime
logs_path, archive_dir, cutoff = sys.argv[1], sys.argv[2], sys.argv[3]
os.makedirs(archive_dir, exist_ok=True)
if not os.path.exists(logs_path):
    sys.exit(0)
with open(logs_path) as f:
    lines = f.read().split("\n")
current_date = None
sections = []
header = []
for line in lines:
    if line.startswith("## ") and len(line) >= 13:
        d = line[3:13]
        try:
            datetime.strptime(d, "%Y-%m-%d")
            current_date = d
            sections.append((d, [line]))
            continue
        except ValueError:
            pass
    if current_date is None:
        header.append(line)
    else:
        sections[-1][1].append(line)
keep, archive = [], {}
for d, sec in sections:
    if d >= cutoff:
        keep.append(sec)
    else:
        archive.setdefault(d[:7], []).extend(sec)
for month, month_lines in archive.items():
    path = os.path.join(archive_dir, month + ".md")
    with open(path, "a") as f:
        f.write("\n".join(month_lines) + "\n\n")
if archive:
    with open(logs_path, "w") as f:
        f.write("\n".join(header))
        for sec in keep:
            f.write("\n" + "\n".join(sec))
        f.write("\n")
    print("Archived " + str(len(archive)) + " month(s)")
' "$MEMORY_DIR/history/logs.md" "$ARCHIVE_DIR" "$CUTOFF_30D" 2>/dev/null
    echo "$(date): [$PROJECT_DIR] Archival step done" >> "$LOG_DIR/2-distill.log"

    # Pre-extract last 3 days of logs to avoid agent reading full file (cost cap)
    THREE_DAYS_AGO=$(date -v-3d +%Y-%m-%d)
    RECENT_LOGS=$(awk -v cutoff="$THREE_DAYS_AGO" '
        /^## [0-9]{4}-[0-9]{2}-[0-9]{2}/ { date = substr($0, 4, 10); show = (date >= cutoff) }
        show { print }
    ' "$MEMORY_DIR/history/logs.md" 2>/dev/null || echo "")

    (
        cd "$PROJECT_DIR" || exit 1
        unset CLAUDECODE

        MEMORY_LINES=$(wc -l < "$MEMORY_DIR/MEMORY.md")
        claude -p "You are a memory distiller. Read the file at $MEMORY_DIR/MEMORY.md (topical patterns).

Here are the recent log entries from the last 3 days:
$RECENT_LOGS

Your job:
- Identify any NEW patterns, facts, or learnings not already in MEMORY.md
- Update MEMORY.md by adding new entries under the appropriate topic section
- If a new topic is needed, create a section for it
- Do NOT delete existing entries unless they are contradicted by newer data
- Do NOT add duplicate information
- The '## Topic Files' section entries are managed by sync scripts. Do not add or remove entries there.
- MEMORY.md is currently $MEMORY_LINES lines (hard limit: 200). If over 170 lines, move the largest non-essential section to its own topic file in the same directory and replace with a 1-line pointer.
- Keep MEMORY.md under 200 lines total

Output what you changed." \
          --allowedTools "Read,Edit" \
          --permission-mode bypassPermissions \
          --max-budget-usd 0.50 \
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
