#!/bin/bash
# 4-sync-confluence.sh — Runs every 24 hours
# 1. Auto-discovers new relevant Confluence pages and adds them to MEMORY.md
# 2. Syncs all (confluence:ID) entries from MEMORY.md to topic files

LOG_DIR="$HOME/claude-os/output"
CONFLUENCE_BASE="https://basis.atlassian.net/wiki/rest/api/content"

# Use MEMORY_FILE if passed (e.g. from bootstrap), otherwise auto-detect
if [ -z "$MEMORY_FILE" ]; then
    MEMORY_FILE=$(grep -rl 'confluence:' "$HOME/.claude/projects"/*/memory/MEMORY.md 2>/dev/null | head -1)
fi
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
    exit 2
fi

if [ ! -f "$MEMORY_FILE" ]; then
    echo "$(date): MEMORY.md not found at $MEMORY_FILE, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 0
fi

# --- Phase 1: Auto-discover new pages ---

DEFAULT_SPACE="BET"

# Find project CLAUDE.md by matching slug against real directories
PROJECT_SLUG=$(basename "$(dirname "$(dirname "$MEMORY_FILE")")")
CLAUDE_MD=""
for F in "$HOME"/*/CLAUDE.md "$HOME"/*/*/CLAUDE.md; do
    [ -f "$F" ] || continue
    D=$(dirname "$F")
    if [ "$(echo "$D" | tr '/.' '-')" = "$PROJECT_SLUG" ]; then
        CLAUDE_MD="$F"
        break
    fi
done

# Extract search queries + relevance terms dynamically from MEMORY.md + CLAUDE.md
DISCOVERY_RESULT=$(python3 -c "
import re, json, urllib.parse, subprocess, os

memory_file = '$MEMORY_FILE'
claude_md = '$CLAUDE_MD'
space = '$DEFAULT_SPACE'
confluence_base = '$CONFLUENCE_BASE'
auth = ('$CONFLUENCE_EMAIL', '$CONFLUENCE_TOKEN')

with open(memory_file) as f:
    memory = f.read()

claude_content = ''
if claude_md and os.path.exists(claude_md):
    with open(claude_md) as f:
        claude_content = f.read()

# --- Extract search queries from project context ---
queries = set()

# 1. Topic descriptions (highest signal, for organic growth)
for m in re.finditer(r'\x60topics/[^\x60]+\x60\s+.+?\s+(.+?)\s+\([a-z]+:', memory):
    queries.add(m.group(1))

# 2. Section headings from MEMORY.md
skip_headings = {'topic files', 'memory', 'claude os', 'file system', 'cumulative friction'}
for m in re.finditer(r'^## (.+?)(?:\s*\(.*\))?\s*$', memory, re.MULTILINE):
    heading = m.group(1).strip()
    if heading.lower() not in skip_headings:
        queries.add(heading)

# 3. Section headings from CLAUDE.md
skip_claude = {'build', 'commands', 'docker', 'testing', 'style', 'quality', 'e2e', 'environment', 'configuration', 'local development'}
for m in re.finditer(r'^#{2,3} (.+?)$', claude_content, re.MULTILINE):
    heading = m.group(1).strip()
    if not any(s in heading.lower() for s in skip_claude):
        queries.add(heading)

# --- Extract relevance terms from both files ---
terms = set()
combined = memory + '\n' + claude_content

# Bold terms
for m in re.finditer(r'\*\*(.+?)\*\*', combined):
    term = m.group(1).strip().rstrip(':')
    if len(term) > 2 and len(term) < 40:
        terms.add(term.lower())

# Section headings as terms
for m in re.finditer(r'^#{1,3} (.+?)(?:\s*\(.*\))?\s*$', combined, re.MULTILINE):
    for word in re.split(r'[\s/]+', m.group(1)):
        word = re.sub(r'[^a-zA-Z0-9]', '', word)
        if len(word) > 2:
            terms.add(word.lower())

# Key terms from content (capitalized phrases likely to be proper nouns/tools)
for m in re.finditer(r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)+)\b', combined):
    terms.add(m.group(1).lower())

# Filter out generic terms
generic = {'the', 'this', 'that', 'with', 'from', 'into', 'all', 'run', 'use', 'set', 'not', 'for', 'and', 'are', 'can', 'may', 'will', 'has', 'get', 'new', 'key', 'see', 'how', 'code', 'file', 'files', 'line', 'start', 'check', 'install', 'important', 'must', 'pass', 'source', 'directories'}
terms = {t for t in terms if t not in generic and len(t) > 2}
relevant_pattern = '|'.join(re.escape(t) for t in sorted(terms)) if terms else '.'

# --- Search Confluence and discover pages ---
existing_ids = set(re.findall(r'\(confluence:(\d+)\)', memory))

lines = memory.split('\n')

# Find insertion point
last_idx = -1
for i, line in enumerate(lines):
    if '(confluence:' in line and '\x60topics/' in line:
        last_idx = i
if last_idx < 0:
    for i, line in enumerate(lines):
        if 'Topic Files' in line and line.startswith('#'):
            # Insert after the header line + description line
            last_idx = i + 2
            break

total_new = 0
for query in sorted(queries):
    encoded = urllib.parse.quote(query)
    url = f'{confluence_base}/search?cql=type=page+AND+space={space}+AND+text~%22{encoded}%22&limit=25'
    try:
        result = subprocess.run(
            ['curl', '-s', '-u', f'{auth[0]}:{auth[1]}', url, '-H', 'Accept: application/json'],
            capture_output=True, text=True, timeout=30
        )
        data = json.loads(result.stdout)
    except Exception:
        continue

    relevant_re = re.compile(relevant_pattern, re.IGNORECASE)
    new_pages = []
    for r in data.get('results', []):
        page_id = r['id']
        title = r['title']
        if page_id not in existing_ids and relevant_re.search(title):
            filename = re.sub(r'[^a-z0-9]+', '-', title.lower()).strip('-') + '.md'
            new_pages.append((page_id, filename, title))
            existing_ids.add(page_id)

    if new_pages and last_idx >= 0:
        new_lines = [f'- \x60topics/{fn}\x60 \u2014 {t} (confluence:{pid})' for pid, fn, t in new_pages]
        lines = lines[:last_idx + 1] + new_lines + lines[last_idx + 1:]
        last_idx += len(new_lines)
        total_new += len(new_pages)

if total_new > 0:
    with open(memory_file, 'w') as f:
        f.write('\n'.join(lines))

print(total_new)
" 2>/dev/null)

echo "$(date): Discovery complete. $(grep -c 'confluence:' "$MEMORY_FILE") total confluence entries in MEMORY.md" >> "$LOG_DIR/4-sync-confluence.log"

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
