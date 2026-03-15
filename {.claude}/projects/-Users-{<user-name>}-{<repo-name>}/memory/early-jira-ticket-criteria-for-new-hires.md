# Early Jira Ticket Criteria for New Hires

Source: (internal URL)

# Introduction

Choosing the initial tickets to onboard a new hire is a tricky balance. Ideally, a ticket builds context quickly, requires a reasonable level of support while supporting independent learning, and aids to help ramp up a new hire quickly. This document intends to define best practices on how to choose an ideal set of tickets over the course of a new hire's first few weeks. 

# Best practices for a [Good-First-Ticket]((internal URL)):

  * Internal page tools
    * Great because it's usually end-to-end
    * Helpful to ramp up on Rails basics for those without prior experience.
  * Avoid tickets along the critical path
  * Minimal dependencies required for testing  

    * For example, analytics service code changes are tough because testing them frequently requires building DSP API and/or BDM in a test environment. We're working on improving the dev experience for those use-cases, but short-term consider whether you can find tickets that have fewer technical dependencies to get moving and contribute code vs spending too much time on setup.
  * Bugs are easy to reproduce locally
    * Too often instructions may be easy to reproduce in production or staging, but may require a challenging setup for local dev
  * Requires enough code to see progress (more is better than less)
    * Helpful for individuals to build confidence
    * Helpful for leads/managers/mentors to track progress
    * More opportunities for productive code review
  * Ticket description is clear, ACs exist, solution is well known
    * Many first tickets are ambiguous bugs that seem simple on first glance. In reality, they're bugs because they're subtle and require tricky debugging to find out that a fix requires a much larger change that isn't worth the effort, or very small without much code to show for the work.
  * Series of tickets that can be broken down into phases
    * Allows for subsequent tickets to build on one another vs jumping around and learning a different area of the code on every ticket

### Jira Boards & Filters

[Good First Tickets (Board)]((internal URL))

[Good First Tickets (Filter)]((internal URL))
