# Basis Platform Monitoring Guide

Source: (internal URL)

# Overview

[DataDog](http://datadog.centro.net/) offers multiple ways to collect and visualize metrics. Each application we maintain here at Basis Tech should appear on the [Datadog Services](https://app.datadoghq.com/software?env=production&fromUser=true&start=1770653905454&end=1770657505454) page. This page is the best place to start when exploring the services and applications. The services have a related dashboards option that lets you find related dashboards.

[APM Services Page](https://app.datadoghq.com/software?env=production&fromUser=true&start=1770653905454&end=1770657505454)

Each application or service is expected to monitor the performance and health of its components. The Basis Platform Ecosystem comprises several services, with a UI powered by a Ruby on Rails backend. This singular UI created a common entry point for all requests. 

Examples of requests moving through Basis Platform

  * Basis UI -> DSP Gateway -> API Self Services

  * Basis UI -> Analytics Service -> Basis Datamart (Snowflake)

If you need to ask question please feel free to post them in the [tools-datadog](https://centro.slack.com/archives/C07E2P8U4LB) slack channel

# Measures and Gauges

<https://docs.datadoghq.com/metrics/>

<https://docs.datadoghq.com/metrics/open_telemetry/>

<https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python>

While StatsD accepts only metrics, DogStatsD accepts all three of the major Datadog data types: metrics, events, and service checks. This section shows typical use cases for metrics split down by metric types, and introduces [sampling rates](https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python#sample-rates) and [metric tagging](https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python#metric-tagging) options specific to DogStatsD.

[COUNT](https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python#count), [GAUGE](https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python#gauge), and [SET](https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python#set) metric types are familiar to StatsD users. `TIMER` from StatsD is a sub-set of `HISTOGRAM` in DogStatsD. Additionally, you can submit [HISTOGRAM](https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python#histogram) and [DISTRIBUTION](https://docs.datadoghq.com/metrics/custom_metrics/dogstatsd_metrics_submission/?tab=python#distribution) metric types using DogStatsD.

## Tags

Tagging is used throughout Datadog to query the metrics, traces, events, and other observables. Using consistent tags to provide meaning to the metrics you are collecting. The <https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/?tab=kubernetes#aws-lambda-functions> is a strategy the we must follow with Datadog.

DataDog Metric and Log Tags

<https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging/?tab=kubernetes#aws-lambda-functions>

<https://docs.datadoghq.com/getting_started/tagging/assigning_tags?tab=noncontainerizedenvironments>

## Setup

The Datadog documentation provides guides for setting up their Datadog SDK for a variety of languages.

[https://docs.datadoghq.com/opentelemetry/instrument/dd_sdks/api_support/?platform=traces&prog_lang=java](https://docs.datadoghq.com/opentelemetry/instrument/dd_sdks/api_support/?platform=traces&prog_lang=java)

# Monitoring

Datadog is our observability platform for collecting and visualizing metrics, logs, traces, and uptime checks across services. Teams use it to build dashboards, set actionable alerts, and investigate issues via APM traces and log correlation. Expectations: each service should (1) emit standard tags (env, service, version, team), (2) maintain at least one service dashboard, and (3) configure alerts for key SLOs, error rates, latency, and resource saturation.

[Monitor List](https://app.datadoghq.com/monitors/manage?order=desc&p=1&sort=modified) is where you can view the monitors that have been created.

Minimum Service Requirements mentions monitoring as required for any new service or application.

### Rules for creating a monitor

  * add tags for identifying who and what.

    * `team` tag to identify who maintains the monitor

    * `service` tag for the application or service name

    * `env` tag to identify the environment

  * Create meaningful monitors that users should take action on.

  * Include instructions and next steps in the monitor's output.

  * Have a dashboard or Datadog page you can link to the user to.

### Resources

  * <https://docs.datadoghq.com/monitors/>

# Dashboards

We use the metrics we collect in Datadog to build focused dashboards that visualize how our systems are performing in real time. By grouping related metrics and gauges into clear views--such as service health, infrastructure, and application performance--we can quickly spot anomalies, track trends, and drill into potential issues before they impact users. These dashboards act as our shared source of truth for operational visibility, helping teams monitor SLIs/SLOs, understand the impact of changes, and make data-driven decisions about reliability and performance.

## Basis Platform Health

This dashboard is designed to provide any team with a "bird's eye" view of the Health of the Basis Platform as a whole. The idea is that each application should have its own dashboard, and that observables from each application that indicate a major problem should be surfaced there.

[Dashboard Link](https://app.datadoghq.com/dashboard/q8j-ius-6d2/basis-platform-health?fromUser=false&refresh_mode=sliding&tile_focus=3153095383310314&tpl_var_dbinstanceidentifier%5B0%5D=cmm-production&tpl_var_env%5B0%5D=production&tpl_var_redis_cluster_id%5B0%5D=buda-reporting-production-redis-7-rg-001&tpl_var_redis_cluster_id%5B1%5D=production-rg-001&tpl_var_redis_cluster_id%5B2%5D=buda-reporting-production-redis-7-rg-002&tpl_var_redis_cluster_id%5B3%5D=buda-reporting-production-redis-7-rg-003&tpl_var_redis_cluster_id%5B4%5D=production-rg-002&tpl_var_redis_cluster_id%5B5%5D=production-rg-003&from_ts=1770475973508&to_ts=1770648773508&live=true)

### Use Case

[Basis Platform Health Jan 13, 6:00 am - Jan 24, 10:00 pm ](https://app.datadoghq.com/dashboard/q8j-ius-6d2?fromUser=true&refresh_mode=paused&tpl_var_dbinstanceidentifier%5B0%5D=cmm-production&tpl_var_env%5B0%5D=production&tpl_var_redis_cluster_id%5B0%5D=buda-reporting-production-redis-7-rg-001&tpl_var_redis_cluster_id%5B1%5D=production-rg-001&tpl_var_redis_cluster_id%5B2%5D=buda-reporting-production-redis-7-rg-002&tpl_var_redis_cluster_id%5B3%5D=buda-reporting-production-redis-7-rg-003&tpl_var_redis_cluster_id%5B4%5D=production-rg-002&tpl_var_redis_cluster_id%5B5%5D=production-rg-003&from_ts=1768305600000&to_ts=1769313600000&live=false)

[Basis Platform Health - Jan 23, 6:00 am - Feb 3, 10:00 pm](https://app.datadoghq.com/dashboard/q8j-ius-6d2?fromUser=true&refresh_mode=paused&tpl_var_dbinstanceidentifier%5B0%5D=cmm-production&tpl_var_env%5B0%5D=production&tpl_var_redis_cluster_id%5B0%5D=buda-reporting-production-redis-7-rg-001&tpl_var_redis_cluster_id%5B1%5D=production-rg-001&tpl_var_redis_cluster_id%5B2%5D=buda-reporting-production-redis-7-rg-002&tpl_var_redis_cluster_id%5B3%5D=buda-reporting-production-redis-7-rg-003&tpl_var_redis_cluster_id%5B4%5D=production-rg-002&tpl_var_redis_cluster_id%5B5%5D=production-rg-003&from_ts=1769169600000&to_ts=1770177600000&live=false)

### Features

  * Goal numbers

  * Basis UI Metrics

  * Sidekiq Metrics

  * RDS Database Metrics

  * Redis Metrics

  * RabbitMQ Metrics

  * Application Specific Metrics

    * Analytics Service

    * Auth Service

    * Basis API

    * Buda Reporting

    * Credentials For Third Party Oauth Service

    * DSP

    * Walled Gardens

## CMM Explorer

This dashboard is an experiment to see how we can use a dashboard to bisect a given trace or a set of traces. The explorer provides a set of graphs that are colocated to enable the user to compare their narrowly focused request with other areas of concern, helping them understand what is slowing the request.

[Dashboard Link](https://app.datadoghq.com/dashboard/38u-iqt-u4y/cmm-explorer?fromUser=false&refresh_mode=paused&from_ts=1770221184459&to_ts=1770393984459&live=false)

### Features

  * Garbage Collection

  * Database query latency

  * Redis memory usage

  * Host CPU or Memory Usage

  * Slow Endpoints Table 

## APM Service Dashboards

The APM service base allows you to associate dashboards with a specific service. We should leverage this feature to associate all our dashboards with their respective services.

From the [APM Services page](https://app.datadoghq.com/software?env=production&fromUser=true&selectedEnv=production&selectedService=basis&start=1770654505819&end=1770658105819) you can find related dashboards. If you know of a dashboard that should be related to a service, you can add it here.

## Application Dashboards

Here is a list of existing Dashboards that teams have already created. 

### Dashboards List

**Dashboards**| **Service**| **notes**  
---|---|---  
[RDS Database Metrics](https://app.datadoghq.com/dashboard/7qc-jz6-cas?fromUser=false&refresh_mode=sliding&from_ts=1767979517755&to_ts=1770657917755&live=true)| Basis|   
[Basis Error Dashboard](https://app.datadoghq.com/dashboard/f7i-pjc-fqu?fromUser=false&overlay=events&overlayQuery=service%3Abasis%20%40http.status_code%3A50%2A%20env%3Aproduction&refresh_mode=sliding&from_ts=1770053117941&to_ts=1770657917941&live=true)| Basis|   
[Basis Platform Health](https://app.datadoghq.com/dashboard/q8j-ius-6d2?fromUser=false&refresh_mode=sliding&from_ts=1770485118943&to_ts=1770657918943&live=true)| Basis|   
[Basis Platform Web Layer](https://app.datadoghq.com/dashboard/qwr-a2q-hxf?fromUser=false&refresh_mode=sliding&from_ts=1769102720112&to_ts=1770657920112&live=true)| Basis|   
[BP - Sidekiq Worker Health](https://app.datadoghq.com/dashboard/psj-9fk-pp7/bp-sidekiq-worker-health?fromUser=false&refresh_mode=sliding&from_ts=1770643891708&to_ts=1770658291708&live=true)| Basis|   
[CMM Explorer](https://app.datadoghq.com/dashboard/38u-iqt-u4y/cmm-explorer?fromUser=false&refresh_mode=paused&tpl_var_cmm_resource_name%5B0%5D=%2A&tpl_var_dbinstanceidentifier%5B0%5D=%2A&tpl_var_env%5B0%5D=production&tpl_var_host%5B0%5D=%2A&tpl_var_query_basis_resource_name%5B0%5D=%22Direct%3A%3ACampaignTableController%23index%22&tpl_var_query_postgres_resource_name%5B0%5D=%2A&from_ts=1770221184459&to_ts=1770393984459&live=false)| Basis|   
[Rails App Performance Monitoring](https://app.datadoghq.com/dashboard/tnb-5ai-bz3/rails-app-performance-monitoring?fromUser=false&overlay=changes&overlayQuery=service%3Abasis%20auto%3Atrue&refresh_mode=sliding&from_ts=1770063097665&to_ts=1770667897665&live=true)| Basis|   
[Analytics Service ](https://app.datadoghq.com/dashboard/u4c-3ss-h2p?fromUser=false&refresh_mode=sliding&from_ts=1770663123533&to_ts=1770666723533&live=true)| Analytics Service|   
[Walled Gardens](https://app.datadoghq.com/dashboard/d29-8kx-ace?fromUser=false&refresh_mode=sliding&from_ts=1770495169593&to_ts=1770667969593&live=true)| Walled Gardens|   
[Two Way Sync](https://app.datadoghq.com/dashboard/z4n-56v-d9w/two-way-sync?fromUser=false&refresh_mode=sliding&from_ts=1770664706383&to_ts=1770668306383&live=true)| Two Way Sync|   
[Financial Layer Servce](https://app.datadoghq.com/dashboard/duj-a6s-cki?fromUser=false&refresh_mode=sliding&from_ts=1770664581432&to_ts=1770668181432&live=true)| Financial Service|   
[Buda Reporting Overview](https://app.datadoghq.com/dashboard/6cc-ad4-b95?fromUser=false&refresh_mode=sliding&tpl_var_env%5B0%5D=production&from_ts=1770401493902&to_ts=1770405093902&live=true)| Buda Reports|   
  
# Other Resources

  * Monitoring Metrics from EKS and EC2 Environments

  * <https://learn.datadoghq.com/>
