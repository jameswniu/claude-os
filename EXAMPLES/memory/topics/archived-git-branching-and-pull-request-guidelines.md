# Archived: Git Branching and Pull Request Guidelines

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/35815542

# DEPRECATED: Refer to 

[How to write useful git commit messages](https://cbea.ms/git-commit/)

When submitting pull requests for code review, please do the following:

  1. **Make sure your branch name has the JIRA ticket in the name**
     1. Example: BP-1234_my-short-description
  2. **Review your own PR first** to identify accidental inclusions of things like `binding.pry` calls, commented-out code that should be deleted, misspellings, etc.
  3. **Include a good summary** of the purpose of the PR. Call out the most important changes for reviewers to pay attention to. Comment inline to call out important parts.
  4. **Add reviewers** after you've done steps 1 and 2. Include reviewers from your team and at least one other team. We require at least one approval from a developer not on your team to merge.
  5. **Make sure that the epic contains links to project documentation** (if the ticket is part of an epic) including the Product Discovery Brief in Confluence, any clickable prototypes or mocks, and any RFC.  This will help to streamline the review process, as well as ensure there is a permanent record of these decisions and artifacts in a well known place.
  6. **Include a good, intentional selection of reviewers**  - Include a few people from your team as well as at least one or two developers from other teams. Include subject matter experts or component owners where applicable.  
     1. **For the reviewer** : If you have questions, you should be able to follow the chain from the pull request, to the JIRA ticket, to the JIRA epic (if applicable) for additional context.
     2. **For the submitter** : For more involved stories or epics with lots of sub-stories, when development begins the team should identify if there are any critical external reviewers and the engineer should reach out to them to make sure that person has appropriate context to be able to perform a sufficient review.  The goal is to ensure that the critical reviewer is comfortable with the motivations for the change, how this particular PR fits into the stream(s) of work, any changes to the technical architecture or new patterns, as well as the UI/UX designs.  This can be very informal, as long as everyone involved is satisfied, and not every feature will have a critical reviewer.
  7. **Allow a reasonable amount of time for review**. The bigger the PR, the longer it will take to review it. **If it is urgent, include a reasonable deadline** for reviewers to get to it. You may need to reach out to reviewers to remind them to review.
  8. **Don't let PRs stay open too long**. If you're not getting feedback from reviewers, bug them about it. **If you're not going to merge it, decline it.  **Delete stale branches if they're no longer relevant.
  9. **Respond to all comments.**  If you're not going to address a comment on the PR, explain why.**  
**
  10. **Notify approvers** if you make significant changes to the PR after they've already approved.
  11. **Rebase and squash your commits** before merging whenever possible. Squashing isn't always necessary if commits are well organized. ('WIP', 'PR feedback', 'Rubocop fix', 'Fix spec', 'Test fix', Fix issue', 'Fix linting issue', 'Revert change', 'Specs', 'Add specs', 'Cleanup', 'Lint', 'Fixed up', Modify spec' or similar messages are **not**  good commit descriptions.) Also, don't merge dev/master/rc into your feature branch. Rebase instead. All commits should also include the ticket id.
  12. **Only the Author  (or someone designated by the author) of the PR should click the merge button** The author of the PR is responsible for determining that the change is acceptable to merge. This includes verifying QA, Product and Release Management have signed off (if necessary) and all necessary reviews are received.
  13. **Make sure your brach is forked from the right branch**. If you are doing feature work it should be off dev, if it's a release fix it should be off the rc branch and if it's a hotfix fix it should be off the hotfix branch. Be sure to rebase if you decide to change the branch it will be merged to. Also, don't base a branch off master or point a PR to master.


