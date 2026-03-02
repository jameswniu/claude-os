#!/bin/bash
# test.sh - Validate scripts without running Claude Code
# Usage: bash test.sh

PASS=0
FAIL=0
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$TEST_DIR/.." && pwd)"
SCRIPT_DIR="$REPO_DIR/scripts"
LAUNCHD_DIR="$REPO_DIR/launchd"

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Claude OS Script Tests ==="
echo ""

# ----------------------------
echo "## 1-log.sh"
# ----------------------------

# Test: script exists and is executable
[ -x "$SCRIPT_DIR/1-log.sh" ] && pass "script is executable" || fail "script is not executable"
head -1 "$SCRIPT_DIR/1-log.sh" | grep -q "#!/bin/bash" && pass "has bash shebang" || fail "missing bash shebang"

# Test: script references required paths
grep -q "MEMORY_DIR" "$SCRIPT_DIR/1-log.sh" && pass "references MEMORY_DIR" || fail "missing MEMORY_DIR"
grep -q "HISTORY" "$SCRIPT_DIR/1-log.sh" && pass "references HISTORY file" || fail "missing HISTORY reference"
grep -q "LAST_RUN_FILE" "$SCRIPT_DIR/1-log.sh" && pass "tracks last run time" || fail "missing last run tracking"
grep -q "claude -p" "$SCRIPT_DIR/1-log.sh" && pass "calls claude headless mode" || fail "missing claude -p call"
grep -q "max-budget-usd" "$SCRIPT_DIR/1-log.sh" && pass "has budget cap" || fail "missing budget cap"
grep -q "allowedTools" "$SCRIPT_DIR/1-log.sh" && pass "restricts allowed tools" || fail "missing tool restrictions"

# Test: skips when no new sessions
grep -q "No new sessions" "$SCRIPT_DIR/1-log.sh" && pass "handles no-new-sessions case" || fail "missing skip logic"

echo ""

# ----------------------------
echo "## 2-distill.sh"
# ----------------------------

[ -x "$SCRIPT_DIR/2-distill.sh" ] && pass "script is executable" || fail "script is not executable"
head -1 "$SCRIPT_DIR/2-distill.sh" | grep -q "#!/bin/bash" && pass "has bash shebang" || fail "missing bash shebang"
grep -q "MEMORY_DIR" "$SCRIPT_DIR/2-distill.sh" && pass "references MEMORY_DIR" || fail "missing MEMORY_DIR"
grep -q "claude -p" "$SCRIPT_DIR/2-distill.sh" && pass "calls claude headless mode" || fail "missing claude -p call"
grep -q "max-budget-usd" "$SCRIPT_DIR/2-distill.sh" && pass "has budget cap" || fail "missing budget cap"
grep -q "logs.md" "$SCRIPT_DIR/2-distill.sh" && pass "reads logs.md" || fail "missing logs.md reference"
grep -q "MEMORY.md" "$SCRIPT_DIR/2-distill.sh" && pass "writes MEMORY.md" || fail "missing MEMORY.md reference"
grep -q "200 lines" "$SCRIPT_DIR/2-distill.sh" && pass "enforces 200 line limit" || fail "missing line limit rule"

echo ""

# ----------------------------
echo "## 3-promote.sh"
# ----------------------------

[ -x "$SCRIPT_DIR/3-promote.sh" ] && pass "script is executable" || fail "script is not executable"
head -1 "$SCRIPT_DIR/3-promote.sh" | grep -q "#!/bin/bash" && pass "has bash shebang" || fail "missing bash shebang"
grep -q "MEMORY_DIR" "$SCRIPT_DIR/3-promote.sh" && pass "references MEMORY_DIR" || fail "missing MEMORY_DIR"
grep -q "claude -p" "$SCRIPT_DIR/3-promote.sh" && pass "calls claude headless mode" || fail "missing claude -p call"
grep -q "max-budget-usd" "$SCRIPT_DIR/3-promote.sh" && pass "has budget cap" || fail "missing budget cap"
grep -q "MEMORY.md" "$SCRIPT_DIR/3-promote.sh" && pass "reads MEMORY.md" || fail "missing MEMORY.md reference"
grep -q "CLAUDE.md" "$SCRIPT_DIR/3-promote.sh" && pass "writes CLAUDE.md" || fail "missing CLAUDE.md reference"
grep -q "3+" "$SCRIPT_DIR/3-promote.sh" && pass "requires 3+ occurrences for promotion" || fail "missing promotion threshold"

echo ""

# ----------------------------
echo "## 4-sync-confluence.sh"
# ----------------------------

[ -x "$SCRIPT_DIR/4-sync-confluence.sh" ] && pass "script is executable" || fail "script is not executable"
head -1 "$SCRIPT_DIR/4-sync-confluence.sh" | grep -q "#!/bin/bash" && pass "has bash shebang" || fail "missing bash shebang"
grep -q "MEMORY_DIR" "$SCRIPT_DIR/4-sync-confluence.sh" && pass "references MEMORY_DIR" || fail "missing MEMORY_DIR"
grep -q "CONFLUENCE_BASE" "$SCRIPT_DIR/4-sync-confluence.sh" && pass "references Confluence API" || fail "missing Confluence API"
grep -q "CONFLUENCE_EMAIL" "$SCRIPT_DIR/4-sync-confluence.sh" && pass "reads auth from env vars" || fail "missing auth env vars"
grep -q "existing_ids" "$SCRIPT_DIR/4-sync-confluence.sh" && pass "tracks discovered pages" || fail "missing page tracking"
grep -q "html2text" "$SCRIPT_DIR/4-sync-confluence.sh" && pass "converts HTML to markdown" || fail "missing HTML conversion"
grep -q "CONFLUENCE_EMAIL.*CONFLUENCE_TOKEN" "$SCRIPT_DIR/4-sync-confluence.sh" && pass "skips when no auth" || fail "missing auth skip logic"

echo ""

# ----------------------------
echo "## Repo checks"
# ----------------------------

# Test: output directory exists
[ -d "$REPO_DIR/output" ] && pass "output directory exists" || fail "output directory missing"

# Test: .gitignore excludes output
grep -q "output/" "$REPO_DIR/.gitignore" && pass ".gitignore excludes output/" || fail "output/ not in .gitignore"

# Test: no em dashes in README
grep -q "—" "$REPO_DIR/README.md" && fail "README contains em dashes" || pass "README has no em dashes"

# Test: EXAMPLES templates have no project-specific content
EX="$REPO_DIR/EXAMPLES"
grep -qi "media.strategy.generator\|orchestrator.*8000\|MCP.*8001\|uvicorn\|FastAPI\|LangGraph\|Supervisord" "$EX/CLAUDE.md" && fail "EXAMPLES/CLAUDE.md has project-specific content" || pass "EXAMPLES/CLAUDE.md is generic"
grep -q "stash.centro.net" "$EX/.claude/CLAUDE.md" && fail "EXAMPLES/.claude/CLAUDE.md has project-specific URLs" || pass "EXAMPLES/.claude/CLAUDE.md is generic"
grep -q "stash.centro.net" "$EX/memory/MEMORY.md" && fail "EXAMPLES/MEMORY.md has project-specific URLs" || pass "EXAMPLES/MEMORY.md is generic"
grep -q "BP-29" "$EX/.claude/commands/review.md" && fail "EXAMPLES/review.md has project-specific tickets" || pass "EXAMPLES/review.md is generic"
grep -q "REDACTED\|ATATT" "$EX/.claude/settings.local.json" && fail "EXAMPLES/settings.local.json has secrets" || pass "EXAMPLES/settings.local.json is clean"
grep -q "(confluence:" "$EX/memory/MEMORY.md" && fail "EXAMPLES/MEMORY.md has project-specific topic entries" || pass "EXAMPLES/MEMORY.md topic entries are clean"

# Test: plist files are valid XML
for PLIST in "$LAUNCHD_DIR"/com.claude.memory-*.plist; do
  NAME=$(basename "$PLIST")
  xmllint --noout "$PLIST" 2>/dev/null && pass "$NAME is valid XML" || fail "$NAME is invalid XML"
done

# Test: plist source templates have ~/.local/bin in PATH
for PLIST in "$LAUNCHD_DIR"/com.claude.memory-*.plist; do
  NAME=$(basename "$PLIST")
  grep -q "\.local/bin" "$PLIST" && pass "$NAME has ~/.local/bin in PATH" || fail "$NAME missing ~/.local/bin in PATH"
done

# Test: plist source templates have no real tokens (only placeholders)
for PLIST in "$LAUNCHD_DIR"/com.claude.memory-*.plist; do
  NAME=$(basename "$PLIST")
  grep -q "ATATT\|ntn_" "$PLIST" && fail "$NAME has real token" || pass "$NAME has no real tokens"
done

echo ""

# ----------------------------
echo "## 5-checkpoint.sh"
# ----------------------------

[ -x "$SCRIPT_DIR/5-checkpoint.sh" ] && pass "script is executable" || fail "script is not executable"
head -1 "$SCRIPT_DIR/5-checkpoint.sh" | grep -q "#!/bin/bash" && pass "has bash shebang" || fail "missing bash shebang"

# Test: checkpoint filters .claude/CLAUDE.md
grep -q "learned per project" "$EX/.claude/CLAUDE.md" && pass "EXAMPLES/.claude/CLAUDE.md has placeholders" || fail "EXAMPLES/.claude/CLAUDE.md missing placeholders"
grep -q "stash.centro.net" "$EX/.claude/CLAUDE.md" && fail "EXAMPLES/.claude/CLAUDE.md has project-specific URLs" || pass "EXAMPLES/.claude/CLAUDE.md has no project URLs"
grep -q "BP-[0-9]" "$EX/.claude/CLAUDE.md" && fail "EXAMPLES/.claude/CLAUDE.md has project-specific tickets" || pass "EXAMPLES/.claude/CLAUDE.md has no project tickets"

# Test: checkpoint filters CLAUDE.md
grep -qi "media.strategy.generator\|orchestrator.*8000\|MCP.*8001\|uvicorn\|FastAPI\|LangGraph" "$EX/CLAUDE.md" && fail "EXAMPLES/CLAUDE.md has project-specific content" || pass "EXAMPLES/CLAUDE.md has no project content"
grep -q "fill in for your project" "$EX/CLAUDE.md" && pass "EXAMPLES/CLAUDE.md has placeholder build commands" || fail "EXAMPLES/CLAUDE.md missing placeholder build commands"

# Test: distilled topic files have no Confluence page IDs
TOPIC_HAS_CONFLUENCE_ID=0
for TOPIC in "$EX/memory"/*.md; do
  NAME=$(basename "$TOPIC")
  [ "$NAME" = "MEMORY.md" ] && continue
  [ "$NAME" = "logs.md" ] && continue
  grep -q "(confluence:[0-9]" "$TOPIC" && TOPIC_HAS_CONFLUENCE_ID=1
done
[ "$TOPIC_HAS_CONFLUENCE_ID" -eq 0 ] && pass "distilled topic files have no Confluence IDs" || fail "distilled topic files still have Confluence IDs"

# Test: distilled topic files have no Basis-specific URLs
TOPIC_HAS_BASIS_URL=0
for TOPIC in "$EX/memory"/*.md; do
  NAME=$(basename "$TOPIC")
  [ "$NAME" = "MEMORY.md" ] && continue
  [ "$NAME" = "logs.md" ] && continue
  grep -q "stash.centro.net\|basis.atlassian.net" "$TOPIC" && TOPIC_HAS_BASIS_URL=1
done
[ "$TOPIC_HAS_BASIS_URL" -eq 0 ] && pass "distilled topic files have no Basis-specific URLs" || fail "distilled topic files still have Basis-specific URLs"

# Test: no topics/ subfolder in EXAMPLES
[ -d "$EX/memory/topics" ] && fail "EXAMPLES still has topics/ subfolder" || pass "EXAMPLES has flat topic structure"

# Test: scripts have no topics/ subfolder references
grep -q "topics/" "$SCRIPT_DIR/4-sync-confluence.sh" && fail "4-sync-confluence.sh still references topics/" || pass "4-sync-confluence.sh has no topics/ refs"
grep -q "topics/" "$SCRIPT_DIR/5-sync-notion.sh" && fail "5-sync-notion.sh still references topics/" || pass "5-sync-notion.sh has no topics/ refs"
grep -q 'topics/' "$SCRIPT_DIR/6-bootstrap.sh" && fail "6-bootstrap.sh still references topics/" || pass "6-bootstrap.sh has no topics/ refs"

# ----------------------------
echo ""
echo "## Local integration checks (skipped in CI)"
# ----------------------------

if [ -z "$CI" ]; then
  # Test: memory directory exists
  # Claude Code encodes project paths: /Users/name/repo -> -Users-name-repo
  PROJECT_SLUG=$(echo "$HOME/media-strategy-generator" | tr '/.' '-' | sed 's/^//')
  MEMORY_DIR="$HOME/.claude/projects/${PROJECT_SLUG}/memory"
  [ -d "$MEMORY_DIR" ] && pass "memory directory exists" || fail "memory directory missing"
  [ -f "$MEMORY_DIR/MEMORY.md" ] && pass "MEMORY.md exists" || fail "MEMORY.md missing"
  [ -f "$MEMORY_DIR/logs.md" ] && pass "logs.md exists" || fail "logs.md missing"

  # Test: launchd agents loaded
  launchctl list | grep -q "com.claude.memory-log" && pass "log agent loaded" || fail "log agent not loaded"
  launchctl list | grep -q "com.claude.memory-distill" && pass "distill agent loaded" || fail "distill agent not loaded"
  launchctl list | grep -q "com.claude.memory-promote" && pass "promote agent loaded" || fail "promote agent not loaded"
else
  echo "  SKIP: memory directory (CI)"
  echo "  SKIP: launchd agents (CI)"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
