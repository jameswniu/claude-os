# Apps Eng Onboarding Task Board

Source: (internal URL)

The Apps Engineering Onboarding (AEO) project in Jira is meant to provide a self-directed way for new application developers to get acquainted with Basis. It is meant to replace the use of Trello boards.

##  Instructions (for managers)

Please follow these instructions **BEFORE** the new hire's start date to ensure a smooth onboarding. 

Follow these simple steps to make the magic happen:

  1. Open the ticket for the "TEMPLATE" epic in the AEO project - AEO-604c33df4a-f75e-33b8-a8b8-5fcc9cdc091bSystem Jira

  2. Hit the button in Jira with the lightning bolt icon (automation) and select the automation rule named "Clone AEO template for new hire".

     1. This should kick off a Jira automation that will copy/clone the template and all its child issues into a new epic.

     2. The automation usually takes 5-6 minutes.

  3. Open the [Jira automation audit log]((internal URL)).

     1. Check whether your automation run succeeded, failed, or is still in progress.

     2. Once it succeeds, use the buttons in the UI to open the details of the execution and get to this view. This shows you the link to the clone of the template. 

  4. Find your new epic ticket in the [Timeline view]((internal URL)) and change the description to include your new hire's name.

  5. Take care of Management Tasks

     1. Use [this Filter]((internal URL)) to find the tasks with the label `assign_to_manager`. Assign these to yourself

     2. At least take care of the task to get your new hire's Atlassian account created via a TEAM ticket

Ensure your new hire's Atlassian account is created before moving on

  5. the epic, use the "bulk edit" feature (in the "…" menu above the list of child issues, then "edit issues") to update the following fields:

     1. Set "Assignee" to be your new hire

  6. When you're ready to start using the kanban board, use the "bulk edit" feature again (but this time use the "transition" radio button) to transition all tickets to have the "To Do" status

  7. Give a link to the kanban board to your new hire, and show them how to use the filters.

All new hires will share the same kanban board for the project, but it can easily be filtered by "assignee" and "label".

##  Instructions (for new hires)

Welcome to Basis!

  1. Wait for your manager to do the stuff above.

  2. Filter the [Kanban board]((internal URL)) in the AEO project to show only your epic (Epic dropdown), and take a look at the "Label" filters to see in which order tickets should be done. Here are some additional Jira features you can use:

     1. Quick Filters to quickly filter to a particular timeframe (Day 1, Week 1, 30 Days, 60 Days)

     2. Group By -> Queries to group by Timeframes

     3. Tickets should also be color-coded by Timeframe

  3. Transition tickets to be "In Progress" as you work through them, and mark them as "Done" once completed. If any issues arise, add a comment, ping your manager or move the issue to be "Blocked".

If you find anything that looks wonky, let your manager know! Sometimes links change or tickets become irrelevant, so if you spot anything out of whack, let us know so we can update the template for the next new dev.

##  What to do if you need to fix something (for everyone)

We all make mistakes (or forget to update things as they change). Here's what to do if you find something that needs fixing:

_If the ticket has a description that needs updating (i.e. broken link, missing info etc.):_

  * update the ticket where you found the problem

  * find the ticket in the "TEMPLATE" epic with the same name (the "summary" field) and replace the description with the fixed version

 _If you think there 's something that's missing that deserves a new ticket for just the new hire:_

  * create a new ticket in the AEO project

  * set the "type" field to be "Task"

  * fill in the "summary" and "description" as is appropriate

  * update the "parent" field to be the new hire's epic

  * set the status to "To Do" to have it show up on the kanban board

 _If you think there 's something missing that deserves a new ticket for everyone:_

  * create a new ticket as above

  * clone the new ticket (using the "…" button)

  * update the "parent" field of the cloned ticket to be the "TEMPLATE" epic: AEO-604c33df4a-f75e-33b8-a8b8-5fcc9cdc091bSystem Jira

  * set the status of the template ticket to "Backlog" so that it does NOT show up on the kanban board

 _If you need to update the Jira automation rule to clone the template epic and its children:_

  * You need to get permissions to be an admin in the AEO (apps eng onboarding) project in Jira. Apply for that access through [this portal]((internal URL)).

  * Then edit and test and debug the automation rule [here]((internal URL)).

  * Jira's AI chatbot "Rovo" has been very helpful in the past with developing the Jira automation rules, highly recommended to use that to help troubleshoot any problems.
