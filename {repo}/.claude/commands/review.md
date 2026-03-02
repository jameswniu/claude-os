IMPORTANT: You MUST follow every step and the Output Format below EXACTLY. Do not skip steps. Do not freestyle. Do not deviate from this structure.

## Setup

Format: /review {ticket-number}
Examples:
  /review PROJ-123
  /review PROJ-456

### Step 1: Fetch and find the branch
Run: git fetch origin
Run: git branch -r | grep {ticket-number}
This finds the full branch name from just the ticket number.
If multiple branches match, list them and ask which one to review.
If no branches match, report "No remote branch found matching {ticket-number}" and stop.

### Step 2: Auto-detect the target branch
Find what the branch was forked from by checking merge-base against common targets:
Run: git merge-base origin/main origin/{branch}
Run: git merge-base origin/dev origin/{branch}
Then check if any other feature branches are closer ancestors:
Run: git log --oneline origin/{branch} --not origin/main origin/dev --decorate
The target is whichever branch the source was forked from most recently.
Report which target was auto-detected: "Detected target: {target}"

### Step 3: Diff
Run: git diff origin/{target}...origin/{branch} --stat
List every changed file. You will review EVERY file individually.

### Step 4: Regression scan (MANDATORY - DO NOT SKIP)
This step catches feature regressions where a field, property, or behavior is removed that downstream consumers still depend on. This is the highest-value check in the entire review.

Run the entire regression scan as a SINGLE bash script. Do NOT run individual commands per file. Write and execute one script that does everything:

```bash
TARGET="origin/{target}"
BRANCH="origin/{branch}"
SCAN_DIRS="frontend/ src/ tests/"
EXTENSIONS="--include=*.ts --include=*.tsx --include=*.py --include=*.rb --include=*.jsx --include=*.js"

echo "=== REGRESSION SCAN ==="
echo ""

for FILE in $(git diff --name-only $TARGET...$BRANCH -- '*.py' '*.ts' '*.tsx' '*.rb' '*.js' '*.jsx' | grep -v test | grep -v __pycache__); do
  echo "--- Scanning: $FILE ---"

  PARENT_NAMES=$(git show $TARGET:$FILE 2>/dev/null | grep -oE '[a-zA-Z_][a-zA-Z0-9_]*' | sort -u)
  PR_NAMES=$(git show $BRANCH:$FILE 2>/dev/null | grep -oE '[a-zA-Z_][a-zA-Z0-9_]*' | sort -u)

  REMOVED=$(comm -23 <(echo "$PARENT_NAMES") <(echo "$PR_NAMES"))

  if [ -z "$REMOVED" ]; then
    echo "  No names removed."
    echo ""
    continue
  fi

  echo "  Removed names:"
  for NAME in $REMOVED; do
    if [ ${#NAME} -lt 4 ]; then
      continue
    fi
    HITS=$(grep -rl "$NAME" $SCAN_DIRS $EXTENSIONS 2>/dev/null | grep -v "$FILE" | head -5)
    if [ -n "$HITS" ]; then
      echo "  REGRESSION: '$NAME' removed but still referenced by:"
      echo "$HITS" | sed 's/^/    /'
    fi
  done
  echo ""
done

echo "=== END REGRESSION SCAN ==="
```

After the script runs, read the output. Any line starting with "REGRESSION:" is a confirmed feature regression with HIGH impact. Include all regression findings in the Regression Scan Results section of the output.

### Step 5: Per-file review
For EVERY file in the diff, review line by line. For each issue found, trace the implication chain all the way to:
- What happens in the codebase (immediate technical effect)
- What happens in production (runtime behavior)
- What the user sees or loses (missing feature, broken flow, silent data loss)

---

## Issue Categories

| ID                    | Label                  | What to look for                                                        |
|-----------------------|------------------------|-------------------------------------------------------------------------|
| feature-regression    | Feature Regression     | Removed/renamed field, property, event, or behavior that downstream consumers still depend on. Leads to missing features. |
| data-integrity        | Data Integrity         | Orphaned records, empty rows, dangling references, inconsistent state in DB. Silent accumulation over time. |
| error-handling        | Error Handling         | Swallowed exceptions, missing try/catch, fallback paths that lose data or silently degrade. |
| race-condition        | Race Condition         | Async timing issues, classification before execution, shared state across concurrent flows. |
| security              | Security               | Input validation, auth checks, secrets in code, injection risks. |
| logic                 | Logic                  | Off-by-one, wrong conditionals, null access, edge cases not handled. |
| style                 | Style                  | Naming, dead code, complexity, redundancy. Only flag if it causes confusion or maintenance risk. |

## Impact Levels

| Impact | Meaning | Example |
|--------|---------|---------|
| HIGH   | User loses a feature, sees broken UI, or data is corrupted/lost | Removed field breaks frontend display, orphaned artifact shows empty card |
| MEDIUM | Production degrades silently, accumulates tech debt, or error handling has gaps | Empty DB rows accumulate over time, errors swallowed without alerting |
| LOW    | Code quality concern, no user-facing or production impact | Redundant check, constructor complexity, missing comment |

## Review Rules

- Review EVERY file in the diff. Do not skip files.
- For every issue, trace the full implication chain: code -> production -> user.
- REGRESSIONS ARE HIGH IMPACT: If the PR removes, breaks, or changes existing behavior that downstream consumers depend on, this is always HIGH impact. This includes removing fields that frontends read, changing API contracts, dropping events that consumers listen for, or altering return types. A regression means a user loses a feature they had before.
- Step 4 regression scan is MANDATORY. Execute the script exactly as written. Do not modify it. Do not split it into multiple commands. Run it as one script.
- Be specific: reference actual variable/function names and file:line.
- Every issue MUST have an actionable fix with corrected code.
- No false positives: only flag real issues.
- Do NOT penalize for undefined external dependencies.

---

## Output Format

### Summary
2-3 sentence overall assessment. What does this PR do and what is the overall risk.

### Regression Scan Results
Paste the output from the Step 4 script. Highlight any lines with "REGRESSION:" and explain the impact for each.

### Issues

Review every file in the diff. For each issue:

```
#: {number}
File: {filepath}
Line: {line range}
Category: {category from table above}
Impact: {HIGH / MEDIUM / LOW}
Finding: {What's wrong}
Implication: {Trace the chain: code effect -> production behavior -> what user sees or loses}
```

Problematic code:
```
// the code that causes the issue
```

Fix:
```
// corrected code
```

If a file has no issues, report: "{filepath}: No issues found."

### Verdict

Rules:
- Any HIGH impact issue = REQUEST CHANGES. No exceptions.
- MEDIUM impact issues only = APPROVE WITH CONDITIONS. List what must be addressed.
- LOW impact issues only or no issues = APPROVE.

Verdict must include:
1. **Decision** with one-line justification
2. **HIGH/MEDIUM issues** (if any): What exactly is broken, which file/line, what the user loses or what degrades in production
3. **Fix**: Exact code change to resolve each HIGH/MEDIUM issue
4. **Remaining risk**: After fixes, anything else to watch for in production
