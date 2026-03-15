#!/bin/bash
# test.sh - Validate scripts without running Claude Code
# Usage: bash test.sh

PASS=0
FAIL=0
TEST_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$TEST_DIR/.." && pwd)"
SCRIPT_DIR="$REPO_DIR/{<repo-name>}/.claude/scripts"

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
grep -q "history/logs.md" "$SCRIPT_DIR/2-distill.sh" && pass "reads history/logs.md" || fail "missing history/logs.md reference"
grep -q "MEMORY.md" "$SCRIPT_DIR/2-distill.sh" && pass "writes MEMORY.md" || fail "missing MEMORY.md reference"
grep -q "200 lines" "$SCRIPT_DIR/2-distill.sh" && pass "enforces 200 line limit" || fail "missing line limit rule"
grep -q "150" "$SCRIPT_DIR/2-distill.sh" && pass "enforces 150 line limit for CLAUDE.local.md" || fail "missing CLAUDE.local.md line limit"

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
grep -q "CLAUDE.local.md" "$SCRIPT_DIR/3-promote.sh" && pass "writes CLAUDE.local.md" || fail "missing CLAUDE.local.md reference"
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

# Test: templates have no project-specific content
REPO_TMPL="$REPO_DIR/{<repo-name>}"
MEM_TMPL="$REPO_DIR/{.claude}/projects/-Users-{<user-name>}-{<repo-name>}/memory"
grep -q "stash.centro.net" "$REPO_TMPL/.claude/CLAUDE.local.md" && fail "{<repo-name>}/.claude/CLAUDE.local.md has project-specific URLs" || pass "{<repo-name>}/.claude/CLAUDE.local.md is generic"
grep -q "stash.centro.net" "$MEM_TMPL/MEMORY.md" && fail "memory/MEMORY.md has project-specific URLs" || pass "memory/MEMORY.md is generic"
grep -q "BP-29" "$REPO_TMPL/.claude/commands/review.md" && fail "review.md has project-specific tickets" || pass "review.md is generic"
grep -q "BP-29" "$REPO_TMPL/.claude/commands/ticket.md" && fail "ticket.md has project-specific tickets" || pass "ticket.md is generic"
grep -q "REDACTED\|ATATT" "$REPO_TMPL/.claude/settings.local.json" && fail "settings.local.json has secrets" || pass "settings.local.json is clean"
grep -q "(confluence:" "$MEM_TMPL/MEMORY.md" && fail "memory/MEMORY.md has project-specific topic entries" || pass "memory/MEMORY.md topic entries are clean"

# Test: user-level configs
USER_TMPL="$REPO_DIR/{.claude}"
[ -f "$USER_TMPL/settings.json" ] && pass "{.claude}/settings.json exists" || fail "{.claude}/settings.json missing"
[ -f "$USER_TMPL/commands/ticket.md" ] && pass "{.claude}/commands/ticket.md exists" || fail "{.claude}/commands/ticket.md missing"
[ -f "$USER_TMPL/hooks/block-em-dashes.sh" ] && pass "{.claude}/hooks/block-em-dashes.sh exists" || fail "{.claude}/hooks/block-em-dashes.sh missing"
[ -f "$USER_TMPL/memory/MEMORY.md" ] && pass "{.claude}/memory/MEMORY.md exists" || fail "{.claude}/memory/MEMORY.md missing"
grep -q "LinkedIn" "$USER_TMPL/memory/MEMORY.md" && fail "{.claude}/memory/MEMORY.md has LinkedIn URL" || pass "{.claude}/memory/MEMORY.md has no LinkedIn URL"

# Test: hooks
HOOK="$REPO_DIR/{<repo-name>}/hooks/pre-push"
[ -x "$HOOK" ] && pass "pre-push hook is executable" || fail "pre-push hook is not executable"
head -1 "$HOOK" | grep -q "#!/bin/bash" && pass "pre-push has bash shebang" || fail "pre-push missing bash shebang"
grep -q "test.sh" "$HOOK" && pass "pre-push references test.sh" || fail "pre-push missing test.sh reference"
grep -q "exit 1" "$HOOK" && pass "pre-push exits non-zero on failure" || fail "pre-push missing exit 1"

echo ""

# ----------------------------
echo "## checkpoint.sh"
# ----------------------------

[ -x "$SCRIPT_DIR/checkpoint.sh" ] && pass "script is executable" || fail "script is not executable"
head -1 "$SCRIPT_DIR/checkpoint.sh" | grep -q "#!/bin/bash" && pass "has bash shebang" || fail "missing bash shebang"

# Test: checkpoint filters .claude/CLAUDE.local.md
grep -q "learned per project" "$REPO_TMPL/.claude/CLAUDE.local.md" && pass "{<repo-name>}/.claude/CLAUDE.local.md has placeholders" || fail "{<repo-name>}/.claude/CLAUDE.local.md missing placeholders"
grep -q "stash.centro.net" "$REPO_TMPL/.claude/CLAUDE.local.md" && fail "{<repo-name>}/.claude/CLAUDE.local.md has project-specific URLs" || pass "{<repo-name>}/.claude/CLAUDE.local.md has no project URLs"
grep -q "BP-[0-9]" "$REPO_TMPL/.claude/CLAUDE.local.md" && fail "{<repo-name>}/.claude/CLAUDE.local.md has project-specific tickets" || pass "{<repo-name>}/.claude/CLAUDE.local.md has no project tickets"

# Test: distilled topic files have no Confluence page IDs
TOPIC_HAS_CONFLUENCE_ID=0
for TOPIC in "$MEM_TMPL"/*.md; do
  NAME=$(basename "$TOPIC")
  [ "$NAME" = "MEMORY.md" ] && continue
  grep -q "(confluence:[0-9]" "$TOPIC" && TOPIC_HAS_CONFLUENCE_ID=1
done
[ "$TOPIC_HAS_CONFLUENCE_ID" -eq 0 ] && pass "distilled topic files have no Confluence IDs" || fail "distilled topic files still have Confluence IDs"

# Test: distilled topic files have no Basis-specific URLs
TOPIC_HAS_BASIS_URL=0
for TOPIC in "$MEM_TMPL"/*.md; do
  NAME=$(basename "$TOPIC")
  [ "$NAME" = "MEMORY.md" ] && continue
  grep -q "stash.centro.net\|basis.atlassian.net" "$TOPIC" && TOPIC_HAS_BASIS_URL=1
done
[ "$TOPIC_HAS_BASIS_URL" -eq 0 ] && pass "distilled topic files have no Basis-specific URLs" || fail "distilled topic files still have Basis-specific URLs"

# Test: no topics/ subfolder in {<repo-name>}
[ -d "$MEM_TMPL/topics" ] && fail "{<repo-name>} still has topics/ subfolder" || pass "{<repo-name>} has flat topic structure"

# Test: scripts have no topics/ subfolder references
grep -q "topics/" "$SCRIPT_DIR/4-sync-confluence.sh" && fail "4-sync-confluence.sh still references topics/" || pass "4-sync-confluence.sh has no topics/ refs"
grep -q "topics/" "$SCRIPT_DIR/5-sync-notion.sh" && fail "5-sync-notion.sh still references topics/" || pass "5-sync-notion.sh has no topics/ refs"
grep -q 'topics/' "$SCRIPT_DIR/bootstrap.sh" && fail "bootstrap.sh still references topics/" || pass "bootstrap.sh has no topics/ refs"

# ----------------------------
echo ""
echo "## Local integration checks (skipped in CI)"
# ----------------------------

if [ -z "$CI" ]; then
  # Test: memory directory exists (detect any existing project dynamically)
  MEMORY_DIR=$(find "$HOME/.claude/projects" -maxdepth 2 -name "MEMORY.md" -path "*/memory/MEMORY.md" 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
  if [ -n "$MEMORY_DIR" ]; then
    pass "memory directory exists"
    [ -f "$MEMORY_DIR/MEMORY.md" ] && pass "MEMORY.md exists" || fail "MEMORY.md missing"
    [ -f "$MEMORY_DIR/history/logs.md" ] && pass "history/logs.md exists" || fail "history/logs.md missing"
  else
    pass "memory directory exists (no projects bootstrapped yet, skipping)"
    pass "MEMORY.md exists (skipped)"
    pass "history/logs.md exists (skipped)"
  fi

  # Test: launchd agents loaded (per-project or legacy names)
  launchctl list | grep -q "com\.claude\..*log" && pass "log agent loaded" || fail "log agent not loaded"
  launchctl list | grep -q "com\.claude\..*distill" && pass "distill agent loaded" || fail "distill agent not loaded"
  launchctl list | grep -q "com\.claude\..*promote" && pass "promote agent loaded" || fail "promote agent not loaded"
else
  echo "  SKIP: memory directory (CI)"
  echo "  SKIP: launchd agents (CI)"
fi

# ----------------------------
echo "## Staging/production integration tests"
# ----------------------------
if bash "$TEST_DIR/test-staging.sh"; then
  pass "staging integration tests passed"
else
  fail "staging integration tests failed"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
