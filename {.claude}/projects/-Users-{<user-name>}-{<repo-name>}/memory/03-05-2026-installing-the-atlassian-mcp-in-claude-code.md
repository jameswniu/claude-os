# 03/05/2026 Installing the Atlassian MCP in Claude Code

Source: (internal URL)

[Atlassian MCP](https://www.atlassian.com/blog/announcements/remote-mcp-server)

This guide walks you through connecting the Atlassian MCP (Model Context Protocol) server to Claude Code. Once set up, Claude can read and interact with your Jira tickets and Confluence pages directly from your terminal, no more context switching between your editor and browser. The whole setup takes about 5 minutes.

## Installation

  1. In your terminal, run `claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse`

  2. Then start Claude and enter `/mcp` and press enter on `atlassian` under `Local MCPs`

  3. Press enter on `Authenticate`

  4. In the Atlassian Rovo MCP server window select make sure both Jira and Confluence are selected and select `Approve`

  5. Make sure `Use app on` is set to `(internal) and select `Accept`

  6. Finally, you will see the following window

## Usage

Open Claude and run a command including a Jira ticket or a link to a Jira/Confluence page. For example:
