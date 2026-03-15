---
description: Run Playwright E2E tests for a ticket or feature area
argument_name: spec_or_ticket
---

# Playwright E2E Test Runner

Run Playwright E2E tests against the local dev environment.

## Input

`$ARGUMENTS` can be:
- A ticket number (e.g., `BP-30222`) — runs the full suite, tags screenshots with the ticket
- A spec path (e.g., `chat/`, `artifacts/artifacts.spec.ts`) — runs that specific test
- A project name (e.g., `chat`, `artifacts`, `strategy-workflow`) — runs that project
- Empty — runs the full suite

## Steps

1. **Ensure dev servers are running**
   - Check if ports 3000 and 3001 are listening. If not, start `make alldev` in the background and wait for readiness.

2. **Install Playwright browsers if needed**
   ```bash
   cd frontend && npx playwright install --with-deps chromium 2>/dev/null; cd ..
   ```

3. **Run the tests**
   - If `$ARGUMENTS` looks like a spec path (contains `/` or `.spec.ts`): `make e2e E2E_SPEC=$ARGUMENTS`
   - If `$ARGUMENTS` looks like a project name: `cd frontend && npx playwright test --project=$ARGUMENTS`
   - Otherwise: `make e2e`

4. **Report results**
   - Show pass/fail counts
   - If any tests failed, show the failure details
   - If a ticket was provided, note it for artifact labeling

5. **On failure**, offer to:
   - Open the HTML report: `make e2e-report`
   - View traces for failed tests
   - Re-run with `--debug` flag
