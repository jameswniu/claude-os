# AI Code Reviewer Project

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1583513725

**Driver**|  Primary: Secondary:   
---|---  
**Approver**|   
**Additional Contributors**|   
**Informed**|   
**Objective**|  Build and integrate an AI Code Review solution to enable Apps Engineering to receive automated feedback on pull requests. The solution should ensure high-quality feedback that addresses security, potential bugs, and performance issues, while adhering to the organization's best practices.  
**Due date**|   
**Key outcomes**| 

  * Solution is available to all engineers in Apps Engineering
  * Provides valuable feedback that increases quality and security
  * Engineers integrate feedback into their changes

  
**Status**|  not started / in progress / complete  
  
##  Problem statement

An AI-based Code Reviewer can provide substantial benefits by catching bugs, identifying security issues, and overall improving the quality and performance of code. 

There are 3rd-party code review tools on the market, but no specific one stands out. As an organization, being on Bitbucket Server (as opposed to Bitbucket Cloud or GitHub) results in constraints on the tools we have access to. Native or 3rd party AI Code Review tools are limited in Bitbucket Server.

A semi-custom solution can be implemented to solve this challenge. Claude can be integrated into a Harness pipeline that is activated either manually or automatically to review PRs.

##  Scope

**Must have:**| 

  * Ability to trigger either manually or automatically
  * Integrated into a CI system so anybody can use it (Harness)
  * Thorough instructions to evaluate for:
    * Bugs
    * Security Issues
    * Performance Issues
    * Style and Best practices
  * Integrate with Claude.md 

  
---|---  
**Nice to have:**|   
**Not in scope:**|   
  
##   Tasks

**Milestone**| **Owner**| **Deadline**| **Status**| **Notes**  
---|---|---|---|---  
Acquire API token and budget for Code Reviewer tool| | | |   
Create the Code Reviewer Agent|  | | |   
Set-up Harness Pipeline to run Code Reviewer| | | |   
Align on trigger mechanism (manual vs automated)| | | |   
Create integration guide for onboarding repositories| | | |   
Investigate how to enable the agent to acquire context (best practices, API docs, etc.) of dependencies| | | |   
Analyze previous code reviews to identify best practices to bake into Claude.md| | | |   
  
# 📊 Success Metrics

  * 


