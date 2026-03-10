#!/bin/bash
# test-staging.sh - Integration tests for checkpoint/bootstrap staging/production split
# Tests the full workflow: checkpoint → staging → push → production
# Usage: bash tests/test-staging.sh

PASS=0
FAIL=0
REAL_REPO="$(cd "$(dirname "$0")/.." && pwd)"

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== Staging/Production Split Tests ==="
echo ""

# ─── Sandbox setup ───────────────────────────────────────────
ORIG_HOME="$HOME"
SANDBOX=$(mktemp -d)
export HOME="$SANDBOX/home"
export SKIP_LAUNCHD=1
mkdir -p "$HOME"

# Fake claude-os git repo with {<repo-name>} template + scripts
CO="$HOME/claude-os"
MEM_TMPL_DIR="$CO/{.claude}/projects/-Users-{<user-name>}-{<repo-name>}/memory"
mkdir -p "$CO/{<repo-name>}/.claude/commands" "$CO/{<repo-name>}/.claude/scripts" "$CO/{<repo-name>}/hooks" "$MEM_TMPL_DIR/history" "$CO/output"
cp -r "$REAL_REPO/{<repo-name>}/.claude/scripts/"* "$CO/{<repo-name>}/.claude/scripts/"

echo "# Seed" > "$CO/{<repo-name>}/.claude/CLAUDE.local.md"
echo '{}' > "$CO/{<repo-name>}/.claude/settings.local.json"
echo "# Seed" > "$MEM_TMPL_DIR/MEMORY.md"
echo "# Seed" > "$MEM_TMPL_DIR/history/logs.md"
printf '#!/bin/bash\necho "hook"\n' > "$CO/{<repo-name>}/hooks/pre-push"
chmod +x "$CO/{<repo-name>}/hooks/pre-push"

cd "$CO"
git init -q
git add -A && git commit -q -m "Initial"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Bare remote for push tests
REMOTE="$SANDBOX/remote.git"
git clone --bare -q "$CO" "$REMOTE"
git remote add origin "$REMOTE" 2>/dev/null
git fetch -q origin
git branch --set-upstream-to="origin/$BRANCH" "$BRANCH" 2>/dev/null

# Dummy checkpoint command so bootstrap skips install.sh
mkdir -p "$HOME/.local/bin"
printf '#!/bin/bash\n' > "$HOME/.local/bin/checkpoint"
chmod +x "$HOME/.local/bin/checkpoint"
export PATH="$HOME/.local/bin:$PATH"

# ─── Fake project with memory files ─────────────────────────
PROJECT="$SANDBOX/my-project"
mkdir -p "$PROJECT/.claude"
SLUG=$(echo "$PROJECT" | tr '/._ ' '-' | sed 's/^//')
MEM="$HOME/.claude/projects/${SLUG}/memory"
mkdir -p "$MEM"

cat > "$PROJECT/CLAUDE.md" << 'EOF'
# Project

## Build & Development Commands

```bash
make dev   # start dev
make test  # run tests
```

## Architecture

- Service A on port 8000

## Testing

- pytest with 85% coverage
EOF

cat > "$PROJECT/.claude/CLAUDE.local.md" << 'EOF'
## PR Review Workflow

- Always fetch origin
- Bitbucket: https://stash.centro.net/rest/api/1.0

## Behavior Rules

- No unsolicited edits

## Environment Constraints

- stash.centro.net base URL
EOF

cat > "$MEM/MEMORY.md" << 'EOF'
# Memory

## Bitbucket API

- Base URL: https://stash.centro.net/rest/api/1.0
- Project and repo: CEN/my-project

## Topic Files (on demand, read when relevant)

Reference docs in the memory directory.
- `code-reviews.md` (confluence:12345) -- review practices
- Synced every 24h. Scripts auto-discover relevant new pages and add them here.

## Recurring Mistakes

- **verdict in pr** Don't add verdict
- **generic mistake** Keep this one

## User Preferences

- Brief, direct communication
EOF

mkdir -p "$MEM/history"
cat > "$MEM/history/logs.md" << 'EOF'
# Logs
- 2024-01-01: Did some work
EOF

cat > "$MEM/code-reviews.md" << 'EOF'
# Code Reviews (confluence:99999)

Review best practices from https://stash.centro.net/wiki/reviews
EOF

# ═══════════════════════════════════════════════════════════════
echo "## 1. Checkpoint → staging → push → production"
# ═══════════════════════════════════════════════════════════════

cd "$PROJECT"
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/5-checkpoint.sh" 2>&1)
RC=$?

[ "$RC" -eq 0 ] && pass "checkpoint exits 0" || fail "checkpoint exits $RC"
echo "$OUT" | grep -q "Checkpoint committed locally" && pass "staging commit confirmed" || fail "missing staging message"
echo "$OUT" | grep -q "git push" && pass "push reminder shown" || fail "missing push reminder"

# Verify commit exists
cd "$CO"
git log --oneline -1 | grep -q "Checkpoint" && pass "commit in git log" || fail "no checkpoint commit"

# Verify unpushed (staging only)
AHEAD=$(git rev-list --count "origin/$BRANCH..$BRANCH" 2>/dev/null)
[ "$AHEAD" -gt 0 ] && pass "commit is unpushed (staging)" || fail "expected unpushed commit"

# Push to production
git push -q origin "$BRANCH" 2>&1
AHEAD=$(git rev-list --count "origin/$BRANCH..$BRANCH" 2>/dev/null)
[ "$AHEAD" -eq 0 ] && pass "push syncs to production" || fail "still ahead after push"

# Verify template filtering
grep -q "stash.centro.net" "$CO/{<repo-name>}/.claude/CLAUDE.local.md" && fail ".claude/CLAUDE.local.md has project URLs" || pass ".claude/CLAUDE.local.md filtered"
grep -q "learned per project" "$MEM_TMPL_DIR/MEMORY.md" && pass "MEMORY.md has placeholders" || fail "MEMORY.md missing placeholders"
grep -q "confluence:" "$MEM_TMPL_DIR/MEMORY.md" && fail "MEMORY.md has confluence IDs" || pass "MEMORY.md IDs stripped"
grep -q "confluence:" "$MEM_TMPL_DIR/code-reviews.md" && fail "topic file has confluence IDs" || pass "topic file IDs stripped"
grep -q "stash.centro.net" "$MEM_TMPL_DIR/code-reviews.md" && fail "topic file has project URLs" || pass "topic file URLs filtered"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 2. Bootstrap pulls latest"
# ═══════════════════════════════════════════════════════════════

# Structural check: git pull runs before file copies
PULL_LINE=$(grep -n "git pull" "$CO/{<repo-name>}/.claude/scripts/6-bootstrap.sh" | head -1 | cut -d: -f1)
COPY_LINE=$(grep -n "seed_file.*CLAUDE" "$CO/{<repo-name>}/.claude/scripts/6-bootstrap.sh" | head -1 | cut -d: -f1)
[ "$PULL_LINE" -lt "$COPY_LINE" ] && pass "git pull precedes file copies" || fail "git pull does not precede copies"

# Run bootstrap on fresh project
BP="$SANDBOX/bootstrap-project"
mkdir -p "$BP" && cd "$BP" && git init -q
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/6-bootstrap.sh" 2>&1)
[ -f "$BP/.claude/CLAUDE.local.md" ] && pass "bootstrap creates .claude/CLAUDE.local.md" || fail "missing .claude/CLAUDE.local.md"
echo "$OUT" | grep -q "CREATED.*CLAUDE.local.md" && pass "bootstrap creates (not overwrites) files" || fail "bootstrap not creating files"
[ -f "$BP/.git/hooks/pre-push" ] && pass "bootstrap deploys pre-push hook" || fail "missing .git/hooks/pre-push"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 3. Checkpoint no changes"
# ═══════════════════════════════════════════════════════════════

cd "$PROJECT"
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/5-checkpoint.sh" 2>&1)
RC=$?

[ "$RC" -eq 0 ] && pass "no-change exits 0" || fail "no-change exits $RC"
echo "$OUT" | grep -q "No changes" && pass "prints 'No changes.'" || fail "missing no-change message"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 4. Bootstrap cd handling"
# ═══════════════════════════════════════════════════════════════

CD_TEST="$SANDBOX/cd-test"
mkdir -p "$CD_TEST" && cd "$CD_TEST" && git init -q
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/6-bootstrap.sh" 2>&1)

echo "$OUT" | grep -q "Project: $CD_TEST" && pass "PROJECT is caller's pwd" || fail "PROJECT is wrong"
[ -f "$CD_TEST/.claude/CLAUDE.local.md" ] && pass "files in caller's dir" || fail "files in wrong dir"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 5. Checkpoint from bad dir"
# ═══════════════════════════════════════════════════════════════

BAD=$(mktemp -d)
cd "$BAD"
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/5-checkpoint.sh" 2>&1)
RC=$?

[ "$RC" -eq 1 ] && pass "bad-dir exits 1" || fail "bad-dir exits $RC (expected 1)"
echo "$OUT" | grep -qi "no memory" && pass "error mentions memory" || fail "missing error message"
rm -rf "$BAD"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 6. Bootstrap git pull already up-to-date"
# ═══════════════════════════════════════════════════════════════

UP="$SANDBOX/uptodate"
mkdir -p "$UP" && cd "$UP" && git init -q
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/6-bootstrap.sh" 2>&1)
RC=$?

[ "$RC" -eq 0 ] && pass "up-to-date bootstrap exits 0" || fail "exits $RC"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 7. git pull errors suppressed (no remote)"
# ═══════════════════════════════════════════════════════════════

cd "$CO" && git remote remove origin 2>/dev/null

NR="$SANDBOX/no-remote"
mkdir -p "$NR" && cd "$NR" && git init -q
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/6-bootstrap.sh" 2>&1)
RC=$?

[ "$RC" -eq 0 ] && pass "no-remote bootstrap exits 0" || fail "exits $RC"
echo "$OUT" | grep -qi "fatal\|error.*pull" && fail "git pull error leaked" || pass "errors suppressed"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 8. logs.md merge preserves both repos"
# ═══════════════════════════════════════════════════════════════

# Simulate two sequential checkpoints from different repos with different log entries

# Reset template logs to empty
echo "# Session Log" > "$MEM_TMPL_DIR/history/logs.md"

# First "repo" has entry A
PROJ_A="$SANDBOX/repo-a"
mkdir -p "$PROJ_A/.claude"
SLUG_A=$(echo "$PROJ_A" | tr '/._ ' '-' | sed 's/^//')
MEM_A="$HOME/.claude/projects/${SLUG_A}/memory/history"
mkdir -p "$MEM_A"
echo "# Memory" > "$(dirname "$MEM_A")/MEMORY.md"
cat > "$MEM_A/logs.md" << 'EOF'
# Session Log

## 2026-03-01

- Repo A unique entry alpha
- Shared entry both repos have

## 2026-03-02

- Repo A day two work
EOF

cd "$PROJ_A"
bash "$CO/{<repo-name>}/.claude/scripts/5-checkpoint.sh" > /dev/null 2>&1

# Second "repo" has entry B (some overlap, some new)
PROJ_B="$SANDBOX/repo-b"
mkdir -p "$PROJ_B/.claude"
SLUG_B=$(echo "$PROJ_B" | tr '/._ ' '-' | sed 's/^//')
MEM_B="$HOME/.claude/projects/${SLUG_B}/memory/history"
mkdir -p "$MEM_B"
# Also need MEMORY.md for the checkpoint script to find the memory dir
mkdir -p "$(dirname "$MEM_B")"
echo "# Memory" > "$(dirname "$MEM_B")/MEMORY.md"
cat > "$MEM_B/logs.md" << 'EOF'
# Session Log

## 2026-03-01

- Repo B unique entry beta
- Shared entry both repos have

## 2026-03-03

- Repo B day three work
EOF

cd "$PROJ_B"
bash "$CO/{<repo-name>}/.claude/scripts/5-checkpoint.sh" > /dev/null 2>&1

# Verify template has entries from both repos
LOGS="$MEM_TMPL_DIR/history/logs.md"
grep -q "Repo A unique entry alpha" "$LOGS" && pass "logs.md has repo A entry" || fail "logs.md missing repo A entry"
grep -q "Repo B unique entry beta" "$LOGS" && pass "logs.md has repo B entry" || fail "logs.md missing repo B entry"
grep -q "Repo A day two" "$LOGS" && pass "logs.md has repo A day 2" || fail "logs.md missing repo A day 2"
grep -q "Repo B day three" "$LOGS" && pass "logs.md has repo B day 3" || fail "logs.md missing repo B day 3"
# Shared line should appear only once
SHARED_COUNT=$(grep -c "Shared entry both repos have" "$LOGS")
[ "$SHARED_COUNT" -eq 1 ] && pass "shared line not duplicated" || fail "shared line duplicated ($SHARED_COUNT times)"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 9. MEMORY.md respects line cap"
# ═══════════════════════════════════════════════════════════════

# Create a project with a huge MEMORY.md (300+ lines)
PROJ_BIG="$SANDBOX/big-mem"
mkdir -p "$PROJ_BIG/.claude"
SLUG_BIG=$(echo "$PROJ_BIG" | tr '/._ ' '-' | sed 's/^//')
MEM_BIG="$HOME/.claude/projects/${SLUG_BIG}/memory"
mkdir -p "$MEM_BIG/history"
echo "# Session Log" > "$MEM_BIG/history/logs.md"

# Generate a MEMORY.md with 300 lines
{
  echo "# Memory"
  echo ""
  echo "## Section One"
  echo ""
  for i in $(seq 1 100); do echo "- Line $i of section one"; done
  echo ""
  echo "## Section Two"
  echo ""
  for i in $(seq 1 100); do echo "- Line $i of section two"; done
  echo ""
  echo "## Section Three"
  echo ""
  for i in $(seq 1 100); do echo "- Line $i of section three"; done
} > "$MEM_BIG/MEMORY.md"

BIG_LINES=$(wc -l < "$MEM_BIG/MEMORY.md")

# Reset template MEMORY.md
echo "# Seed" > "$MEM_TMPL_DIR/MEMORY.md"

cd "$PROJ_BIG"
bash "$CO/{<repo-name>}/.claude/scripts/5-checkpoint.sh" > /dev/null 2>&1

TMPL_LINES=$(wc -l < "$MEM_TMPL_DIR/MEMORY.md")
[ "$TMPL_LINES" -le 200 ] && pass "MEMORY.md capped at 200 lines ($TMPL_LINES)" || fail "MEMORY.md exceeds 200 lines ($TMPL_LINES)"
[ "$BIG_LINES" -gt 200 ] && pass "source was over 200 lines ($BIG_LINES)" || fail "source was not big enough ($BIG_LINES)"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 10. CLAUDE.local.md respects line cap"
# ═══════════════════════════════════════════════════════════════

# Create a project with an oversized CLAUDE.local.md (200 lines)
PROJ_CL="$SANDBOX/big-cl"
mkdir -p "$PROJ_CL/.claude"
SLUG_CL=$(echo "$PROJ_CL" | tr '/._ ' '-' | sed 's/^//')
MEM_CL="$HOME/.claude/projects/${SLUG_CL}/memory"
mkdir -p "$MEM_CL/history"
echo "# Session Log" > "$MEM_CL/history/logs.md"
echo "# Memory" > "$MEM_CL/MEMORY.md"

# Generate a CLAUDE.local.md with 200 lines
{
  echo "## Section One"
  echo ""
  for i in $(seq 1 95); do echo "- Rule $i of section one"; done
  echo ""
  echo "## Section Two"
  echo ""
  for i in $(seq 1 100); do echo "- Rule $i of section two"; done
} > "$PROJ_CL/.claude/CLAUDE.local.md"

CL_SRC_LINES=$(wc -l < "$PROJ_CL/.claude/CLAUDE.local.md")

# Reset template CLAUDE.local.md
echo "# Seed" > "$CO/{<repo-name>}/.claude/CLAUDE.local.md"

cd "$PROJ_CL"
OUT=$(bash "$CO/{<repo-name>}/.claude/scripts/5-checkpoint.sh" 2>&1)

TMPL_CL_LINES=$(wc -l < "$CO/{<repo-name>}/.claude/CLAUDE.local.md")
[ "$TMPL_CL_LINES" -le 150 ] && pass "CLAUDE.local.md capped at 150 lines ($TMPL_CL_LINES)" || fail "CLAUDE.local.md exceeds 150 lines ($TMPL_CL_LINES)"
[ "$CL_SRC_LINES" -gt 150 ] && pass "source was over 150 lines ($CL_SRC_LINES)" || fail "source was not big enough ($CL_SRC_LINES)"
echo "$OUT" | grep -q "WARNING.*CLAUDE.local.md.*200 lines" && pass "checkpoint warns about CLAUDE.local.md over limit" || fail "missing CLAUDE.local.md over-limit warning"

echo ""

# ─── Cleanup ─────────────────────────────────────────────────
export HOME="$ORIG_HOME"
rm -rf "$SANDBOX"

echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
