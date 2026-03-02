# Scalable Applications and Architecture

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/505544931

_This exercise focuses on web application design and architecture. No coding should be required. The candidate should be asked to create documentation/diagrams to support their solutions._

Problem is already in Coderpad: <https://app.coderpad.io/dashboard/questions/all/280521>. Any changes here should be updated in the question template as well.

Dump the Markdown from Coderpad into a text file, modify (with VS Code for example, for Markdown preview), and then update in Coderpad.

Walk the candidate through the entire Background section, and then present them with either the Senior or Staff exercises.

true13falselistbracketstrue

## Background & Domain

### Exporting Audience Inventory

For targeting online ads, Basis gives its clients access to a large collection of data-driven audience segments.

An **Audience Segment** is a set of consumers that share a specific trait, such as age, occupation, interest, or behavior.

* * *

#### Example Data:

The data set is hierarchical, and is normally displayed in a tree or folder structure

Audience Segment| Reach| Price (CPM)  
---|---|---  
**Data Vendor ABC**|  -| -  
  :   **Demographic**|  -| -  
  :     :   **Age 18-24**|  3,500,000| $1.50 CPM  
  :     :   **Age 25-35**|  12,100,000| $2.50 CPM  
  :     :   etc.| |   
  :   **Interests**|  -| -  
  :     :   **Automotive**|  800,000| $3.50 - $5.50 CPM  
  :     :     :   **SUVs**|  600,000| $3.50 CPM  
  :     :     :   **Sportscars**|  200,000| $5.50 CPM  
  :     :     :   etc.| |   
  :     :   **Literature**|  450,000| $0.85 - $2.75 CPM  
  :     :     :   etc.| |   
**Data Vendor XYZ**|  -| -  
  :   **Demographic**|  -| -  
  :     :   etc.| |   
  
  * **Reach** is the number of consumers within an audience or segment

  * **CPM** is short for "Cost per 1,000", referring to the number of impressions (ad views) purchased

* * *

Many clients have requested the ability to download the full set of available audience segments, as a spreadsheet.

You will be designing the backend aspects of this feature. Consider what backend functionality would be required to support the desired frontend user experience.

Our Data Engineering team has provided an internal Audience API service that our feature can call to fetch paged rows of audience segments in JSON format. The API is very simple: a `GET` request to `/audience-segments?page=1&pageSize=500` will return the first page of 500 CSV rows. 

### Frontend UX Requirements

The reports are expected to take some time to generate, so users will have to request a report, and then come back later to check the status and finally download the finished report.

Each user may have a different set of available segments.

The Audience Segments view will have a new Export button. Clicking the button should retrieve and display the following information:

  * Some text representing the current status of the report (NONE, PENDING, or COMPLETE)

  * A button to generate a new report

  * If the status is COMPLETE, they will also see:

    * The time that the report was completed

    * A button to begin downloading the report from the server

If a user clicks to generate a new report, their previously-generated report will immediately become unavailable. Only the user's most recently-generated report will ever be available.

The finished report should be a spreadsheet (.CSV) where each row represents one unique, targetable Audience Segment, including the same level of information seen in the sample data.

### Interviewer - Potential Domain Questions & Answers

Q. **Why do some rows not have a price or reach?**  
Q. **What is a "targetable" segment?**

A. Nodes that include a price are actual audience segments that can be targeted. Nodes with no price are for organizing the hierarchy, but can't be purchased or targeted.

Q. **Why do some rows have a price range and some don't?**

A. Depending on the node, the price can either be a range or a fixed price.

Q. **Where do we get the raw data from?**

A. The raw data comes from a REST API. Getting all the data could require dozens of API requests.

Q. **How/where are user permissions applied?**

A. The REST API handles that, and only provides the data set available to the current user, so we don't need to worry about that aspect.

Q. **How often does the data change?**  
Q. **Can the results be cached?**  
Q. **Why would the user want to overwrite or generate a new report?**

A. Small changes are made to the data fairly frequently (every couple days), at irregular/unknown intervals.

## Senior 1 - REST API Design

  1. Design a JSON REST API to support the frontend requirements. Describe and document each endpoint in terms of Path, Method, Request paramters and Response body.

  2. Within this design, are there any extra cases that we could consider or solve for that aren't explicitly outlined in the requirements?

### Interviewer - Things to look for:

  * Does their design satisfy all the requirements?

    * It should cover the 3 main functions - generate a report, check report status, and download the latest report

  * Does each endpoint have a distinct and clear purpose?

  * Does the design seem logical, functional, and resilient?

  * Do they consider additional error/edge cases without being prompted?

  * Do they consider authorization and security?

  * Do they consider resource usage, or anything that might be beyond the scope of this question?

## Senior 2 - CSV Data Model

  1. Since the requirements leave some details open to interpretation, how would you format the CSV data so that it satisfies the requirements? Provide an example using some of the sample data.

### Interviewer - Things to look for:

This will show how well they understand the hierarchical data, and how well they consider how the usability of the data.

  * Does their answer satisfy the requirements?

  * Price:

    * Do they consider number formatting?

    * Do they consider whether min/max price should be together or separate?

  * Hierarchy:

    * Do they consider the requirement to only include targetable segments?

    * Do they include the full, hierarchical name/path for each segment?

    * Do they consider whether Name and Path should be together or separate?

_There's not necessarily a correct solution for these. The most important thing is that they they consider some of these details and justify their choices._

## Staff 1 - System Architecture

You are in charge of designing the system that will handle this functionality. How would you approach this problem, from an architecture perspective?

  1. How would you handle the long-running report generation tasks?

  2. How would you store/retrieve the completed CSV files?

  3. Would this system require any new data models or data storage?

  4. Create a diagram to represent all elements of the system, including any external services or data required.

  5. What concerns, unknowns, or potential risks can you identify about the system or the requirements?

_Optional, if they didn't already consider this:_

  6. What would happen if the service crashed while generating a report? How could you change the design to be more resilient to that.

### Interviewer - Things to look for:

  * Does their design satisfy the requirements?

  * Are they able to communicate clearly about technical concepts?

  * Do they consider resource limitations or potentially high memory usage?

  * Do they implement any kind of queue?

  * Is the solution resilient to crashes and restarts?

  * Does their solution work across a distributed system (more than 1 instance)?

## Staff 1 (Auth) - System Architecture

You are in charge of designing the system that will handle this functionality. How would you approach this problem, from an architecture perspective?

  1. Create a diagram to represent all elements of the system, including any external services or data required.

     1. How would you handle the long-running report generation tasks?

     2. How would you store/retrieve the completed CSV files?

  2. How would you handle authentication?

  3. How would you make sure the user requesting the report has access to the data?

     1. What type of access control paradigm (RBAC, ReBAC, ABAC) would you implement and why?

     2. How would you verify the user's identity in this scenario?

  4. Where would you have authorization decisions being made in the system and why?

     1. Would/should different services have different policies?

  5. How would you scale the way authorization decisions are made so that the system is still performant as the number of check requests exponentially increases?

     1. How would a cache be built?

     2. How would the cache be successfully invalidated if necessary?

  6. Let's say the authorization service was compromised by a malicious third party. How would you build the system to respond appropriately and/or maintain system availability?

     1. How would you build a useful audit trail?

     2. How would you build a system that could successfully rollback to previous states, if necessary?

  7. What concerns, unknowns, or potential risks can you identify about the system or the requirements?

_Optional, if they didn't already consider this:_

  6. What would happen if the service crashed while generating a report? How could you change the design to be more resilient to that.

### Interviewer - Things to look for:

  * Does their design satisfy the requirements?

  * Are they able to communicate clearly about technical concepts?

  * Do they consider resource limitations or potentially high memory usage?

  * Do they implement any kind of queue?

  * Is the solution resilient to crashes and restarts?

  * Does their solution work across a distributed system (more than 1 instance)?

## Staff 2 - Scaling & Availability

Imagine after some time has passed, we find that a lot of users are trying to generate reports first thing every Monday morning, around the same time.

  1. Which areas of the system could have issues with an increase in report frequency, and could we scale the system up to handle those issues?

  2. What aspects of the system would you monitor to detect potential problems?

### Interviewer - Things to look for:

... TBD

