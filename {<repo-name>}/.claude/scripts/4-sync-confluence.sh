#!/bin/bash
# 4-sync-confluence.sh — Runs every 24 hours
# 1. Auto-discovers new relevant Confluence pages and adds them to MEMORY.md (30-entry FIFO cap)
# 2. Syncs all (confluence:ID) entries from MEMORY.md to topic files
# Loops over all projects with a MEMORY.md

LOG_DIR="$HOME/claude-os/output"
CONFLUENCE_BASE="https://basis.atlassian.net/wiki/rest/api/content"

mkdir -p "$LOG_DIR"

# --- Phase 0: Reconcile orphaned topic files into MEMORY.md ---
MEMORY_FILES_ALL=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null)
RECONCILED_TOTAL=0

while IFS= read -r MF; do
    [ -z "$MF" ] && continue
    MD=$(dirname "$MF")
    RECONCILED=0

    # Find the last topic entry line number
    LAST_TOPIC_LINE=$(grep -n '`[^`]*\.md`' "$MF" | grep -v 'MEMORY\.md\|CLAUDE\.md\|logs\.md' | tail -1 | cut -d: -f1)
    [ -z "$LAST_TOPIC_LINE" ] && continue

    for TOPIC_FILE in "$MD"/*.md; do
        [ -f "$TOPIC_FILE" ] || continue
        BASENAME=$(basename "$TOPIC_FILE")
        [ "$BASENAME" = "MEMORY.md" ] && continue

        if ! grep -q "\`$BASENAME\`" "$MF"; then
            # Insert after last topic entry
            sed -i '' "${LAST_TOPIC_LINE}a\\
- \`${BASENAME}\` -- reference material" "$MF"
            LAST_TOPIC_LINE=$((LAST_TOPIC_LINE + 1))
            RECONCILED=$((RECONCILED + 1))
        fi
    done

    if [ "$RECONCILED" -gt 0 ]; then
        P0_SLUG=$(echo "$MD" | sed 's|.*/projects/||; s|/memory.*||')
        PROJ=$(python3 -c "
import json, os
slug = '$P0_SLUG'
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
        [ -z "$PROJ" ] && PROJ="$P0_SLUG"
        echo "$(date): [$PROJ] Reconciled $RECONCILED orphaned topic file(s)" >> "$LOG_DIR/4-sync-confluence.log"
        RECONCILED_TOTAL=$((RECONCILED_TOTAL + RECONCILED))
    fi
done <<< "$MEMORY_FILES_ALL"

if [ "$RECONCILED_TOTAL" -gt 0 ]; then
    echo "$(date): Phase 0 reconciled $RECONCILED_TOTAL total orphaned topic file(s)" >> "$LOG_DIR/4-sync-confluence.log"
fi

if [ -z "$CONFLUENCE_EMAIL" ] || [ -z "$CONFLUENCE_TOKEN" ]; then
    echo "$(date): CONFLUENCE_EMAIL or CONFLUENCE_TOKEN not set, skipping" >> "$LOG_DIR/4-sync-confluence.log"
    exit 2
fi

# Find all project MEMORY.md files
MEMORY_FILES=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null)
if [ -z "$MEMORY_FILES" ]; then
    echo "$(date): No MEMORY.md files found, skipping" >> "$LOG_DIR/4-sync-confluence.log"
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
    [ -z "$PROJECT_DIR" ] && PROJECT_DIR="$SLUG"

    if [ ! -f "$MEMORY_FILE" ]; then
        continue
    fi

    echo "$(date): [$PROJECT_DIR] Starting sync..." >> "$LOG_DIR/4-sync-confluence.log"

    # --- Phase 1: Auto-discover new pages ---

    DEFAULT_SPACE="BET"

    # Find project CLAUDE.md by matching slug against real directories
    PROJECT_SLUG=$(basename "$(dirname "$(dirname "$MEMORY_FILE")")")
    CLAUDE_MD=""
    for F in "$HOME"/*/CLAUDE.md "$HOME"/*/*/CLAUDE.md; do
        [ -f "$F" ] || continue
        D=$(dirname "$F")
        if [ "$(echo "$D" | tr '/._ ' '-')" = "$PROJECT_SLUG" ]; then
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
for m in re.finditer(r'\x60[^\x60]+\x60\s+.+?\s+(.+?)\s+\([a-z]+:', memory):
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
    if '(confluence:' in line and '\x60' in line:
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
        new_lines = [f'- \x60{fn}\x60 — {t} (confluence:{pid})' for pid, fn, t in new_pages]
        # 30-entry FIFO cap: count all topic entries with source IDs
        topic_count = sum(1 for l in lines if re.match(r'^- \x60[^\x60]+\.md\x60.*\([a-z]+:', l))
        while topic_count + len(new_lines) > 30:
            for i, l in enumerate(lines):
                if re.match(r'^- \x60[^\x60]+\.md\x60.*\([a-z]+:', l):
                    lines.pop(i)
                    if i <= last_idx:
                        last_idx -= 1
                    topic_count -= 1
                    break
            else:
                break
        lines = lines[:last_idx + 1] + new_lines + lines[last_idx + 1:]
        last_idx += len(new_lines)
        total_new += len(new_lines)

if total_new > 0:
    with open(memory_file, 'w') as f:
        f.write('\n'.join(lines))

print(total_new)
" 2>/dev/null)

    echo "$(date): [$PROJECT_DIR] Discovery complete. $(grep -c 'confluence:' "$MEMORY_FILE") total confluence entries" >> "$LOG_DIR/4-sync-confluence.log"

    # --- Phase 2: Sync all entries ---

    SYNCED=0
    FAILED=0

    while IFS= read -r LINE; do
        FILENAME=$(echo "$LINE" | sed -n 's/.*`\([^`]*\.md\)`.*/\1/p')
        PAGE_ID=$(echo "$LINE" | sed -n 's/.*(confluence:\([^)]*\)).*/\1/p')

        if [ -z "$FILENAME" ] || [ -z "$PAGE_ID" ]; then
            continue
        fi

        OUTFILE="$MEMORY_DIR/$FILENAME"

        RESULT=$(curl -s -w "\n%{http_code}" -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" \
            "$CONFLUENCE_BASE/$PAGE_ID?expand=body.storage" \
            -H "Accept: application/json")

        HTTP_CODE=$(echo "$RESULT" | tail -1)
        BODY=$(echo "$RESULT" | sed '$d')

        if [ "$HTTP_CODE" != "200" ]; then
            echo "$(date): [$PROJECT_DIR] FAILED $FILENAME (HTTP $HTTP_CODE)" >> "$LOG_DIR/4-sync-confluence.log"
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
            echo "$(date): [$PROJECT_DIR] OK $FILENAME ($LINES lines)" >> "$LOG_DIR/4-sync-confluence.log"
            SYNCED=$((SYNCED + 1))
        else
            echo "$(date): [$PROJECT_DIR] FAILED $FILENAME (parse error)" >> "$LOG_DIR/4-sync-confluence.log"
            FAILED=$((FAILED + 1))
        fi
    done < <(grep 'confluence:' "$MEMORY_FILE" | grep '`[^`]*\.md`')

    echo "$(date): [$PROJECT_DIR] Sync complete. $SYNCED synced, $FAILED failed." >> "$LOG_DIR/4-sync-confluence.log"

    if [ "$FAILED" -gt 0 ]; then
        ERRORS=$((ERRORS + 1))
    fi

done <<< "$MEMORY_FILES"

if [ "$ERRORS" -gt 0 ]; then
    echo "$(date): Finished with $ERRORS project(s) having failures" >> "$LOG_DIR/4-sync-confluence.log"
    exit 1
fi
