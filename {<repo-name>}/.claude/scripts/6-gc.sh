#!/bin/bash
# 6-gc.sh — Runs weekly (launchd) or on-demand via /gc
# Scores memory files, archives stale ones, flags consolidation candidates
# Pattern: same as 2-distill.sh — loop over projects, claude -p for consolidation

LOG_DIR="$HOME/claude-os/output"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/6-gc.log"

echo "$(date): === GC run starting ===" >> "$LOG_FILE"

# If MEMORY_FILE is set (launchd per-project mode), scope to that project only
if [ -n "$MEMORY_FILE" ] && [ -f "$MEMORY_FILE" ]; then
    MEMORY_FILES="$MEMORY_FILE"
else
    # Manual run: process all projects
    MEMORY_FILES=$(find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null)
fi
if [ -z "$MEMORY_FILES" ]; then
    echo "$(date): No MEMORY.md files found, skipping" >> "$LOG_FILE"
    exit 0
fi

ERRORS=0

while IFS= read -r MEMORY_FILE; do
    MEMORY_DIR=$(dirname "$MEMORY_FILE")
    SLUG=$(echo "$MEMORY_DIR" | sed 's|.*/projects/||; s|/memory.*||')

    # Resolve project directory from history.jsonl
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
        echo "$(date): [$SLUG] Could not resolve project directory, skipping" >> "$LOG_FILE"
        continue
    fi

    echo "$(date): [$PROJECT_DIR] Starting GC..." >> "$LOG_FILE"

    ARCHIVE_DIR="$MEMORY_DIR/archive"
    mkdir -p "$ARCHIVE_DIR"

    GC_METADATA="$MEMORY_DIR/.gc-metadata.json"

    # Initialize metadata file if missing
    if [ ! -f "$GC_METADATA" ]; then
        echo '{}' > "$GC_METADATA"
    fi

    # Score all memory files and take actions
    python3 - "$MEMORY_DIR" "$ARCHIVE_DIR" "$GC_METADATA" "$MEMORY_FILE" << 'PYTHON_SCRIPT' >> "$LOG_FILE" 2>&1
import sys, os, json, shutil
from datetime import datetime, timedelta
from pathlib import Path

memory_dir = sys.argv[1]
archive_dir = sys.argv[2]
gc_metadata_path = sys.argv[3]
memory_md_path = sys.argv[4]

now = datetime.now()

# Load existing metadata
try:
    with open(gc_metadata_path) as f:
        metadata = json.load(f)
except (json.JSONDecodeError, FileNotFoundError):
    metadata = {}

# Read MEMORY.md to check index presence
try:
    with open(memory_md_path) as f:
        memory_content = f.read()
except FileNotFoundError:
    memory_content = ""

# Get all .md files in memory dir (not subdirs, not MEMORY.md itself)
md_files = []
for f in Path(memory_dir).glob("*.md"):
    if f.name == "MEMORY.md":
        continue
    md_files.append(f)

results = []

# Build set of managed files (Confluence-synced, Notion-synced, or reference material)
# These are externally managed by sync scripts and should never be GC'd
import re
managed_files = set()
for line in memory_content.split("\n"):
    m = re.match(r'^- `([^`]+\.md)`', line)
    if m:
        fn = m.group(1)
        if '(confluence:' in line or '(notion:' in line or '-- reference material' in line:
            managed_files.add(fn)

for fpath in sorted(md_files):
    fname = fpath.name
    stat = fpath.stat()
    size_bytes = stat.st_size
    age_days = (now - datetime.fromtimestamp(stat.st_mtime)).days

    # Read frontmatter to get type
    ftype = "unknown"
    try:
        with open(fpath) as f:
            content = f.read()
        if content.startswith("---"):
            fm_end = content.find("---", 3)
            if fm_end > 0:
                fm = content[3:fm_end]
                for line in fm.split("\n"):
                    if line.strip().startswith("type:"):
                        ftype = line.split(":", 1)[1].strip()
                        break
    except:
        content = ""

    # Skip managed files (Confluence/Notion-synced, reference material)
    if fname in managed_files:
        results.append((fname, "managed", age_days, size_bytes, -1, "managed (sync)"))
        file_meta = metadata.get(fname, {})
        file_meta["type"] = "managed"
        file_meta["score"] = -1
        file_meta["last_scored"] = now.isoformat()
        file_meta["managed"] = True
        metadata[fname] = file_meta
        continue

    # Check for manual override in metadata
    file_meta = metadata.get(fname, {})
    if file_meta.get("pinned", False):
        score = 100
        results.append((fname, ftype, age_days, size_bytes, score, "pinned"))
        file_meta["score"] = score
        file_meta["last_scored"] = now.isoformat()
        metadata[fname] = file_meta
        continue

    # --- Scoring ---

    # 1. Type weight (30%)
    type_weights = {
        "feedback": 100,
        "project": 70,
        "advice": 60,
        "user": 80,
        "reference": 40,
        "confluence": 20,
        "unknown": 30,
    }
    type_score = type_weights.get(ftype, 30)

    # 2. Recency (25%): score = max(0, 100 - age_days * 0.5)
    recency_score = max(0, 100 - age_days * 0.5)

    # 3. Size efficiency (15%): small dense files score higher, >20KB penalized
    if size_bytes < 2000:
        size_score = 100
    elif size_bytes < 5000:
        size_score = 80
    elif size_bytes < 10000:
        size_score = 60
    elif size_bytes < 20000:
        size_score = 40
    else:
        size_score = max(0, 40 - (size_bytes - 20000) // 5000 * 10)

    # 4. Index presence (15%): described in MEMORY.md
    basename_no_ext = fpath.stem
    if fname in memory_content:
        # Check if it has a description (not just bare listing)
        # Look for "fname" followed by description text
        idx = memory_content.find(fname)
        line_end = memory_content.find("\n", idx) if idx >= 0 else -1
        line = memory_content[idx:line_end] if idx >= 0 and line_end >= 0 else ""
        if " -- " in line or " — " in line or ":" in line.split(fname, 1)[-1]:
            index_score = 100
        else:
            index_score = 50
    else:
        index_score = 0

    # 5. Source freshness (15%): updated in last 60 days
    if age_days <= 60:
        freshness_score = 100
    else:
        freshness_score = max(0, 100 - (age_days - 60) * 1.0)

    # Weighted total
    score = int(
        type_score * 0.30
        + recency_score * 0.25
        + size_score * 0.15
        + index_score * 0.15
        + freshness_score * 0.15
    )

    # Determine action
    if score >= 60:
        action = "keep"
    elif score >= 30:
        action = "consolidate"
    else:
        action = "archive"

    results.append((fname, ftype, age_days, size_bytes, score, action))

    # Update metadata
    file_meta["type"] = ftype
    file_meta["score"] = score
    file_meta["last_scored"] = now.isoformat()
    file_meta["age_days"] = age_days
    file_meta["size_bytes"] = size_bytes
    metadata[fname] = file_meta

# Print scoring table
print("\n{:<55} {:<12} {:>5} {:>8} {:>5} {:<12}".format(
    "File", "Type", "Age", "Size", "Score", "Action"))
print("-" * 105)
for fname, ftype, age, size, score, action in sorted(results, key=lambda x: x[4]):
    size_str = f"{size//1024}KB" if size >= 1024 else f"{size}B"
    print(f"{fname:<55} {ftype:<12} {age:>5}d {size_str:>8} {score:>5} {action:<12}")

# Auto-archive files scoring <30 (skip managed files)
archived = []
for fname, ftype, age, size, score, action in results:
    if action == "archive" and ftype != "managed":
        src = os.path.join(memory_dir, fname)
        dst = os.path.join(archive_dir, fname)
        try:
            shutil.move(src, dst)
            archived.append(fname)
            print(f"\n  ARCHIVED: {fname} (score={score}) -> archive/")
        except Exception as e:
            print(f"\n  ERROR archiving {fname}: {e}")

# List consolidation candidates grouped by potential theme (exclude managed)
consolidate_files = [(f, t, a, s, sc) for f, t, a, s, sc, act in results if act == "consolidate" and t != "managed"]
if consolidate_files:
    print(f"\nConsolidation candidates ({len(consolidate_files)} files):")
    for fname, ftype, age, size, score in consolidate_files:
        size_str = f"{size//1024}KB" if size >= 1024 else f"{size}B"
        print(f"  {fname} (type={ftype}, score={score}, {size_str})")

# Summary
managed_count = sum(1 for _, _, _, _, _, a in results if a == "managed (sync)")
keep_count = sum(1 for _, _, _, _, _, a in results if a == "keep")
consol_count = len(consolidate_files)
archive_count = len(archived)
print(f"\nSummary: {managed_count} managed (sync), {keep_count} kept, {consol_count} consolidation candidates, {archive_count} archived")

# Save metadata
with open(gc_metadata_path, "w") as f:
    json.dump(metadata, f, indent=2, default=str)

# Check MEMORY.md line count
try:
    with open(memory_md_path) as f:
        line_count = len(f.readlines())
    print(f"MEMORY.md: {line_count}/200 lines")
    if line_count > 180:
        print(f"  WARNING: MEMORY.md over 180 lines, needs trimming")
except:
    pass

PYTHON_SCRIPT

    if [ $? -ne 0 ]; then
        echo "$(date): [$PROJECT_DIR] ERROR: GC scoring failed" >> "$LOG_FILE"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    echo "$(date): [$PROJECT_DIR] GC scoring complete" >> "$LOG_FILE"

    # --- Consolidation via claude -p (only if there are candidates) ---
    CONSOLIDATE_COUNT=$(python3 -c "
import json
with open('$GC_METADATA') as f:
    meta = json.load(f)
count = sum(1 for v in meta.values() if isinstance(v, dict) and 30 <= v.get('score', 100) < 60)
print(count)
" 2>/dev/null)

    if [ "$CONSOLIDATE_COUNT" -gt 0 ] && [ "${GC_AUTO_CONSOLIDATE:-0}" = "1" ]; then
        echo "$(date): [$PROJECT_DIR] Running consolidation on $CONSOLIDATE_COUNT candidates..." >> "$LOG_FILE"

        (
            cd "$PROJECT_DIR" || exit 1
            unset CLAUDECODE

            claude -p "You are a memory consolidation agent. Read the GC metadata at $GC_METADATA.

Find all files with scores between 30-59 (consolidation candidates). Group them by theme:
- AI tools: ai-*.md, tips-*.md
- Apps engineering: apps-engineering-*.md
- Git/PR reference: git-*.md, archived-*.md, tickets-*.md, problem-*.md, code-reviews.md

For each group:
1. Read all files in the group
2. Create a single consolidated file (e.g., 'consolidated-ai-tools.md') with the essential information distilled to <25% of original size
3. Move originals to $ARCHIVE_DIR/
4. Update MEMORY.md: replace individual entries with one line pointing to the consolidated file

Keep it tight. Only preserve actionable information, not historical context.
Output what you changed." \
              --allowedTools "Read,Edit,Write,Bash(mv)" \
              --permission-mode bypassPermissions \
              --max-budget-usd 1.00 \
              < /dev/null
        ) >> "$LOG_FILE" 2>&1

        echo "$(date): [$PROJECT_DIR] Consolidation complete" >> "$LOG_FILE"
    elif [ "$CONSOLIDATE_COUNT" -gt 0 ]; then
        echo "$(date): [$PROJECT_DIR] $CONSOLIDATE_COUNT consolidation candidates found (run with GC_AUTO_CONSOLIDATE=1 or /gc to act)" >> "$LOG_FILE"
    fi

done <<< "$MEMORY_FILES"

# --- User-level GC ---
# Scan ~/.claude/memory/ the same way (if it exists)
USER_MEMORY_DIR="$HOME/.claude/memory"
USER_MEMORY_MD="$USER_MEMORY_DIR/MEMORY.md"
if [ -d "$USER_MEMORY_DIR" ] && [ -f "$USER_MEMORY_MD" ]; then
    echo "$(date): [user-level] Starting GC on $USER_MEMORY_DIR..." >> "$LOG_FILE"

    USER_ARCHIVE_DIR="$USER_MEMORY_DIR/archive"
    mkdir -p "$USER_ARCHIVE_DIR"
    USER_GC_META="$USER_MEMORY_DIR/.gc-metadata.json"
    if [ ! -f "$USER_GC_META" ]; then
        echo '{}' > "$USER_GC_META"
    fi

    python3 - "$USER_MEMORY_DIR" "$USER_ARCHIVE_DIR" "$USER_GC_META" "$USER_MEMORY_MD" << 'USER_GC_SCRIPT' >> "$LOG_FILE" 2>&1
import sys, os, json, shutil
from datetime import datetime
from pathlib import Path

memory_dir, archive_dir, gc_meta_path, memory_md_path = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
now = datetime.now()

try:
    with open(gc_meta_path) as f:
        metadata = json.load(f)
except (json.JSONDecodeError, FileNotFoundError):
    metadata = {}

try:
    with open(memory_md_path) as f:
        memory_content = f.read()
except FileNotFoundError:
    memory_content = ""

md_files = [f for f in Path(memory_dir).glob("*.md") if f.name != "MEMORY.md"]
results = []

# Build set of managed files (same logic as project-level)
import re
managed_files = set()
for line in memory_content.split("\n"):
    m = re.match(r'^- `([^`]+\.md)`', line)
    if m:
        fn = m.group(1)
        if '(confluence:' in line or '(notion:' in line or '-- reference material' in line:
            managed_files.add(fn)

for fpath in sorted(md_files):
    fname = fpath.name
    stat = fpath.stat()
    size_bytes = stat.st_size
    age_days = (now - datetime.fromtimestamp(stat.st_mtime)).days

    ftype = "unknown"
    try:
        with open(fpath) as f:
            content = f.read()
        if content.startswith("---"):
            fm_end = content.find("---", 3)
            if fm_end > 0:
                for line in content[3:fm_end].split("\n"):
                    if line.strip().startswith("type:"):
                        ftype = line.split(":", 1)[1].strip()
                        break
    except:
        pass

    # Skip managed files (Confluence/Notion-synced, reference material)
    if fname in managed_files:
        results.append((fname, "managed", age_days, size_bytes, -1, "managed (sync)"))
        file_meta = metadata.get(fname, {})
        file_meta["type"] = "managed"
        file_meta["score"] = -1
        file_meta["last_scored"] = now.isoformat()
        file_meta["managed"] = True
        metadata[fname] = file_meta
        continue

    file_meta = metadata.get(fname, {})
    if file_meta.get("pinned", False):
        score = 100
        results.append((fname, ftype, age_days, size_bytes, score, "pinned"))
        file_meta["score"] = score
        file_meta["last_scored"] = now.isoformat()
        metadata[fname] = file_meta
        continue

    type_weights = {"feedback": 100, "project": 70, "advice": 60, "user": 80, "reference": 40, "confluence": 20, "unknown": 30}
    type_score = type_weights.get(ftype, 30)
    recency_score = max(0, 100 - age_days * 0.5)
    size_score = 100 if size_bytes < 2000 else 80 if size_bytes < 5000 else 60 if size_bytes < 10000 else 40 if size_bytes < 20000 else max(0, 40 - (size_bytes - 20000) // 5000 * 10)
    index_score = 0
    if fname in memory_content:
        idx = memory_content.find(fname)
        line_end = memory_content.find("\n", idx) if idx >= 0 else -1
        line = memory_content[idx:line_end] if idx >= 0 and line_end >= 0 else ""
        index_score = 100 if (" -- " in line or " — " in line or ":" in line.split(fname, 1)[-1]) else 50
    freshness_score = 100 if age_days <= 60 else max(0, 100 - (age_days - 60) * 1.0)

    score = int(type_score * 0.30 + recency_score * 0.25 + size_score * 0.15 + index_score * 0.15 + freshness_score * 0.15)
    action = "keep" if score >= 60 else "consolidate" if score >= 30 else "archive"
    results.append((fname, ftype, age_days, size_bytes, score, action))
    file_meta.update({"type": ftype, "score": score, "last_scored": now.isoformat(), "age_days": age_days, "size_bytes": size_bytes})
    metadata[fname] = file_meta

print("\n[user-level] Memory file scores:")
print("{:<55} {:<12} {:>5} {:>8} {:>5} {:<12}".format("File", "Type", "Age", "Size", "Score", "Action"))
print("-" * 105)
for fname, ftype, age, size, score, action in sorted(results, key=lambda x: x[4]):
    size_str = f"{size//1024}KB" if size >= 1024 else f"{size}B"
    print(f"{fname:<55} {ftype:<12} {age:>5}d {size_str:>8} {score:>5} {action:<12}")

archived = []
for fname, ftype, age, size, score, action in results:
    if action == "archive" and ftype != "managed":
        try:
            shutil.move(os.path.join(memory_dir, fname), os.path.join(archive_dir, fname))
            archived.append(fname)
            print(f"  ARCHIVED: {fname} (score={score})")
        except Exception as e:
            print(f"  ERROR archiving {fname}: {e}")

managed_count = sum(1 for _,_,_,_,_,a in results if a=='managed (sync)')
print(f"\n[user-level] Summary: {managed_count} managed (sync), {sum(1 for _,_,_,_,_,a in results if a=='keep')} kept, {sum(1 for _,_,_,_,_,a in results if a=='consolidate')} consolidate, {len(archived)} archived")

with open(gc_meta_path, "w") as f:
    json.dump(metadata, f, indent=2, default=str)

USER_GC_SCRIPT

    echo "$(date): [user-level] GC complete" >> "$LOG_FILE"
fi

# --- Line limit enforcement ---
# Check all MEMORY.md files (project + user level) against 200-line limit
# Check all CLAUDE.md / CLAUDE.local.md files against 150-line limit
echo "$(date): Checking line limits..." >> "$LOG_FILE"

check_line_limit() {
    local file="$1"
    local limit="$2"
    local label="$3"
    if [ -f "$file" ]; then
        local lines
        lines=$(wc -l < "$file")
        if [ "$lines" -gt "$limit" ]; then
            echo "$(date): OVER LIMIT: $label ($file) is $lines/$limit lines" >> "$LOG_FILE"
        else
            echo "$(date): OK: $label ($file) is $lines/$limit lines" >> "$LOG_FILE"
        fi
    fi
}

# User-level configs
check_line_limit "$HOME/.claude/memory/MEMORY.md" 200 "user MEMORY.md"
check_line_limit "$HOME/.claude/CLAUDE.md" 150 "user CLAUDE.md"

# All project-level configs
find "$HOME/.claude/projects" -maxdepth 3 -name "MEMORY.md" 2>/dev/null | while read -r mfile; do
    slug=$(echo "$mfile" | sed 's|.*/projects/||; s|/memory.*||')
    check_line_limit "$mfile" 200 "[$slug] MEMORY.md"
done

find "$HOME/.claude/projects" -maxdepth 2 -name "CLAUDE.local.md" -o -name "CLAUDE.md" 2>/dev/null | while read -r cfile; do
    check_line_limit "$cfile" 150 "$(basename "$cfile") in $(dirname "$cfile" | sed 's|.*/projects/||')"
done

# Also check repo-level CLAUDE.md files for each resolved project
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
    if [ -n "$PROJECT_DIR" ]; then
        check_line_limit "$PROJECT_DIR/.claude/CLAUDE.local.md" 150 "[$SLUG] repo CLAUDE.local.md"
        check_line_limit "$PROJECT_DIR/CLAUDE.md" 150 "[$SLUG] repo CLAUDE.md"
    fi
done <<< "$MEMORY_FILES"

echo "$(date): === GC run complete ===" >> "$LOG_FILE"

if [ "$ERRORS" -gt 0 ]; then
    echo "$(date): Finished with $ERRORS error(s)" >> "$LOG_FILE"
    exit 1
fi
