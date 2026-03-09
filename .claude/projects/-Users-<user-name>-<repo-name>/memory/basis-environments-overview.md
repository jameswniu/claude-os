# Basis Environments Overview

Source: (internal URL)

Any change to Basis, whether a new feature or a bug fix, goes through the same process to go from a developer's laptop to production. We have four environments where different kinds of software work. You will hear a lot about these environments in discussions with your team, so it's good to have an understanding of what they are and when you'll use them. 

The environments types (or classes) are:

  * Development

  * Integration

  * Staging

  * Production

  * Demo

The order in which your work progresses through the environments affects how frequently and easily you can make changes to the code as you work on it.

The **Development** environment is your local computer. Your development environment is almost entirely under your control as a developer. Changes to the code can be seen immediately in the local server running on your machine or in the tests you run. This means you can make changes frequently and see the results before even committing them to source control. You will work in the development environment until you are satisfied that the change works as expected and through the pull request process as you respond to feedback from the code review process. 

**Integration** environments are shared environments with an internal URL. They are used to verify the code on a branch before it is merged into the upstream repository. The developer or tester manages the environments, and they can be created, updated, or destroyed on demand via the Marvin Slack bot or Harness. Deploying to an integration environment requires a git branch that has been pushed upstream to Bitbucket but before it has been merged to the development main branch. It takes longer to get changes into an integration environment because of the deployment process. However, changes can still be pushed to an integration environment a few times daily, usually in response to QA finding issues before sign-off. For specific details on deploying, see [Deploying to Integration Environments with Marvin]((internal URL)) or EKS Environment (see EKS Onboarding Guide).

The release team manages **Staging** and contains all the changes that have been merged with the upstream release branch following sign-off. It is used for the final regression test and sign-off by the QA team before a release goes to Production. The release team usually updates staging once a week, and changes to code in staging are far less frequent since QA and product must sign off work before being merged. In general, we try to limit staging changes to issues considered critical in Production. 

**Production** is the environment where users actually use Basis. We release to production once per week unless critical bugs arise. 

**Demo** is the environment that our Solutions Engineering team uses to demo our platform to new clients. See EKS Demo Environments: Home Page or EKS Demo Environments.
