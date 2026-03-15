---
name: Microsoft Graph Transcript Workflow
description: Teams meeting transcript pipeline via Graph API and Stream browser extraction fallback - search, download, parse VTT files, upload extracted transcripts to OneDrive
type: reference
---

## How It Works

Teams transcripts are stored in two places:
1. **OneDrive .vtt files** - searchable via Graph API (under `Recordings/` folders)
2. **Stream backend** - only accessible via SharePoint internal API with browser cookies

The `/transcript` skill handles both paths transparently. Graph API search is tried first; if no results, browser extraction from Stream is offered as a fallback.

**API approach:** Microsoft Search API finds `.vtt` files across the Basis tenant (~73 total as of 2026-03-12). Download via `/drives/{drive-id}/items/{item-id}/content`. Calendar API (`/me/calendarView`) returns meetings with online meeting join URLs for correlation.

## Token

- **Location:** `~/.graph-token`
- **Source:** Graph Explorer (https://developer.microsoft.com/en-us/graph/graph-explorer)
- **Lifetime:** ~24 hours from creation
- **Required scopes:** `Files.ReadWrite.All`, `Sites.ReadWrite.All`, `Calendars.Read`
- **On 401 or near-expiry:** Tell user immediately:
  > Graph token expired. Refresh at https://developer.microsoft.com/en-us/graph/graph-explorer then save to `~/.graph-token`
- After refresh, decode JWT to get new `exp` claim and note it

## CLI Tool

**Path:** `~/bin/graph-transcript`

```
graph-transcript search <query>                          # Search .vtt transcripts
graph-transcript download <driveId> <itemId> [file.vtt]  # Download transcript
graph-transcript calendar [YYYY-MM-DD]                   # Show calendar events for date
graph-transcript recent [count]                          # Most recent transcripts
```

The CLI stays Graph-API-only. Browser extraction is inherently interactive and requires Claude's browser tools.

## Browser Extraction (Stream Fallback)

For transcripts only stored in Stream's backend (not as .vtt in OneDrive). Requires the Chrome browser extension.

### Prerequisites
- Chrome browser with Claude extension connected
- User logged into SharePoint/Stream in the browser
- A Stream URL (e.g., `https://centrohub-my.sharepoint.com/personal/{user}/_layouts/15/stream.aspx?id=...`)

### Pipeline

1. **Navigate** to Stream URL
2. **Extract IDs** from `videomanifest` network requests:
   - URL-decode the `docid` parameter
   - driveId = segment after `/drives/`
   - itemId = segment after `/items/` (before `?`)
3. **List transcripts:** GET `/_api/v2.0/drives/{driveId}/items/{itemId}/media/transcripts` (Accept: application/json)
4. **Download VTT:** GET `/_api/v2.0/drives/{driveId}/items/{itemId}/media/transcripts/{transcriptId}/streamContent` (Accept: text/vtt)
5. **Upload to OneDrive:**
   - POST `/_api/contextinfo` to get `FormDigestValue`
   - POST VTT blob to `/_api/web/GetFolderByServerRelativePath(decodedurl='/personal/james_niu_basis_com/Documents/Recordings')/Files/add(url='{fileName}',overwrite=true)` with `X-RequestDigest` header
6. **Verify** via `graph-transcript search`

### API Endpoints

| Step | Method | URL | Headers |
|------|--------|-----|---------|
| List transcripts | GET | `centrohub-my.sharepoint.com/_api/v2.0/drives/{driveId}/items/{itemId}/media/transcripts` | Accept: application/json |
| Download VTT | GET | `.../{transcriptId}/streamContent` | Accept: text/vtt (MUST be text/vtt, not application/json) |
| Form digest | POST | `centrohub-my.sharepoint.com/personal/james_niu_basis_com/_api/contextinfo` | Accept: application/json |
| Upload file | POST | `.../_api/web/GetFolderByServerRelativePath(...)/Files/add(...)` | X-RequestDigest: {digest}, Accept: application/json |

### Endpoints That Do NOT Work
- `/_api_cached/v2.1/drives/.../media/transcripts` - 403 (Time-Limited URL validation failed)
- `/personal/.../_api/mediats/TranscriptInfo` - 404
- `/personal/.../_api/SP.MediaTranscription.TranscriptClientService/GetTranscripts` - 403
- `/_api/v2.0/me/drive/root:{path}:/content` via PUT - 401 (invalidRequestDigest) - Vroom upload does not work; must use SharePoint REST API with form digest

## API Gotchas

- URL-encode `!` as `%21` in SharePoint drive IDs (the CLI does this automatically)
- Search uses `filetype:vtt AND (<query>)` via Microsoft Search `/search/query` POST endpoint
- Download follows redirects (`curl -L`) for the content endpoint
- **OneDrive VTT files** contain `[SPEAKER_N]` IDs and timestamps in `HH:MM.SSS --> HH:MM.SSS` format
- **Stream-extracted VTTs** have NO `[SPEAKER_N]` labels - just raw text and timestamps. Cue IDs use `{guid}/{segment-number}` format (the number is a segment counter, not a speaker ID). Line endings are `\r\n`.
- Stream transcript metadata reports `transcriptType: "subtitle"` and `displayName` ending in `.json`, but `streamContent` with `Accept: text/vtt` returns proper VTT format
- Browser cookies provide auth for Stream API endpoints; Graph API tokens cannot hit `/_api/v2.0` endpoints directly (wrong audience/scope)
- Stream UI disables the download button for non-owners, but the API does not enforce that restriction

## Known Constraints

- Transcription must be manually started during the Teams meeting (not automatic)
- `OnlineMeetings.Read` scope is blocked by Basis tenant admin; use file search instead
- `Directory.Read.All` (org chart) requires IT admin consent; don't re-attempt
- Lavender Team Stand organizer: Kyle Bernstein
- Stream extraction requires Chrome extension and interactive browser session (cannot be scripted in bash)
- Upload target is always james_niu's OneDrive Recordings folder (`/personal/james_niu_basis_com/Documents/Recordings`)
- Recordings folder Graph API item ID: `01MMHNJO4TQNMIZZQPBVB3TIEJ62RPYLSY`

## Use Cases

When a transcript is available, Claude can:

- **Meeting summary**: Parse VTT, extract key decisions, action items, blockers, owners
- **JIRA ticket creation**: Task mentioned in meeting -> create ticket via JIRA API
- **Lucidchart updates**: Architecture discussion -> update diagrams via Lucid MCP
- **Slack digest**: Post meeting highlights to `#lavender-tangerine-dev` via Slack MCP
- **Calendar correlation**: Match transcript files to calendar events by subject/date
- **Cross-org search**: Find who discussed a topic across any team's recordings
- **Stream extraction**: Extract transcripts from recordings that aren't in OneDrive via browser automation
