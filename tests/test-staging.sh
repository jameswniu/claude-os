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

# Fake claude-os git repo with scripts + minimal EXAMPLES seed
CO="$HOME/claude-os"
mkdir -p "$CO/EXAMPLES/memory" "$CO/EXAMPLES/.claude/commands" "$CO/output"
cp -r "$REAL_REPO/scripts" "$CO/"

echo "# Seed" > "$CO/EXAMPLES/.claude/CLAUDE.md"
echo '{}' > "$CO/EXAMPLES/.claude/settings.local.json"
echo "# Seed" > "$CO/EXAMPLES/memory/MEMORY.md"
echo "# Seed" > "$CO/EXAMPLES/memory/logs.md"

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
SLUG=$(echo "$PROJECT" | tr '/.' '-' | sed 's/^//')
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

cat > "$PROJECT/.claude/CLAUDE.md" << 'EOF'
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

cat > "$MEM/logs.md" << 'EOF'
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
OUT=$(bash "$CO/scripts/5-checkpoint.sh" 2>&1)
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

# Verify EXAMPLES filtering
grep -q "stash.centro.net" "$CO/EXAMPLES/.claude/CLAUDE.md" && fail ".claude/CLAUDE.md has project URLs" || pass ".claude/CLAUDE.md filtered"
grep -q "learned per project" "$CO/EXAMPLES/memory/MEMORY.md" && pass "MEMORY.md has placeholders" || fail "MEMORY.md missing placeholders"
grep -q "confluence:" "$CO/EXAMPLES/memory/MEMORY.md" && fail "MEMORY.md has confluence IDs" || pass "MEMORY.md IDs stripped"
grep -q "confluence:" "$CO/EXAMPLES/memory/code-reviews.md" && fail "topic file has confluence IDs" || pass "topic file IDs stripped"
grep -q "stash.centro.net" "$CO/EXAMPLES/memory/code-reviews.md" && fail "topic file has project URLs" || pass "topic file URLs filtered"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 2. Bootstrap pulls latest"
# ═══════════════════════════════════════════════════════════════

# Structural check: git pull runs before file copies
PULL_LINE=$(grep -n "git pull" "$CO/scripts/6-bootstrap.sh" | head -1 | cut -d: -f1)
COPY_LINE=$(grep -n "cp.*CLAUDE.md" "$CO/scripts/6-bootstrap.sh" | head -1 | cut -d: -f1)
[ "$PULL_LINE" -lt "$COPY_LINE" ] && pass "git pull precedes file copies" || fail "git pull does not precede copies"

# Run bootstrap on fresh project
BP="$SANDBOX/bootstrap-project"
mkdir -p "$BP" && cd "$BP" && git init -q
OUT=$(bash "$CO/scripts/6-bootstrap.sh" 2>&1)
[ -f "$BP/.claude/CLAUDE.md" ] && pass "bootstrap creates .claude/CLAUDE.md" || fail "missing .claude/CLAUDE.md"
echo "$OUT" | grep -q "CREATED.*CLAUDE.md" && pass "bootstrap creates (not overwrites) files" || fail "bootstrap not creating files"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 3. Checkpoint no changes"
# ═══════════════════════════════════════════════════════════════

cd "$PROJECT"
OUT=$(bash "$CO/scripts/5-checkpoint.sh" 2>&1)
RC=$?

[ "$RC" -eq 0 ] && pass "no-change exits 0" || fail "no-change exits $RC"
echo "$OUT" | grep -q "No changes" && pass "prints 'No changes.'" || fail "missing no-change message"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 4. Bootstrap cd handling"
# ═══════════════════════════════════════════════════════════════

CD_TEST="$SANDBOX/cd-test"
mkdir -p "$CD_TEST" && cd "$CD_TEST" && git init -q
OUT=$(bash "$CO/scripts/6-bootstrap.sh" 2>&1)

echo "$OUT" | grep -q "Project: $CD_TEST" && pass "PROJECT is caller's pwd" || fail "PROJECT is wrong"
[ -f "$CD_TEST/.claude/CLAUDE.md" ] && pass "files in caller's dir" || fail "files in wrong dir"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 5. Checkpoint from bad dir"
# ═══════════════════════════════════════════════════════════════

BAD=$(mktemp -d)
cd "$BAD"
OUT=$(bash "$CO/scripts/5-checkpoint.sh" 2>&1)
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
OUT=$(bash "$CO/scripts/6-bootstrap.sh" 2>&1)
RC=$?

[ "$RC" -eq 0 ] && pass "up-to-date bootstrap exits 0" || fail "exits $RC"

echo ""

# ═══════════════════════════════════════════════════════════════
echo "## 7. git pull errors suppressed (no remote)"
# ═══════════════════════════════════════════════════════════════

cd "$CO" && git remote remove origin 2>/dev/null

NR="$SANDBOX/no-remote"
mkdir -p "$NR" && cd "$NR" && git init -q
OUT=$(bash "$CO/scripts/6-bootstrap.sh" 2>&1)
RC=$?

[ "$RC" -eq 0 ] && pass "no-remote bootstrap exits 0" || fail "exits $RC"
echo "$OUT" | grep -qi "fatal\|error.*pull" && fail "git pull error leaked" || pass "errors suppressed"

echo ""

# ─── Cleanup ─────────────────────────────────────────────────
export HOME="$ORIG_HOME"
rm -rf "$SANDBOX"

echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
