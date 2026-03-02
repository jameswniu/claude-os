# AI Development Tools: Use-Case Library

Source: (internal URL)

[Use-case submission form](https://docs.google.com/forms/d/e/1FAIpQLSdQy40q2uqHJWTFw2ofaONQAS_8qe6bwOvKR7YWHonLvA9sAA/viewform)

# **Overview**

This library contains**** examples of using GitHub Copilot and Claude Code to solve common engineering problems. 

 **Each use case includes:**

  * The specific problem it solves

  * Actual prompts that work

  **How this helps you:**

  * Skip the trial-and-error phase

  * Learn from what's already working for the team

  * Get productive with AI tools faster

  * Discover new ways to use these tools

> Note: Examples for some use-cases in Claude Code only. Same can be done with copilot with similar prompts. 

# Code Generation

### Generate API Endpoint from Description

**Problem**

Need to create a new REST API endpoint with controller, service, validation, and tests. 

Claude Code1800

# prompt 

  Create a new REST endpoint GET /api/users/:userId/orders that:

  * Returns paginated order history for a user

  * Includes validation for userId and pagination params

  * Has proper error handling for user not found

  * Follows the existing pattern in src/controllers/userController.ts

  * Includes unit tests with mocks

  Write the controller, service, route, types, and test files.

**Prompting Best Practices**

  1. Be explicit with your instructions. 

Less Effective Prompt: `Create a new REST endpoint GET /api/users/:userId/orders`

  2. Add Context to improve results, it helps AI tools to better understand your goals and deliver more targeted responses. 

More Effective Prompt, to add: `Follows the existing pattern in src/controllers/userController.ts` or `Follow patterns in current codebase` , etc. 

# Debugging & Error Analysis 

### Analyze Error Message and Stack Trace

**Problem**

Getting an error with stack trace, need to understand root cause and fix it. 

Claude Code1800

# Prompt

I'm getting this error when creating a line item:

  Error: Cannot read property 'campaignId' of undefined

      at LineItemService.validateLineItem (src/services/lineItemService.ts:145)

      at LineItemController.createLineItem (src/controllers/lineItemController.ts:67)

      at async handler (src/middleware/asyncHandler.ts:12)

  Can you:

  1. Read the files in the stack trace

  2. Identify where campaignId should be set but isn't

  3. Show me the bug and suggest a fix

**What Claude will do:**

  * Read all files mentioned in stack trace

  * Trace through the execution flow

  * Identify the root cause

  * Suggest a specific fix

**Additional Tips for Prompt**

  * Adding more context about what the test is supposed to do can help

  * Adding implementation code along side the failure 

  * What you have tried to fix the issue 

  * Add logging to help understand 

    * What values are being passed to functions 

    * the state of a particular object before/after an operation

    * whats in an array/object at failure point 

    * etc. 

### Debug Failing Tests

**Problem**

Run all tests, Analyze failures, and fix them. 

Claude Code1800

# Prompt

Run the test suite with: bundle exec rspec

For the failing tests:

  1. Analyze the failure

  2. Read the test and implementation code

  3. Fix the issue

  4. Rerun tests to verify

Keep iterating until all tests pass

# Can ask it to skip seeds or run specific tests or other specifics as needed 

Skip seeding with SKIP_SEEDS=1 

### Generate Tests for a function

**Problem**

Generate unit tests for a function. 

Claude Code1800

# Prompt

Generate comprehensive unit tests for calculateOrderTotal function in src/services/orderService.ts

Include: 

  * Happy path scenarios

  * Edge cases (empty cart, negative values, null inputs) 

  * error conditions

  * use the same test pattern as src/services/__tests__/userService.test.ts

Create the test file at src/services/__tests__/orderService.test.ts

# Documentation

### Generate README for a Module

**Problem**

Generate a Generic README template for a new module or repository. 

Claude Code1800

# Prompt

Create a README.md for the authentication module at src/auth/ 

Read the actual code in the directory and document: 

  * What the module does

  * How to configure it, including setting it up locally

  * Using examples from the real API 

  * include sections for Tests, Code Linting, etc. 

save to src/auth/README.md

# Can also share an example README for formatting 

Use this example README for formatting : [Insert README text] 

### Add JSDoc/RDoc Comments 

**Problem**

Want to add JSDoc or RDoc documentation for functions in code. 

Claude Code1800

# Prompt

Add comprehensive JSDoc comments to all public methods in src/services/campaignService.ts

Include: 

  * Description

  * @param tags with types

  * @returns description

  * @throws for error conditions

  * @example with actual usage

# Code Review & Refactoring 

### Reviewing Your Changes Before Committing

**Problem**

Review your code changes before commiting for security, performance, code quality, missing error handling, breaking changes, and other issues. 

Claude Code Example1800

# Prompt

Review my uncommitted changes for:

  * Security issues (SQL injection, XSS, auth problems)

  * Performance problems

  * Code quality issues

  * Missing error handling

  * Breaking changes

  Run: git diff

  Then analyze the changes and provide feedback.

# Claude will list out the issues, you can selectively fix issues as you like.

Code Review Feedback Best Practices1800

  1. Be explicit for High Quality Code Review 

Bad: 

Good:

  2. Constraint the Scope

     1. specify what matters (i.e., security, performance, readability, correctness, architecture, etc.) - unconstrained reviews lead to generic advice

     2. what doesn't matter (i.e., naming unless critical, code style, etc.) 

  3. Force evidence-based feedback 

     1. Require line references, concrete examples, why this matters - AI tools can drift into opinions unless told otherwise 

  4. Enforce Design Principles Explicitly

**SOLID**

**Functional Programming**

**API Design**

**Security**

etc…

  5. Ask for uncertainty to be flagged 

     1. instead of confident but wrong statements 

  6. Use Step Based Reviews

  * instead of one big prompt

**Step 1**

> "Summarize what this code does."

**Step 2**

> "Now review it for correctness and edge cases."

**Step 3**

> "Now review it for design principles and maintainability."

This dramatically reduces misunderstandings.

  7. Advanced Techniques 

     1. "Diff-only" reviews 

        1. LLMs do best reviewing changes not entire files 

        2.      2. Ask for Counter Examples 

        1. `For each critical issue, give a concrete scenario where the current code fails.`

     3. Use Checklists 

        1.      4. Write a Claude.md (instructions.md, Agent.md, etc.) or relevant file about Design Principles code follows. This will allow AI tools to give better code reviews. 

Code Review Prompt Template1800

You are a senior <language> engineer performing a rigorous code review.

Context:

  * Language/version:

  * Intended use (prod, internal tool, library, etc.):

  * Performance/security constraints:

  * Team conventions (if any):

Review goals:

  * Correctness

  * Maintainability

  * Adherence to the following principles:

    * <principle 1>

    * <principle 2>

    * <principle 3>

Instructions:

  * Identify concrete issues only (no speculative concerns).

  * Reference exact lines or code snippets.

  * For each issue:

    1. Describe the problem

    2. Explain why it matters

    3. Propose a specific improvement

Output format:

  * Critical issues (must fix)

  * Non-critical issues (should fix)

  * Optional improvements (nice to have)

Here is the code:

### Reviewing others code

**Problem**

Reviewing other coworkers code for quality. 

Suggestions1800

One way to review the code is to checkout the specific branch you are reviewing and ask the AI tool of choice to review the changes in the commits desired. Similar prompts can be used as when reviewing your own code. 

# Prompt in terminal

git diff HEAD~1..HEAD | claude "  
You are a senior engineer.  
Review this commit for:

  * correctness and edge cases

  * code style and clarity

  * performance or security issues

  * missing tests  
Return actionable feedback.  
"

### Refactor a Complex Function

**Problem**

Want to refactor a complex function and split into smaller functions, improve readibility, etc. 

Claude Code1800

# Prompt

The processOrder function in src/services/orderService.ts is too complex (200+ lines).

  Refactor it by:

  * Breaking into smaller functions

  * Improving readability

  * Maintaining the same behavior

  * Updating tests if needed

  Then run the test suite to ensure nothing broke.

### Git Operations

**Problem**

Generate a commit message. 

Claude Code1800

# Prompt

Look at my git diff and suggest a good commit message following our conventional commits format.

Format for message should be as following "[JIRA ticket number] description". 

Create a Pull Request 

Claude Code1800

# Prompt

Create a pull request for my current branch.

  Look at all commits since branching from develop and write a comprehensive PR description including:

  * Summary of changes

  * Why these changes were made

  * Testing done

  * Any breaking changes

  Then run: gh pr create
