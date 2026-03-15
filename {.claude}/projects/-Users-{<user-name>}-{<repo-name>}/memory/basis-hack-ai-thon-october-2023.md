# Basis Hack-AI-thon October 2023

Source: (internal URL)

# Intro

Welcome to Apps Engineering's first-ever virtual hackathon! Hackathons are a way of team building that allows engineers to take a break from the normal day-to-day. It allows meeting new people across teams and building closer professional relationships. It's also an opportunity to build something new and innovative, which could have the potential to become an official Basis Platform feature. With the widespread growth in AI adoption, we are looking toward the future to unleash to incredible potential of AI for our platform. Most importantly the hackathon should be a fun, engaging and motivating event. With these principles in mind, The Hackathon Team (Arturo, Demi, Divyam, Fayadh, Jonah, Kiu) planned this event and we wish you an awesome HackAIthon!

# Summary

## Timeframe 

2 days / 48 hours | October 25-26

## Prompt

Build a Prototype in the context of Basis and the Ad Tech industry that utilizes a [Generative AI](https://news.microsoft.com/2023/04/04/ai-explained/) API (e.g. ChatGPT, Midjourney, etc). This could be a feature in Basis, or a standalone application utilizing Basis.

## Prizes

  * Winner: $100 Uber Eats

  * Runner Up: $50 Uber Eats

## Teams

**Team 1 (Python)****MightyONEs**| **Team 2 (Ruby or Java)****Team 10**| **Team 3 (Java or Python)****The Gooby Woobies**| **Team 4 (Java)**| **Team 5 (Java)****HeyHi**| **Team 6 (Ruby)****AI Caramba**| **Team 7 (Java)****7th Sense**| **Team 8 (Java)****Quantum Query AI**  
---|---|---|---|---|---|---|---  
Hallie Shan*| Brian Gregg*| Olga Dubynka| Ian Wildfong| Carlos Pardo| Coby Drexler*| Demi Lee| Julian Selser  
Brian Mehrman| John Richardson| Justin Virgadamo*| Jon Michalak*| Joe Klonowski*| Ted Price| Albert VanderMeulen| Ali Farmani*  
Nafisa Sarowar| Roberto Ratti| Josh Davison| Zoe Jones| Arturo Urquiza| Marjorie Hurtado| Juan Costamagna| Kyle Bernstein  
Camilo Sarmiento| Gaber Mowiena| Kiu Lam| Patrick Schwisow| Melody Chau| Anas Tlemat| Natasha Fagin| Robin Lee  
| Sabrina Jurlina| Onkesh Bansal| | Rachel Braband| | Brendan White*|   
  
* = Team Lead

# Program

## Planning Stage (10/18-10/25)

  1. Come up with a team name and rename your Slack channel accordingly (keep the prefix)

  2. Assign a "Team Leader"

     1. Responsibilities

        1. Making sure streams of work and plans are laid out and everyone is clear on their responsibilities

        2. Has final [Decision Rights](https://u.pcloud.link/publink/show?code=Fl6ctalK) on the team

     2. We highly encourage a non-manager/team lead to step up as an opportunity for growth/experience

     3. If nobody volunteers, we ask that the most senior member on the team take the role

  3. Identify specific problem statements or challenges that your Gen AI API would address.

     1. Problem statements should be well-defined, focusing on clear pain points

  4. Idea Generation:

     1. Generate a range of ideas that address the theme

        1. Creative and lofty ideas should be considered

  5. Prioritization and Selection:

     1. Review your generated ideas and prioritize them based on feasibility, impact, and alignment with the hackathon's goals.

     2. Teams should select one to develop further during the hackathon.

  6. Decide which Generative API you will use

     1. Run a test command to confirm connectivity

  7. Concept Development:

     1. Flesh out your chosen idea with the following details:

        1. A clear description of the idea and how it addresses the identified problem.

        2. The role of the Gen AI API in implementing the idea.

        3. Preliminary technical requirements

        4. What data sources will be used?

  8. Application shell and development environments

     1. Setup "Hello World" applications

     2. Get development environments setup and ready to go

     3. This will allow everyone to jump right in and start building

     4. **Please do not begin building the application until the start of the hackathon on Wednesday!**

  9. If there's any confusion or questions, ask in [#hack-ai-thon](https://centro.slack.com/archives/C05UZCHCSM9)

## Development (10/25-10/26)

  * Refer to the following resources to aid you in the development process: <(internal URL)

  * We encourage teams to consider pair programming, especially in the beginning as things get moving

    * Once the foundation is in place, parallelizing the work will be easier

  * Repositories

    * Repositories have been created in Bitbucket for each team under the [HACK project]((internal URL))

    * Please find your team's repository [here]((internal URL)) based on your team number

    * If you are going to be forking a repo please let #hack-ai-thon-2023 know so we can move the repo and rename it accordingly

  * Infrastructure

    * A kubernetes cluster (eks-hackathon) is deployed to enable teams to deploy their application

      * Your existing permission **EKSDevAdminRole** will allow you to deploy to this cluster

      * Namespaces have been created for each team in the eks-hackathon cluster

        * Please deploy your infrastructure only into your team's namespace "hackai-team-X"

      * Setup your shell:

        * 1. If you have never used kubectl on your workstation before run this step:

          * <(internal URL)

        * 2. Set --profile=eks-dev. We will borrow the eks-dev profile but make sure to set the cluster "\--name eks-hackathon" when specifying the name.

  * **Deployment is *optional***. You may run your application locally for demonstration.

  * You will **not** be able to provision a full E2E environment like in eks-dev. The E2E environments rely on custom cluster configurations and pipeline infrastructure that is not available for the hackathon.

  * The Basis Platform UI may not run on eks-hackathon without certain supporting infrastructure or data. Your team is responsible for hacking a solution together IF you want to deploy Basis Platform UI to the cluster.

    * As noted above **Deployment is *optional***

    * You may also create a completely new UI. Basis Platform UI is not a requirement

  * Your solution may just be an API, no UI is required

  * Adhere to the [Security policies]((internal URL)) detailed below

## Presentation & Awards (10/26)

A final meeting will be held on EOD October 26.

  * Team presentations | _5 minutes each (40 minutes)_

  * Voting | _5 minutes_

  * Awards and parting words | _5 minutes_

# APIs

We will provide API keys to [Open AI](https://platform.openai.com/docs/introduction) and will share them here within the next couple of days.

Note: you should NOT be committing any of these keys to version control.

Instead, we recommend having your application [read environment variables](https://12factor.net/config) and setting any secrets manually to allow for quick work while keeping them secure.

## Open AI

API Key: [https://start.1password.com/open/i?a=RNVMH2QYSBBQHCBGLXXKXMT5WY&v=pgrdlf4salo5rtvbjewpulfjxa&i=xuhc37yrbu4circ23zzquszksi&h=centro-team.1password.com](https://start.1password.com/open/i?a=RNVMH2QYSBBQHCBGLXXKXMT5WY&v=pgrdlf4salo5rtvbjewpulfjxa&i=xuhc37yrbu4circ23zzquszksi&h=centro-team.1password.com)

You can verify the key with a curl command such as

bash

## Other

You can feel free to use any other APIs (e.g. [Midjourney via TheNextLeg](https://www.thenextleg.io/), [Google's PaLM](https://developers.generativeai.google/guide/palm_api_overview), etc), but you should plan to sign up for your own API account and expense any costs. Please give  a heads-up if you decide to use a different API.

# Resources

<(internal URL)

# Code of Conduct

  * Respect: Treat all participants with respect and professionalism.

  * Plagiarism: Do not use someone else's work without proper attribution.

  * Harassment: Harassment in any form will not be tolerated.

  * Fair Play: Maintain honesty and ethical conduct throughout the competition.

  * Reporting: Report any code of conduct violations to Jonah Rosenberg.

  * Consequences: Violations may lead to disqualification.

# Security Considerations and Guidelines

## Basis Security AI Policy

## Hackathon Guidelines

  * Use AI tools in a way that is consistent with the company's values and ethics.

  * Ensure no production, or customer data is used. Any data you use with the models, should be data that is generated or de-identified. Sanitize the content of prompts (no personal information and no corporate confidential data or code)

  * Secure your data: Implement strong security measures to protect your data, such as using SSL/TLS encryption for data in transit, encrypting data at rest, and implementing robust authentication and authorization mechanisms. 

  * Treat any Generative AI tools the same way you would treat any other vendor when it comes to data privacy and security. Ensure no proprietary code or data is input into any Generative AI models.

  * You can opt out of Open AI using your data for training its models here: [_form_](https://docs.google.com/forms/d/1t2y-arKhcjlKc1I5ohl9Gb16t6Sq-iaybVFEbLFFjaI/viewform?ts=63cec7c0&edit_requested=true).
