# AI Generated PR Summaries

Source: (internal URL)

# [PR Descriptions POC]((internal URL))

### Potential Solutions

#### Built-In Feature

[Bitbucket Cloud Pull Request Descriptions AI](https://www.atlassian.com/blog/bitbucket/generate-pull-request-descriptions-with-atlassian-intelligence#:~:text=AI%2Dassisted%20pull%20request%20descriptions%20are%20part%20of%20the%20Atlassian,accept%20the%20terms%20of%20service.) \- Bitbucket Cloud AI [writing assistant](https://support.atlassian.com/bitbucket-cloud/docs/use-atlassian-intelligence-to-help-write-or-edit-content/)

  * 

This feature exists in Bitbucket Cloud. We use Bitbucket Server (Data Center) and likely **cannot use this feature** unless we migrate to Bitbucket Cloud. We need to contact the Atlassian Team (Frieda) to see if any AI features can be enabled in our Bitbucket. <(internal URL)

### Custom Solution

If we cannot access the built-in feature, we can implement the following:

  * Create a Harness pipeline

    * Extract the following information:

      * git diff

      * git commit comments

      * Jira ticket numbers and descriptions

      * PR comments

    * Run the data through an AI

      * Any AI can be used, start with current Copilot

        * Test with Claude

      * Post the generated description in the PR comments

    * Implement constraints on the data

      * Some PRs are large; we want to avoid exhausting limits on a few PRs

        * Limit context per file to 30 lines and files to 10

      * Allow users to add context via a PR comment

  * Create a Trigger

    * Trigger on manual action

      * Avoid using PR Buttons (custom feature)

      * For example, trigger when user comments "AI-Desc" on their own PR

  * Implement on any repo but start small

    * Pilot with a team managing a microservice

    * Then try it on CMM quickly

### Additional Context

  * GitHub Copilot PR summaries feature <https://docs.github.com/en/enterprise-cloud@latest/copilot/how-tos/use-copilot-for-common-tasks/create-a-pr-summary>

    *   * GitHub Copilot PR summaries responsible use<https://docs.github.com/en/copilot/responsible-use/pull-request-summaries>

    * Risks:

      * Processing time (40+ seconds)

      * Inaccurate responses

      * Manually regenerating summaries after PR updates
