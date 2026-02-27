# Plugin Marketplace Plan

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1527939210

**Driver**|  Primary:  Secondary:   
---|---  
**Approver**|   
**Additional Contributors**|   
**Informed**|  @ stakeholders  
**Objective**|  Create a comprehensive framework to empower Engineers to build AI-enabled development workflows through a Claude Plugin Marketplace.  
**Due date**|   
**Key outcomes**| 

  * Apps Engineering organization using the Plugin Marketplace
  * Contributors adding to the Plugin Marketplace
  * Gather survey feedback on impact in efficiency.

  
**Status**|  not started / in progress / complete  
  
##  Problem statement

Claude Code Plugin Marketplaces provide a way to create a shared set of AI based tools for use across the organization. They are specific to Claude Code and support Claude-specific entities, including commands, agents, hooks, skills, and MCP servers. These entities improve the developer experience with Claude Code by enabling on-demand or automated invocation of predefined organization-specific instructions, ensuring that Claude Code output incorporates internal best practices in a more targeted way.

##  Scope

**Must have:**| 

  * Plugin Marketplace Repository
    * Plugin
      * Commands
        * example
      * Agents
        * example
      * Hooks
        * example
      * Skills
        * example
      * MCP Servers
        * example
    * Investigate how to use with GitHub Copilot
    * How-to guide for Claude
    * How-to guide for Github Copilot

  
---|---  
**Nice to have:**| 

  * Add an `Implement Jira ticket` Command

  
**Not in scope:**|   
  
##   Tasks

**Milestone**| **Owner**| **Deadline**| **Status**| **Notes**  
---|---|---|---|---  
Create an [experimental Plugin Marketplace](https://stash.centro.net/projects/CEN/repos/ai-council/pull-requests/2/overview)|  | | complete| [link](https://stash.centro.net/projects/CEN/repos/ai-council/browse/plugins/react-best-practices)  
Create an official Plugin Marketplace - Dedicated repo|  | | Complete| [link](https://stash.centro.net/projects/CEN/repos/apps-eng-ai-dev-tools/browse)  
Create a Contributing and Usage How-to guide for Claude Code|  | | not started|   
~~Investigate multi-platform feasibility. Using with Copilot (Gemini etc.)~~|  | | Cancelled|   
~~Create a How-to guide for Github Copilot~~| | |  Cancelled|   
Add [AGENTS.md files to centro-media-manager](https://stash.centro.net/projects/CEN/repos/centro-media-manager/pull-requests/30144/overview)|  | | Complete| [link](https://stash.centro.net/projects/CEN/repos/centro-media-manager/pull-requests/30144/overview)  
Add a `Create Jira ticket` [Command](https://stash.centro.net/projects/CEN/repos/ai-council/browse/.claude/commands/create-ticket.md)|  | | complete| [link](https://stash.centro.net/projects/CEN/repos/ai-council/browse/.claude/commands/create-ticket.md)  
Add a `Code Review` Agent|  | | in progress| [link](https://stash.centro.net/projects/CEN/repos/apps-eng-ai-dev-tools/pull-requests/3/overview)  
Add a Hook example|  | | not started|   
Add a Skill example|  | | complete| [link](https://stash.centro.net/projects/CEN/repos/apps-eng-ai-dev-tools/browse/plugins/commit-commands/skills/jira-commit-format/SKILL.md)  
Get confirmation of Claude Code org access|  | | complete| Rolled out around   
Define requirements for submitting PRs to the AI-tools repo| | | in progress|   
Add ai-council as required-reviewers for the ai-tools repo|  | | complete|   
Add namespacing to plugin marketplace resources| | | not started|   
  
##  Related links

<https://code.claude.com/docs/en/plugin-marketplaces>

