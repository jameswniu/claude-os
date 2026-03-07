When the user provides a ticket (XML, screenshot, copy-paste, any format):

## Step 1: Extract ticket info
- Extract the ticket ID (e.g., BP-29293) and title from whatever format was provided
- Derive branch name: `{TICKET_ID}_{snake_cased_short_title}`
  - Example: BP-29293 "Get Line Items Tool" -> `BP-29293_get_line_items_tool`

## Step 2: Git setup (run without asking for confirmation)
1. Check working tree: `git status --porcelain`
2. If dirty: `git stash --include-untracked`
3. Update dev: `git fetch origin dev && git checkout dev && git pull origin dev`
4. Create branch: `git checkout -b {branch_name}`
5. If stashed: `git stash pop`

Edge cases:
- Already on a branch matching this ticket: skip, inform user
- Branch name already exists locally: inform user, don't force-create

## Step 3: Summarize
- Summarize the ticket requirements
- Ask the user what to work on first
