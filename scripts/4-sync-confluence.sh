#!/bin/bash
# 4-sync-confluence.sh — Runs every 24 hours
# Re-fetches registered Confluence pages into topic files in the memory directory

MEMORY_DIR="/Users/james.niu/.claude/projects/-Users-james-niu-media-strategy-generator/memory"
LOG_DIR="/Users/james.niu/scripts/claude-memory/output"
CONFLUENCE_BASE="https://basis.atlassian.net/wiki/rest/api/content"

mkdir -p "$LOG_DIR"

# Auth: reads from environment variables CONFLUENCE_EMAIL and CONFLUENCE_TOKEN
if [ -z "$CONFLUENCE_EMAIL" ] || [ -z "$CONFLUENCE_TOKEN" ]; then
    echo "$(date): CONFLUENCE_EMAIL or CONFLUENCE_TOKEN not set, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 0
fi

# Registry: page_id | filename | description
# Add new pages here to sync them automatically
PAGES=(
    "1597341723|claudehub.md|ClaudeHub main page"
    "1559166979|use-case-library.md|AI dev tools use-case library"
    "1588723799|tips-bash-mode.md|Tip: using bash mode"
    "1527939210|plugin-marketplace.md|Plugin marketplace plan"
)

SYNCED=0
FAILED=0

for ENTRY in "${PAGES[@]}"; do
    IFS='|' read -r PAGE_ID FILENAME DESCRIPTION <<< "$ENTRY"
    OUTFILE="$MEMORY_DIR/$FILENAME"

    RESULT=$(curl -s -w "\n%{http_code}" -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
        "$CONFLUENCE_BASE/$PAGE_ID?expand=body.storage" \
        -H "Accept: application/json")

    HTTP_CODE=$(echo "$RESULT" | tail -1)
    BODY=$(echo "$RESULT" | sed '$d')

    if [ "$HTTP_CODE" != "200" ]; then
        echo "$(date): FAILED $FILENAME (HTTP $HTTP_CODE)" >> "$LOG_DIR/4-sync-confluence.log"
        FAILED=$((FAILED + 1))
        continue
    fi

    echo "$BODY" | python3 -c "
import sys, json, html2text

data = json.loads(sys.stdin.read())
html = data['body']['storage']['value']
title = data.get('title', 'Untitled')
page_id = '$PAGE_ID'

h = html2text.HTML2Text()
h.body_width = 0
h.ignore_links = False
h.ignore_images = True
h.ignore_emphasis = False

md = h.handle(html)

# Clean up common Confluence macro artifacts
import re
lines = md.split('\n')
clean = []
for line in lines:
    # Skip lines that are just Confluence macro IDs/metadata
    if re.match(r'^[a-f0-9]{10,}$', line.strip()):
        continue
    if re.match(r'^none$', line.strip()):
        continue
    if re.match(r'^note[a-f0-9]+$', line.strip()):
        continue
    if re.match(r'^:.*:.*#', line.strip()):
        continue
    # Remove trailing UUIDs from lines
    line = re.sub(r'\s+[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\s*$', '', line)
    clean.append(line)

md = '\n'.join(clean)

# Remove duplicate consecutive headers
md = re.sub(r'(\*\*[^*]+\*\*)\s*\n\s*\1', r'\1', md)

source = f'https://basis.atlassian.net/wiki/rest/api/content/{page_id}/view'
print(f'# {title}\n\nSource: {source}\n\n{md}')
" > "$OUTFILE" 2>/dev/null

    if [ $? -eq 0 ]; then
        LINES=$(wc -l < "$OUTFILE")
        echo "$(date): OK $FILENAME ($LINES lines)" >> "$LOG_DIR/4-sync-confluence.log"
        SYNCED=$((SYNCED + 1))
    else
        echo "$(date): FAILED $FILENAME (parse error)" >> "$LOG_DIR/4-sync-confluence.log"
        FAILED=$((FAILED + 1))
    fi
done

echo "$(date): Sync complete. $SYNCED synced, $FAILED failed." >> "$LOG_DIR/4-sync-confluence.log"
