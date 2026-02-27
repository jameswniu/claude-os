# AI Development Tools: Use-Case Library

Source: https://basis.atlassian.net/wiki/spaces/BET/pages/1559166979

This library contains examples of using GitHub Copilot and Claude Code to solve common engineering problems.

Each use case includes:
- The specific problem it solves
- Actual prompts that work

## Code Generation

**Generate a REST endpoint with tests**
```
Create a new GET /api/campaigns/:id/metrics endpoint.
Follow the existing pattern in src/api/routes/.
Include input validation in the service layer and add pytest tests.
```

**Generate a React component**
```
Create a CampaignCard component using React Query for data fetching
and styled-components for styling. Follow the pattern in src/components/CampaignList.
```

## Debugging

**Debug a stack trace**
```
! make test TEST_FILE=tests/api/test_campaigns.py
```
Then if it fails: `fix`

**Trace an API error**
```
This endpoint returns 500 in staging. Here's the stack trace: [paste].
Trace the issue from the route handler through the service layer.
```

## Code Review

**Review a PR for regressions**
```
/review BP-29421
```

**Blast radius analysis**
```
I'm removing the `legacy_format` field from CampaignResponse.
Find every file that references this field and assess the impact.
```

## Testing

**Generate comprehensive tests**
```
Read src/services/campaign_service.py and generate pytest tests.
Use createMockService() from tests/helpers. Include edge cases:
zero, negative, null, and overflow scenarios.
```
