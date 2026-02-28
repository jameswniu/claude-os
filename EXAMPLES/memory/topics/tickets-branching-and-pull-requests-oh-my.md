# Tickets, Branching and Pull Requests Oh My!

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/35815828

This guide is intended to provide a general workflow for those making contributions to the codebase.  

### For the ticket owner:

  1. **You're assigned a ticket**
     1. Review the ticket and ask questions if details are not clear or you don't understand the task.  Different teams will likely handle the before-coding phase of a ticket differently.
     2. **Make sure that the epic contains links to project documentation** (if the ticket is part of an epic) including the Product Discovery Brief in Confluence, any clickable prototypes or mocks, and any RFC.
        1. This will help to streamline the review process, as well as ensure there is a permanent record of these decisions and artifacts in a well known place.
     3. **Create a RFC if this feature has multiple tickets or contains a major change (or if it is part of a Milestone)**
        1. It's helpful to run your approach by the team before executing
        2. [RFC Guidelines](https://stash.centro.net/projects/CEN/repos/apps_eng_docs/browse/rfcs/README.md)
  2. **Create a branch with the JIRA ticket in the name**
     1. Example: BP-1234_my-short-description
     2. **Make sure your branch is forked from the right branch**.
        1. If you are doing feature work it should be off dev, if it's a release fix it should be off the rc branch and if it's a hotfix fix it should be off the hotfix branch (created once Support has approved the hotfix release).
        2. Be sure to rebase if you change the branch it will be merged to (e.g., from dev to the RC branch).
        3. Don't base a branch off master or point a PR to master.
  3. **Make the necessary changes for the ticket and manually test them yourself.**
     1. Add testing notes to the JIRA ticket too.
  4. **Add tests for each of the files and classes touched by your changes**  

     1. If the test file doesn't exist, add one and at least test your changes
     2. Leave it better than you found it
  5. **Ask yourself these questions**
     1. Am I 100% confident in my solution, and have I backed up that confidence, tangibly, with 100% spec coverage?
     2. Have I manually tested the functionality?
     3. Do I have an understanding of the boundaries and interactions my contribution will have with the surrounding code?
     4. Have I adhered to the style and best practices employed by our engineering team?
     5. Have you checked if any permissions are required or need to be added?
  6. **Commit your changes**
     1. **Each commit should have the JIRA ticket along with a message that describes the change  (Part of Change Management Policy [BT-P4](https://centrohub.sharepoint.com/sites/BasisSecurity/Shared%20Documents/Policies/BT-P4%20-%20Change%20Management%20Policy.pdf))**
        1. Example: [BP-1234] Commit Message 
        2. [How to Write a Git Commit Message: Commit messages matter. Here's how to write them well.](https://cbea.ms/git-commit/)
        3. [How To Write Proper Git Commit Messages](https://medium.com/@steveamaza/how-to-write-a-proper-git-commit-message-e028865e5791)
        4. 'WIP', 'PR feedback', 'Rubocop fix', 'Fix spec', 'Test fix', Fix issue', 'Fix linting issue', 'Revert change', 'Specs', 'Add specs', 'Cleanup', 'Lint', 'Fixed up', Modify spec' or similar messages are **not** good commit descriptions
     2. **Rebase and squash your commits** before merging whenever possible. Squashing isn't always necessary if commits are well organized.
        1. Don't merge/pull other branches (including dev, master, rc) into your feature branch. Rebase instead.
  7. **Push your branch to origin (bitbucket/stash)**
  8. **Create a pull request (PR) and review it yourself before adding others**
     1. Save for some exceptions, your PR should be opened against the dev/develop branch. 
     2. Identify accidental inclusions of things like `binding.pry` calls, commented-out code that should be deleted, misspellings, etc.  Our git hooks can help here.
     3. This will allow you to proofread your work through the eyes of your potential reviewers and will allow you to make any necessary fixes prior to the review process.
     4. This will reduce trivial comments, and allow reviewers to focus on the meaningful bits of your contribution.
  9. **Include a good summary** of the purpose of the PR.
     1. Call out the most important changes for reviewers to pay attention to.
     2. Comment inline to call out important parts.
  10. **Start a test build(Part of Change Management Policy [BT-P4](https://centrohub.sharepoint.com/sites/BasisSecurity/Shared%20Documents/Policies/BT-P4%20-%20Change%20Management%20Policy.pdf))**
     1. A passing build is required to merge
     2. If you make additional changes to the PR (including rebases or amending), you will need a new passing build.
     3. If your PR lasts more than 7 days, your build will expire and you'll need rebase and build again.  If there is a newer version of your base branch (e.g., dev) rebase your changes onto that, but amending your last commit and force pushing may be necessary to pass this check if there are no changes to your base branch.
  11. **Create a POS task ticket if there are any scripts that need to be ran or any other one-off tasks**
     1. Communicate with ops appropriately view the #techopsradio Slack channel
     2. Ops will require a lead engineer to sign off any tasks submitted this way, so don't hesitate to reach out to someone for an approval.
  12. **Add reviewers  (Part of Change Management Policy [BT-P4](https://centrohub.sharepoint.com/sites/BasisSecurity/Shared%20Documents/Policies/BT-P4%20-%20Change%20Management%20Policy.pdf))**
     1. Include reviewers from your team and at least one other team.
     2. Include subject matter experts or component owners where applicable. 
     3. We require at least one approval from a developer not on your team to merge.
     4. For more involved stories or epics with lots of sub-stories, when development begins the team should identify if there are any critical external reviewers and the engineer should reach out to them to make sure that person has appropriate context to be able to perform a sufficient review.
        1. The goal is to ensure that the critical reviewer is comfortable with the motivations for the change, how this particular PR fits into the stream(s) of work, any changes to the technical architecture or new patterns, as well as the UI/UX designs.
        2. This can be very informal, as long as everyone involved is satisfied, and not every feature will have a critical reviewer.  This is something of a gut call, but if you would be uncomfortable merging this change without signoff from a particular engineer that's a strong signal that they are a critical reviewer.
  13. **Allow a reasonable amount of time for review**.
     1. The bigger the PR, the longer it will take to review it.
     2. **If it is urgent, include a reasonable deadline** for reviewers to get to it.
     3. If you're not getting feedback from reviewers, bug them about it.  On the other side of things, if you are a reviewer and someone nudges you about a PR, be honest about expectations for when you will be able to get to it if you won't be able to right away.
  14. **Respond to all comments.**
     1. If you're not going to address a comment on the PR, explain why.
     2. Acknowledge any comments or concerns on Stash, adding tasks where changes are necessary
     3. If you make a change as a result of a task, reply to the requester on Stash with a 'done' comment or resolve the related task
     4. Don't amend commits when responding to PR feedback. Use [`commit --fixup`](https://git-scm.com/docs/git-commit/2.32.0) if you are making a change to a specific commit that already exists.
  15. **Notify approvers** if you make significant changes to the PR after they've already approved.
  16. **After you have enough (see #10 for details)  approvals, the ticket is ready for QA.**
     1. Move the ticket in JIRA to the Test Queue.
     2. QA may find issues that require additional changes to your PR.
  17. **Once QA has successfully tested your PR, they will move the JIRA ticket to Ready for Sign-Off**
     1. Product will test the changes against acceptance criteria from the JIRA ticket.
     2. Product may find issues that require additional changes and retesting by QA.
  18. **After product has signed off on the PR, you are ready to merge.**
     1. Click the merge button in Bitbucket and be sure to check the box to remove the branch once merged.
     2. Add any migration details or feature flags to the release page: 
  19. **Only the Author  (or someone designated by the author) of the PR should click the merge button**
     1. The author of the PR is responsible for determining that the change is acceptable to merge.
     2. This includes verifying QA, Product and Release Management have signed off (if necessary) and all necessary reviews are received.
  20. **If you're not going to merge it, decline it.**
     1. Delete stale branches if they're no longer relevant.
  21. **Close the JIRA ticket**

### For the reviewer:

  * **If you have questions, you should be able to follow the chain from the pull request, to the JIRA ticket, to the JIRA epic (if applicable) for additional context.**
  * **Things to look for in a pull request**
    * <https://web.archive.org/web/20220117051338/https://sourcelevel.io/pull-requests-checklists-metrics-and-best-practices-a-definitive-guide> 
    * Useful git commit messages and the JIRA ticket in each commit message.
    * Tests for each of the files and classes touched by the changes
    * Do the tests reflect the change in behavior?
    * Do tests reach acceptable coverage for your project?
    * Comments in the code if it's complex
    * Do the changes meet the intended purpose described in the feature or story?
    * Does the code work as intended?
    * Is the code clear and easy to understand?


