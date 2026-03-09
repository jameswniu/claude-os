# Datadog Crash Course

Practical primer for Basis/Compass team usage.

## What Datadog Is

Monitoring/observability platform. Single place to answer "what's happening in production" and "what went wrong."

## Two Main Tools (per Kyle)

**APM (Application Performance Monitoring)**
- Traces of requests flowing through services
- Shows: which endpoint was hit, how long it took, what DB queries ran, where it got slow
- Team APM page: Compass APM bookmark for `(project-name)`
- Start here when: something is slow or erroring

**Logs**
- Searchable stream of application log output
- Filter by service, time range, error level, keywords
- Start here when: you need to see what actually happened (stack traces, specific error messages)

## Team Bookmarks (from Kyle)

- **Compass Production** - production dashboard
- **Compass Staging02** - staging dashboard
- **Compass Staging55** - staging dashboard
- **Compass APM** - APM service page (not a dashboard; it's the trace/performance view for `(project-name)`)

No custom Compass dashboard yet (ticket planned for next sprint).

## 6 Infra Dashboards (Curated)

1. RDS Database Metrics - DB CPU, connections, query performance
2. Redis Health - cache hit rates, memory usage
3. Web Layer Metrics - request volume, response times, error rates
4. Sidekiq Layer Metrics - background job queue depths, failures
5. RabbitMQ Dashboard - message queue health
6. Controller Overview - per-controller performance

## Typical Debugging Flow

1. Get paged or see alert in `#compass_alerts`
2. Open APM - look for red (errors) or latency spikes
3. Click into a failing trace to see full request path
4. Jump to Logs for detailed error/stack trace
5. Check relevant infra dashboard if it looks like a DB/Redis/queue issue

## Tips

- First thing: set the time window to when the issue started
- APM traces link directly to related logs (click through)
- Logs search works like grep: `service:(project-name) status:error`
