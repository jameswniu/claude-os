# Git Fundamentals

Source: (internal URL)

## Learning Git

<https://www.atlassian.com/git>

I recommend taking the time to understand the basics of what git does, rather than just committing these cryptic commands to memory. Understanding the principles behind the commands will help you solve problems when they occur. The [official Git tutorial](https://git-scm.com/docs/gittutorial) explains what the parts of git are in broad strokes. If it's just just telling you stuff you already know, then dig into the [git book](https://git-scm.com/book/en/v2), which has more details.

[https://ndpsoftware.com/git-cheatsheet.html](https://ndpsoftware.com/git-cheatsheet.html#loc=index;) This is a cool cheatsheet with a map of git's different "places" and the commands that are relevant to each of them. 

The [git rebase ](https://git-scm.com/docs/git-rebase)man page is good for the very specific situations I see many Basis developers get stuck on.

## Rebase automatically

When setting up your git environment, one of the first things you should do is set up git pull to use the rebase strategy rather than merge:  
  
`git config --global pull.rebase true`  
  

This will ensure that if you pull in upstream changes to a branch with local changes, your local changes will be rebased onto the upstream changes rather than having the upstream branch merged to your local changes. This will make everything easier when you want to squash commits or rebase onto another branch (e.g. dev)

## Rebase interactively

`git rebase -i origin/target_branch`

The [git docs](https://git-scm.com/docs/git-rebase) explain this far better than I can. Learn it, use it, your team mates will appreciate it!

Interactive rebase will drop you into vi by default, which can be a bit confusing for the uninitiated. Always remember these two commands for exiting vi:

First press escape to exit any interactive mode, then:

`:wq` will write your changes and **proceed** with the rebase

`:cq` will abort the changes and **stop** the rebase

## Reset a branch

`git reset` will unstage any staged files without making any changes.

`git reset --hard _branch-name-or-commit_` will destructively force the current branch to the state of _`branch-name-or-commit`_. This is a great way to revert _back_   to your old branch if a rebase goes goofy. You may need to run `git rebase --abort` as well.

## Cherry Pick

`git cherry-pick single-commit-sha`

This will apply one single commit to your branch. Great for pulling in a fix for a flaky spec or any other issue from somebody else's branch.

## Force with Lease

When squashing or rebasing an existing branch, **don't** use `git push --force` anymore - now we have `git push --force-with-lease`, which will prevent any unforeseen clobbering of upstream commits which could happen with `--force`

## rebase --onto

`git rebase --onto <newbase> <oldbase>` 

One of the most common tasks is moving a series of commits onto a different base commit.  For example, onto an hotfix branch instead of `dev.  In that example you'd do (assuming you have 2 commits) `git rebase --onto origin/dev HEAD~1` `

## Bisect

This is too long to have a quick summary of, but if you ever find yourself in a large automobile trying to figure out which commit broke something, and you have a past commit that is not broken, this will let you do a binary search for the first broken commit.  <https://git-scm.com/docs/git-bisect>

## Git Cheat Sheet

The [Git Cheat Sheet from Git Tower](https://www.git-tower.com/blog/git-cheat-sheet) has a lot of good commands and tips as well.[ ](https://www.git-tower.com/blog/git-cheat-sheet)
