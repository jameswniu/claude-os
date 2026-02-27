# Claude Code Pricing Evaluation week of 11/24/2025

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1492484268

The Apps Engineering AI Tools Council supported the comparative analysis of the 2 Claude pricing models. The goal is to produce data that can inform the purchasing strategy for company-wide adoption, with the intent of minimizing costs.

## Pricing Models

[FAQ answer defining the two different models](https://support.claude.com/en/articles/9876003-i-have-a-paid-claude-subscription-pro-max-team-or-enterprise-plans-why-do-i-have-to-pay-separately-to-use-the-claude-api-and-console)

**Abbreviation: Per User Per Month -> PUPM**

### Claude Paid Plan - Team Plan

#### <https://support.claude.com/en/articles/9266767-what-is-the-team-plan>

  * [$150](https://www.claude.com/pricing#team-&-enterprise) PUPM for Claude Code access

  * Subscription works with the [Claude chat app](https://claude.ai/new)

    * Tokens shared between Claude Code and the Claude chat app

  * 100-person team limit 

### Claude Console - API 

<https://support.claude.com/en/articles/8114521-how-can-i-access-the-claude-api>

  * [Pricing](https://www.claude.com/pricing#api) based on usage

  * Access to Claude Code

  * Cannot use API tokens for the Claude chat app

    * Account will be on the free tier on the Claude chat app

## **Assignments**

Team Plan

  *   * 

API

  *   *   * 

Contributors were given the following instructions on 11/24/25: 

> By this Friday (11/28/25), we need usage data that will guide our decision on expanding access to the rest of the organization.
> 
>   1. Please log in to Claude Code using your Basis account through the Basis/BasisAI organization.
> 
>   2. The goal is to be able to evaluate how much usage a typical developer at Basis may consume in a given day.
> 
>   3. Keep track of which JIRA tickets you implement each day
> 
>      1. This can help us assess token consumption variance on different-sized repos.
> 

## Results

The timeline posed a significant challenge due to the US Thanksgiving Holiday.

received verbal confirmation from individuals about the specific days that their Claude Code usage could provide relevant data to evaluate `how much usage a typical developer at Basis may consume in a given day.` This was then used to create the following chart:

**Date of Usage**| **Contributor**| **Cost**| **Projected Monthly Cost (Cost x 20 working-days/month)**  
---|---|---|---  
|  Divyam Patel| $3.54| $70.8  
| Ryan Morris|  does not have access. can likely access the Team Plan Basis AI org dashboard to see 's token consumption on this date and calculate the potential API cost based on [API pricing](https://www.claude.com/pricing#api).|   
| Arturo Urquiza| $5.15| $103.00  
| Arturo Urquiza| $2.39| $47.80   
| Jonah Rosenberg| $5.11| $102.20   
| Divyam Patel| $2.44| $48.80   
| Jon Michalak| $2.54| $50.80   
| Divyam Patel| $5.29| $105.80   
| Divyam Patel| $8.03| $160.60   
| Jonah Rosenberg| $12.81| $256.20   
  
With this data, we project ~$105.11 PUPM for API-based pricing.

## Recommendation

A combination of Team Plan and API-based access can be leveraged to provide the flexibility needed to minimize costs while empowering power users to explore and innovate. 

  1. A target per-user budget limit should be established: $100 per month

  2. The target population should be defined (All engineers at Basis or only a subset?): 100 engineers

  3. The total monthly budget is: $10,000.00

     1. Yearly budget is: $120,000.00

  4. 15% of the target population projected as potential power users: 15 power users

     1. These represent individuals who would exceed $150 in API consumption, making the Team Plan seats preferable

  5. 15 Team Plan seats should be purchased

     1. This would cost 15*$150=$2250

  6. Remaining budget is $7750

     1. Per-user budget for the remaining 85 users: $91.18

  7. All users being onboarded to Claude should initially be granted only API-based access. 

  8. Usage should be monitored periodically to identify any power users

  9. Power users should be reassigned to the Team Plan-based access

     1. If Team Plan seats are exhausted, limits should be put in place to prevent API overspending.

### Alternatives

#### Single API Pricing Plan

  1. A target per-user budget limit should be established: $100 per month

  2. The target population should be defined: 100 engineers

  3. The total monthly budget is: $10,000.00

     1. Yearly budget is: $120,000.00

  4. All users onboarded to Claude are granted API-based access.

  5. Limits are strongly enforced to prevent users from exceeding the per-user budget

#### Employee-contribution Plan

  1. A target per-user budget limit should be established: $100 per month

  2. The target population should be defined: 100 engineers

  3. The total monthly budget is: $10,000.00

     1. Yearly budget is: $120,000.00

  4. Users can pay the difference for Team Plan access: $50 per month

     1. suggests the following:

        1. `I would pay $150 a month out of my own pocket if I had to, to have access to the best tool to help me do my work. Being limited in the level of access I want for Claude to be on a more limited company-approved plan would be unfortunate.`

        2. This is generally a sentiment  has heard from others

     2. It would be worth exploring any way to allow employees to fund their own costs for premium versions of these tools.


