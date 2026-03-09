# Apps Engineering Resource Library (formerly Onboarding)

Source: (internal URL)

This page used to be named "Basis Platform Onboarding" but it got too large to be used as an onboarding guide.

Our Onboarding process has since been replaced by the Apps Eng Onboarding Task Board.

Everyone on the team is encouraged to keep this page updated to help your fellow team members when searching for a particular resource, link, or process.

### Getting Started

  * Verify ability to sign in to Confluence (and Atlassian products). You'll need to be on [VPN](https://centrohub.sharepoint.com/sites/ITSupport/SitePages/OVPN-Setup-Guide.aspx). If you don't have access to the Atlassian suite, please ask your manager to create a TEAM ticket.

    * If you are connected to the VPN and still unable to access Confluence, try using Google's DNS Servers (8.8.8.8 and 8.8.4.4). [Instructions here](https://developers.google.com/speed/public-dns/docs/using#macos).

  * Ask your manager to request a Basis Platform Support account for you

    * Email [support@centro.net](mailto:support@centro.net) to create an internal support user account for you

  * Setting up your laptop

  * Setting up printers

### Languages and Frameworks

Ruby and Rails resources

JavaScript and React resources _todo: add me_

Java and Spring resources _todo: add me_

[Python resources]((internal URL)) _todo: add me_

### Apps Engineering Fundamentals

Basic skills you will need to succeed as an engineer at Basis. 

Shell Fundamentals

Git Fundamentals

### Technology Resources

#### Basis Platform

  * README: <(internal URL)

  * Best practices for UI code: <(internal URL)

  * Production: [https://platform.basis.net](https://platform.basis.net/dashboard?statuses=Planning&statuses=Approved&statuses=Live)

  * Staging: [https://staging02.prod.basis.net](https://staging02.prod.basis.net/)

  * Confluence: Basis Platform Home 

  * Learn how to setup Basis Platform at Basis Services: Setup

#### Tools

  * [Slack](https://centro.slack.com)

  * Atlassian

    * [JIRA](https://jira.centro.net/)

    * [Stash]((internal URL))

    * [Confluence]((internal URL))

  * [Datadog](http://datadog.centro.net/) (Datadog is accessible through SSO)

  * [Airbrake](https://centro.airbrake.io/) (via Team Lead or ProdOps)

  * [Metabase](https://metabase-production-internal.prod.basis.net/) (PMO )

  * [1Password](https://centro-team.1password.com/) (via IT Support <it.support@[centro.net](http://centro.net)>)

  * [Postman](https://basis-apps.postman.co/home)

    * See Getting Started with Postman for setup instructions for new hires.

  * [VividCortex](https://centro.app.vividcortex.com/)

  * [Lucidchart](https://www.lucidchart.com/documents#docs?folder_id=203123722)

    * After logging in for your first time, reach out to  to get added to the Eng Basis Platform user group

  * [O'Reilly Learning Platform](https://www.oreilly.com) (Formerly Safari Books)

    * A Toronto Public Library card can get you free access to this [here](https://www.torontopubliclibrary.ca/detail.jsp?R=EDB0099)

    * We have a Basis account with 20 seats

      * If you are interested in a seat, reach out to 

      * Seats are use it or lose it - if a license isn't being used, it may be reassigned

      * It's easy to swap people in and out, so if you lose access and want it again later, just ask

      * If all the seats are actively being used, we can look into additional seats.

  * Marvin

    * Slackbot for automated Prod Ops tasks

    * Chat Marvin either directly or in the [#infrabuilds](https://centro.slack.com/messages/C4KTGGAPM) room

    * @marvin help (or just "help" in a Marvin DM)

  * Design System

    * [Basis Design System](https://design.centro.net/)

    * [Storybook](https://storybook.basis.net/)

    * [Figma](https://www.figma.com/files/)

  * Mailtrap

    * used to capture emails from our testing environments

  * [Pendo]((internal URL))

  * [Harness](https://harness.io/)

    * Request Access to Harness

    * Harness Access Control

    * Harness Builder's Guide

#### Architecture

  * Basis Architecture Document

    * README

    * Current State

    * Possible Future State

    * Source in Lucidchart: <https://app.lucidchart.com/invitations/accept/29dc6746-4e6d-4e3d-bc73-17bf4f0e4b23>

  * Bi-weekly Architecture Discussion group ([#architecture](https://centro.slack.com/archives/C2V1RRFNC))

  * [RFCs]((internal URL)) (request for comments)

  * Minimum Service Requirements

  * Domain Hierarchy

    * Diagram: <https://app.lucidchart.com/invitations/accept/3d09fc0b-0665-45d7-b4da-407d028af28e>

    * Older version [here]((internal URL))

  * Component Architecture Overview

  * High Level Architecture

  * [High-level "Tech Systems"](https://app.lucidchart.com/lucidchart/07eba8dc-af34-415a-8331-0d3d8af1a576/edit?page=0_0) (including Basis + DSP + Data)

  * [DSP Data Flow](https://lucid.app/lucidchart/ea767fa9-0ac8-48d0-9c3e-fdcf471b16cf/view?page=0_0)

  * Basis Platform Negotiation Process

  * Microservice Architecture Resources

#### Team

Basis Platform has several teams of Engineers, Product Managers, QA engineers, UI designers, and UX designers. 

Cross-Functional Team Chart

  * Each team usually has their own space

    * Team Bluetiful

    * Magenta

    * Red Team

    * Team Tangerine

    * Cyan Team Process

    * Team-BA

    * (internal URL)

  * There is also a product space with information about current projects teams are working on. Here you can see which initiatives people are working on.

    * BP Automation Product Management

  * Bootcamp Home 

  * Lightning Talks Home

    * [Lightning Talks Blog](https://confluence.centro.net/pages/viewrecentblogposts.action?key=LT)

  * Read about our team feedback process here.

  * About every 6 months, the whole company does self-reviews. See How to write a self-review, for developers.

  * QA Team has their own framework document here.

  * Early Jira Ticket Criteria for New Hires

#### Support

This section details a list of links below to help you get an understanding of what the centro support process looks like.

  * The link below contains a guide of what the engineer on support should be looking out for

    * [Daily Support Responsibilities/Checklist]((internal URL))

  * This section shows how to triage issues/tickets while on the support rotation

    * [Basis Support & Triage Flow Chart]((internal URL))

  * Production After Action Reports (Post-Mortem)

  * [Ticket Severity SLA]((internal URL))

#### Workflow

  * Platform Release Process

    * Basis Platform Release Guide

  * Pull Requests

    * Tickets, Branching and Pull Requests Oh My!

  * How to write a bug report

  * Basis Environments Overview

  * AWS Integration Environments

    * TL;DR: [Deploying to Integration Environments with Marvin]((internal URL))

  * [Basis Production Read-Only Database Access]((internal URL))

  * [UI Guides and Component Library](https://ui.prod.ourcentro.net)

  * Flakey Specs

  * Zero Downtime Migrations

  * [Data Fetching and State Management Patterns]((internal URL))

### Business Resources

#### Resources about Basis, the web app

Basis, the company, owns and operates Basis (AKA Basis Platform), a web app that helps employees and clients of Basis create and manage ads. This is super confusing terminology, especially for you, the new hire. Sorry! You'll get used to it.

Anyway, here is more documentation and resources for you to learn about Basis, the web app. Most of this stuff is targeted at users of Basis Platform or for the customer experience team (Basis employees who help users learn to use Basis Platform), so it doesn't explain how any of this stuff works from the perspective of an engineer or a product manager - don't worry, there's other resources for that!

  * [Basis Help](https://basis-production-helpdocs.s3.amazonaws.com/master_buyer/Home.htm) \- the help center for Basis. We're lacking a solid "Getting Started" section, but feel free to take a self-guided tour of the docs to learn about how to use the app and all the features it offers.

  * [Basis Customer Experience (BCE) Resources](https://centrohub.sharepoint.com/sites/CustomerSuccess/SitePages/BCE---Basis-Resources.aspx) \- lots of onboarding and training materials put together by the BCE team, including:

  * [Training Modules](https://centrohub.sharepoint.com/sites/CustomerSuccess/SitePages/Training-Modules.aspx) \- covering topics such as workflow & reporting, ad serving, programmatic 101, data integrations, and ad types.

  * [Basis Institute (LMS)](https://centrohub.sharepoint.com/sites/CustomerSuccess/SitePages/Centro-Institute-\(LMS\).aspx) \- training videos including an intro to Basis. Login credentials for internal users included.

  * [Basis Internal - Sales, Operations, and Support (BISOS)]((internal URL)) \- all sorts of internal documentation about Basis' application features. Content may or may not be up to date, so proceed with caution.

  * [Product Knowledge Base (Beta)]((internal URL)) \- The internal product knowledge base that should eventually become the go-to resource for learning about Basis and its features. This is a work in progress in its early stages.

#### Learn more about Basis and the digital media industry

  * Centro tech team Continous Learning page

  * [Basis List of Common Terms](https://basis-production-helpdocs.s3.amazonaws.com/master_buyer/Common%20Topics/List%20of%20Common%20Terms.htm?tocpath=Basis%20Platform%20Terminology%7C_____1)

  * [IAB Digital Advertising Glossary](https://wiki.iab.com/index.php/Category:Glossary)

  * Learning Advertising and Ad Tech

  * Digital Media Industry Links

  * Basis Demos

    * [Demo 1](https://web.microsoftstream.com/video/6475e3d5-3128-49f2-a7a2-9d8c6e4ed3a5)

    * [Demo 2](https://web.microsoftstream.com/video/2155cc2b-f38b-4efd-ad10-06d3a0347fe2)

    * [Demo 3](https://web.microsoftstream.com/video/718fbb9c-4a8a-4105-b0db-5af3b3b2e609)

  * Basis Platform Help Documents (In-app Help)

  * Web Accessibility Best Practices

  * Customer Success Walkthroughs with New Customers

    *  _Note: you may need to request access to some of these. Feel free to request and you should be granted access in a day or two._

    * [ Campaign Building: Basis Onboarding ](https://centrohub-my.sharepoint.com/:v:/g/personal/kamelyn_bovinette_centro_net/EZO_fWF7jctKlYcgXUeq49gBqJPzFEc_1-QVj-AGwg9lfw)

    * [ DSP Optimization Training ](https://centrohub-my.sharepoint.com/:v:/g/personal/kamelyn_bovinette_centro_net/Eaoshgj1pmtFhSVvakHBkZcB4R2Z0vrg0vtMrVCTd3Aa8Q)

    * [ Simple Design ](https://centrohub-my.sharepoint.com/:v:/g/personal/matan_horenstein_centro_net/Eew-DFA5imZCliEmape1q9ABeixs_OOPW1QzvFZ2XuDNFw?e=LcVB94) (DSP Focus)

    * [ Smith Kroeger ](https://centrohub-my.sharepoint.com/:v:/g/personal/matan_horenstein_centro_net/EVGnjeePmAlJqdI8aRGGoB0B20t4TWs0qWRM__AghTFviw?e=DGu6zK) (Building/Linking Search/Social - Google Search Example)

### Continuous Learning

  * [Linkedin Learning](https://www.linkedin.com/learning) (SSO with Centro credential)

  * Basis Engineering Reading List \- recommended reading for Basis Engineers: books your team mates have read and benefitted from 

### Internal HR stuff

  * Your manager should have added you to the following distribution lists. You should double check, and possibly remind them (in case they forgot):

    * eng.apps.basis

  * [Workday](https://wd5.myworkday.com/centro) (Vacation/PTO and Payroll)

  * [Concur](https://concur.centro.net) (Expenses)

  * [Centro Intranet](https://info.centro.net)

    * [Other Useful HR Pages](https://info.centro.net/SitePages/OnlineResources.aspx)

### Presentations for New Hires

  * Basis Platform Overview (Product)

  * Component Architecture Overview (Engineering)

  * Testing Process Overview (QA)

  * Tech Ops Overview (Prod Ops)
