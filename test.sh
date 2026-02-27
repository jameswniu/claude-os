#!/bin/bash
# test.sh - Validate scripts without running Claude Code
# Run: bash test.sh

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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
grep -q "log.md" "$SCRIPT_DIR/2-distill.sh" && pass "reads log.md" || fail "missing log.md reference"
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
echo "## Integration checks"
# ----------------------------

# Test: output directory exists
[ -d "$SCRIPT_DIR/output" ] && pass "output directory exists" || fail "output directory missing"

# Test: .gitignore excludes output
grep -q "output/" "$SCRIPT_DIR/.gitignore" && pass ".gitignore excludes output/" || fail "output/ not in .gitignore"

# Test: memory directory exists
MEMORY_DIR="/Users/james.niu/.claude/projects/-Users-james-niu-media-strategy-generator/memory"
[ -d "$MEMORY_DIR" ] && pass "memory directory exists" || fail "memory directory missing"
[ -f "$MEMORY_DIR/MEMORY.md" ] && pass "MEMORY.md exists" || fail "MEMORY.md missing"
[ -f "$MEMORY_DIR/log.md" ] && pass "log.md exists" || fail "log.md missing"

# Test: launchd agents loaded
launchctl list | grep -q "com.claude.memory-log" && pass "log agent loaded" || fail "log agent not loaded"
launchctl list | grep -q "com.claude.memory-distill" && pass "distill agent loaded" || fail "distill agent not loaded"
launchctl list | grep -q "com.claude.memory-promote" && pass "promote agent loaded" || fail "promote agent not loaded"

# Test: no em dashes in README
grep -q "—" "$SCRIPT_DIR/README.md" && fail "README contains em dashes" || pass "README has no em dashes"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
