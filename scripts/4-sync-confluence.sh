#!/bin/bash
# 4-sync-confluence.sh — Runs every 24 hours
# 1. Auto-discovers new relevant Confluence pages and adds them to MEMORY.md
# 2. Syncs all (confluence:ID) entries from MEMORY.md to topic files

LOG_DIR="$HOME/claude-os/output"
CONFLUENCE_BASE="https://basis.atlassian.net/wiki/rest/api/content"

# Auto-detect: find the first MEMORY.md (prefer one with confluence: entries, fallback to any)
MEMORY_FILE=$(grep -rl 'confluence:' "$HOME/.claude/projects"/*/memory/MEMORY.md 2>/dev/null | head -1)
if [ -z "$MEMORY_FILE" ]; then
    MEMORY_FILE=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null | head -1)
fi
if [ -z "$MEMORY_FILE" ]; then
    echo "$(date): No MEMORY.md found, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 0
fi
MEMORY_DIR=$(dirname "$MEMORY_FILE")

mkdir -p "$LOG_DIR"

if [ -z "$CONFLUENCE_EMAIL" ] || [ -z "$CONFLUENCE_TOKEN" ]; then
    echo "$(date): CONFLUENCE_EMAIL or CONFLUENCE_TOKEN not set, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 0
fi

if [ ! -f "$MEMORY_FILE" ]; then
    echo "$(date): MEMORY.md not found at $MEMORY_FILE, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 0
fi

# --- Phase 1: Auto-discover new pages ---

# Search queries to find relevant pages (space:keyword pairs)
SEARCH_QUERIES=(
    "BET:claude"
    "BET:claude code"
    "BET:AI tools"
)

# Relevance filter: page title must contain at least one of these terms (case-insensitive)
RELEVANT_TERMS="claude code|claude os|ai tool|ai code|ai dev|ai review|ai pr|prompt|llm|plugin|marketplace"

# Exclude filter: page titles matching these terms are skipped (case-insensitive)
EXCLUDE_TERMS="upgrade|hack-ai-thon|hackathon|refactor from|loading indicator|pricing evaluation"

# Collect already-synced page IDs from MEMORY.md
EXISTING_IDS=$(grep 'confluence:' "$MEMORY_FILE" | sed -n 's/.*(confluence:\([^)]*\)).*/\1/p')

DISCOVERED=0

for QUERY in "${SEARCH_QUERIES[@]}"; do
    IFS=':' read -r SPACE KEYWORD <<< "$QUERY"
    ENCODED_KEYWORD=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$KEYWORD'))")

    SEARCH_RESULT=$(curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
        "$CONFLUENCE_BASE/search?cql=type=page+AND+space=$SPACE+AND+text~%22$ENCODED_KEYWORD%22&limit=25" \
        -H "Accept: application/json")

    # Parse results and check for new pages
    python3 -c "
import sys, json, re

data = json.loads('''$(echo "$SEARCH_RESULT" | sed "s/'/'\\''/g")''')
existing = set('''$EXISTING_IDS'''.split())
memory_file = '$MEMORY_FILE'

# Read current MEMORY.md
with open(memory_file) as f:
    content = f.read()

# Find the insertion point: last (confluence:...) line in Topic Files section
lines = content.split('\n')
last_confluence_idx = -1
for i, line in enumerate(lines):
    if '(confluence:' in line and '\`topics/' in line:
        last_confluence_idx = i

if last_confluence_idx < 0:
    # Look for Topic Files section header
    for i, line in enumerate(lines):
        if 'Topic Files' in line and line.startswith('#'):
            last_confluence_idx = i + 2  # skip header and blank line
            break
if last_confluence_idx < 0:
    # No Topic Files section, append one
    lines.append('')
    lines.append('## Topic Files (on demand, read when relevant)')
    lines.append('')
    last_confluence_idx = len(lines) - 1

relevant_terms = '$RELEVANT_TERMS'
exclude_terms = '$EXCLUDE_TERMS'
relevant_pattern = re.compile(relevant_terms, re.IGNORECASE)
exclude_pattern = re.compile(exclude_terms, re.IGNORECASE)

new_pages = []
for r in data.get('results', []):
    page_id = r['id']
    title = r['title']
    if page_id not in existing and relevant_pattern.search(title) and not exclude_pattern.search(title):
        # Generate filename from title
        filename = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-') + '.md'
        new_pages.append((page_id, filename, title))
        existing.add(page_id)

if new_pages and last_confluence_idx >= 0:
    new_lines = []
    for page_id, filename, title in new_pages:
        new_lines.append(f'- \`topics/{filename}\` — {title} (confluence:{page_id})')
    # Insert after the last confluence line
    lines = lines[:last_confluence_idx + 1] + new_lines + lines[last_confluence_idx + 1:]
    with open(memory_file, 'w') as f:
        f.write('\n'.join(lines))

print(len(new_pages))
" 2>/dev/null

    NEW_COUNT=$?
done

# Log discovery results
TOTAL_NEW=$(grep -c 'confluence:' "$MEMORY_FILE")
echo "$(date): Discovery complete. $TOTAL_NEW total confluence entries in MEMORY.md" >> "$LOG_DIR/4-sync-confluence.log"

# --- Phase 2: Sync all entries ---

SYNCED=0
FAILED=0

while IFS= read -r LINE; do
    FILENAME=$(echo "$LINE" | sed -n 's/.*`topics\/\([^`]*\)`.*/\1/p')
    PAGE_ID=$(echo "$LINE" | sed -n 's/.*(confluence:\([^)]*\)).*/\1/p')

    if [ -z "$FILENAME" ] || [ -z "$PAGE_ID" ]; then
        continue
    fi

    mkdir -p "$MEMORY_DIR/topics"
    OUTFILE="$MEMORY_DIR/topics/$FILENAME"

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
prev_line = ''
for line in lines:
    stripped = line.strip()
    if re.match(r'^[a-f0-9]{10,}$', stripped):
        continue
    if re.match(r'^none$', stripped):
        continue
    if re.match(r'^note[a-f0-9]+$', stripped):
        continue
    if re.match(r'^:.*:.*#', stripped):
        continue
    if re.match(r'^[\d]+(true|false|default|flat|none)+', stripped):
        continue
    if re.match(r'^:[a-z_]+:\s*$', stripped):
        continue
    line = re.sub(r'\s+[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}\s*$', '', line)
    line = re.sub(r'\\\\([*._~])', r'\1', line)
    if stripped and stripped == prev_line:
        continue
    prev_line = stripped
    clean.append(line)

md = '\n'.join(clean)
md = re.sub(r'(complete|not started|in progress|cancelled)\s*(Green|Yellow|Red)', r'\1', md, flags=re.IGNORECASE)
md = re.sub(r'\n{3,}', '\n\n', md)

space_key = data.get('_expandable', {}).get('space', '').split('/')[-1] if '_expandable' in data else ''
source = f'https://basis.atlassian.net/wiki/spaces/{space_key}/pages/{page_id}' if space_key else f'https://basis.atlassian.net/wiki/rest/api/content/{page_id}/view'
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
done < <(grep 'confluence:' "$MEMORY_FILE" | grep '`topics/')

echo "$(date): Sync complete. $SYNCED synced, $FAILED failed." >> "$LOG_DIR/4-sync-confluence.log"
