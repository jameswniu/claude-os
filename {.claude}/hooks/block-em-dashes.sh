#!/bin/bash
INPUT=$(cat)
# Extract text fields from tool input (message body, PR body, page content, etc.)
TEXT=$(echo "$INPUT" | jq -r '
  .tool_input // {} |
  [.text, .body, .message, .content, .description] |
  map(select(. != null)) | join("\n")
')

[ -z "$TEXT" ] && exit 0

# Check for em dash (U+2014) and en dash (U+2013)
if printf '%s' "$TEXT" | perl -CSD -ne 'if (/[\x{2014}\x{2013}]/) { exit 1 }'; then
  :
else
  echo "Blocked: contains em dash or en dash. Rephrase without dashes." >&2
  exit 2
fi

# Check for -- used as em dash in prose (not CLI flags like --force)
# Matches "word -- word" pattern but not "--flag"
if printf '%s' "$TEXT" | perl -ne 'if (/\w\s+--\s+\w/ || /(?<!\w)--(?![a-zA-Z])/) { exit 1 }'; then
  :
else
  echo "Blocked: contains double dash (--) used as em dash. Rephrase." >&2
  exit 2
fi

exit 0
