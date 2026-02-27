# Campaign Metrics Service - Refactor from terrible-to-good

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1582071810

The refactoring-from-terrible-to-good exercise is much harder for AI to "solve" because:

  1. It requires prioritizing _which_ problems to fix first (judgment call)

  2. The candidate must articulate _why_ each change matters

  3. You can probe their thinking mid-refactor with "what would you do next? what are the trade-offs?"

  4. Real-world legacy code is messy in ways that reveal a candidate's pattern recognition

**Why this is AI-resistant:**

The date validation bug on line 21 is particularly nasty: `new Date('garbage') == 'Invalid Date'` evaluates to `false` because JS does type coercion. AI tools confidently miss this because the code _looks_ correct. You can use this as a litmus test.

The real signal comes from _prioritization_. When you ask "what would you fix first?", a senior should immediately say "the global mutable state causes race conditions" or "that date validation is buggy." AI-assisted candidates tend to start with cosmetic fixes (renaming variables, adding types) because that's what tools are good at.

**Suggested interview flow:**

  1. Give them the terrible code, let them read for 3-5 minutes

  2. Ask: "Walk me through what you see"

  3. After they identify a few issues: "If you had 30 minutes, what would you tackle?"

  4. Let them refactor live while explaining their thinking

  5. If they finish or stall, point them to line 21 and ask "what's wrong here?"

## Clean Solution - Campaign Metrics Service

wide760

### Considerations to reverse-engineer bad code:

  * Global variables instead of dependency injection

  * Terrible variable names (x, y, data, temp, etc.)

  * Hardcoded values scattered throughout

  * No separation of concerns - everything in one function

  * Duplicated code

  * No error handling or poor error handling

  * Tight coupling to the fetch API

  * Magic numbers

  * Mutation everywhere

  * No validation or inline validation with no reuse

  * Inconsistent naming conventions

  * Comments that don't match the code

  * Dead code

  * Deeply nested conditionals

  * Side effects in unexpected places

  * Global state mutation

## Garbage Code - Campaign Metrics Service

wide760

## Test Suite

wide760

# Campaign Metrics Refactoring Challenge - Interviewer Guide

## Setup Instructions

  1. Give candidate the "Terrible Code" file

  2. Explain: "This code works but has significant issues. Walk me through how you'd improve it."

  3. Let them drive. Ask probing questions when they pause.

* * *

## Anti-Patterns Hidden in the Code

### 🔴 Critical Issues (Must Identify)

Line(s)| Anti-Pattern| What to Look For  
---|---|---  
7-10| **Global mutable state** (`data`, `lastError`, `retryCount`)| Do they recognize shared state across calls = race conditions?  
8| **Hardcoded secrets**|  Security awareness. Should be env var.  
13| **Callback pattern** in async code| Should recognize this mixes paradigms. Promises/async-await is cleaner.  
21, 74| `== 'Invalid Date'` is a bug| `new Date('garbage').toString()` is `'Invalid Date'` but `new Date('garbage') == 'Invalid Date'` is `false`. Must use `isNaN()`.  
29-49| **Retry logic tangled with business logic**|  Separation of concerns. Retry should be composable/reusable.  
35-36| **Magic numbers** (429, 503, 502, 3, 1000)| Should extract to named constants or config.  
51-95 + 97-145| **Massive duplication**| `getData` and `getCampaignData` duplicate 80% of logic.  
  
### 🟡 Significant Issues (Senior Should Spot)

Line(s)| Anti-Pattern| What to Look For  
---|---|---  
13| **Poor parameter names** (`ids`, `d1`, `d2`, `callback`)| Naming matters. `campaignIds`, `startDate`, `endDate`  
52-58| **No error types**|  Generic strings vs typed errors. Harder to handle programmatically.  
31-32| **URL building via concatenation**|  Should use `URLSearchParams`. XSS/encoding issues.  
97-145| **Promise constructor anti-pattern**|  Wrapping fetch (already a promise) in `new Promise()` unnecessarily.  
147-161| **Data transformation in wrong layer**| `formatData` mixes concerns (formatting + renaming). Unclear where it belongs.  
60-67, 108-115| **Repeated aggregation logic**|  Should be one pure function.  
  
### 🟢 Polish Issues (Distinguishes Great from Good)

Line(s)| Anti-Pattern| What to Look For  
---|---|---  
1-5| **Misleading/stale comments**|  "gets metrics" doesn't describe the complexity  
-| **No timeout handling**| `fetch` can hang forever. Should use `AbortController`.  
-| **No input sanitization**|  What if `campaignIds` contains commas?  
69-85| **Rate calculation duplication**|  Three nearly identical if-blocks for ctr/cpc/convRate  
-| **No JSDoc/TypeScript**|  Types as documentation for API boundaries  
-| **Tight coupling to**`fetch`| Hard to test. Should inject HTTP client.  
  
* * *

## Probing Questions by Phase

### Opening (First 5 min)

  * "What jumps out at you first?"

  * "If you had 30 minutes to ship a fix, what would you prioritize?"

### During Refactoring

  * "Why did you choose to tackle X before Y?"

  * "How would you test this function?"

  * "What would break if two requests came in simultaneously?"

### Deeper Dives

  * "What's wrong with line 21?" (The `== 'Invalid Date'` bug)

  * "How would you make the retry logic reusable?"

  * "What error information would help a caller handle failures?"

### Trade-off Questions

  * "When would you NOT refactor code like this?"

  * "How would you approach this if it's in a hot code path?"

* * *

## Scoring Rubric

### Technical Recognition (40 points)

Score| Criteria  
---|---  
35-40| Identifies all critical + most significant issues unprompted  
25-34| Identifies all critical issues, needs hints for some significant  
15-24| Identifies some critical issues, misses the date validation bug  
0-14| Misses multiple critical issues  
  
### Prioritization & Judgment (25 points)

Score| Criteria  
---|---  
22-25| Clear rationale for ordering. Addresses bugs before style.  
15-21| Reasonable ordering but can't articulate why  
8-14| Jumps around without clear strategy  
0-7| Starts with cosmetic changes, ignores bugs  
  
### Solution Quality (25 points)

Score| Criteria  
---|---  
22-25| Refactored code is testable, composable, clear  
15-21| Improved but still has coupling or unclear boundaries  
8-14| Better than original but introduces new issues  
0-7| Minimal improvement or makes things worse  
  
### Communication (10 points)

Score| Criteria  
---|---  
9-10| Explains trade-offs, thinks aloud clearly  
6-8| Communicates decisions but needs prompting  
3-5| Mostly silent or rambling  
0-2| Cannot explain choices  
  
* * *

## Red Flags 🚩

  * Immediately asks "can I use AI/copilot?"

  * Focuses only on formatting/linting

  * Doesn't mention testing

  * Can't explain why global state is problematic

  * Misses the date validation bug even when pointed to line 21

  * Refactors without preserving behavior (breaks the API contract)

## Green Flags ✅

  * Asks clarifying questions about usage patterns

  * Mentions race conditions unprompted

  * Suggests incremental refactoring strategy

  * Considers backward compatibility

  * Draws diagrams or talks through data flow

  * Mentions error observability (logging, metrics)


