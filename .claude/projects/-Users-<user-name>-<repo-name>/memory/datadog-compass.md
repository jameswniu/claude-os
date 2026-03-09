# Datadog / Compass / PagerDuty

Onboarding notes from Kyle Bernstein (Datadog/Compass monitoring) and Julian Selser (PagerDuty access). March 2026.

## Key Bookmarks (Datadog)

Kyle confirmed these are the correct and complete set for now:

- **Compass Production** — main production dashboard
- **Compass Staging02** — staging environment
- **Compass Staging55** — staging environment
- **Compass APM** — Datadog APM service page for `(project-name)`
  https://app.datadoghq.com/apm/entity/service%3A(project-name)?env=production

## Most Useful Datadog Features

- **APM** and **Logs** are the go-to tools

## Compass Dashboard Status

- No custom Compass dashboard yet
- Ticket planned for next sprint to add metrics + dashboard

## Alert Ownership

- `#compass_alerts` Slack channel is the team's channel (Juli set them up)
- Other teams manage their own alerts

## Staging Alerts

- Juan (Julian Selser) handles staging alerts
- Some alerts misconfigured due to Compass rename

## Basis Platform Dashboards

6 infra dashboards in the Datadog curated list:

1. RDS Database Metrics
2. Redis Health
3. Web Layer Metrics
4. Sidekiq Layer Metrics
5. RabbitMQ Dashboard
6. Controller Overview

## PagerDuty

- Will get paged for issues; sometimes need to create/escalate tickets
- **Access request**: Create a POS Jira ticket with "Access" type
  - Provide: full name, Basis email, user type, department
  - Turnaround: 1-3 business days
  - Guide: (internal URL)
- **POS ticket for access**: (internal URL) (access level TBD, pending Kyle/Julian input)

## On-Call Rotation

- Kyle is formalizing a support on-call rotation (coordinating with other teams)
- Currently first come first serve until the formal rotation is in place
- Kyle is always personally on backup call no matter what
- John Richardson is a teammate in the same Slack group
- On-call at Basis is generally not too bad (per John's experience)
- Kyle is documenting the on-call process before GA
