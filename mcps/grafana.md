# Grafana MCP

Connects Claude Code to a Grafana instance. Tested with Grafana Cloud and self-hosted Grafana OSS 10+.

## What it exposes

Full access to the Grafana ecosystem through natural-language tool calls:

**Dashboards**
- `search_dashboards` — find dashboards by title or tag
- `get_dashboard_by_uid` — retrieve full dashboard JSON
- `get_dashboard_summary` — condensed view (panels, data sources, variables)
- `get_dashboard_panel_queries` — extract PromQL/LogQL from each panel
- `update_dashboard` — modify a dashboard programmatically

**Datasources**
- `list_datasources`, `get_datasource` — enumerate and inspect connected data sources

**Prometheus (metrics)**
- `query_prometheus` — run PromQL instant or range queries
- `query_prometheus_histogram` — histogram_quantile convenience wrapper
- `list_prometheus_metric_names`, `list_prometheus_metric_metadata`
- `list_prometheus_label_names`, `list_prometheus_label_values`

**Loki (logs)**
- `query_loki_logs` — run LogQL queries
- `query_loki_patterns` — pattern extraction across log streams
- `query_loki_stats` — volume and throughput stats
- `list_loki_label_names`, `list_loki_label_values`
- `find_error_pattern_logs` — AI-assisted error cluster detection across log streams
- `find_slow_requests` — trace slow request patterns in log data

**Incidents (Grafana Incident)**
- `list_incidents`, `get_incident` — list and retrieve incidents
- `create_incident` — open a new incident
- `add_activity_to_incident` — append timeline entries
- `get_sift_analysis`, `get_sift_investigation`, `list_sift_investigations` — automated RCA

**Alerting**
- `list_alert_groups`, `get_alert_group` — browse firing alert groups
- `alerting_manage_rules` — create or update alert rules
- `alerting_manage_routing` — manage notification policies

**OnCall (Grafana OnCall)**
- `get_current_oncall_users` — who is on call right now
- `list_oncall_schedules`, `get_oncall_shift` — rotation details
- `list_oncall_teams`, `list_oncall_users`

**Annotations**
- `create_annotation`, `update_annotation`, `get_annotations`, `get_annotation_tags`

**Pyroscope (profiling)**
- `query_pyroscope`, `list_pyroscope_profile_types`, `list_pyroscope_label_names`

**Navigation**
- `generate_deeplink` — generate direct URLs to dashboards, panels, and Explore queries

## DevOps / SRE use cases

| Scenario | Tools |
|---------|-------|
| **Incident triage** | `find_error_pattern_logs` → `find_slow_requests` → `create_incident` → `add_activity_to_incident` |
| **SLO breach investigation** | `query_prometheus` (error rate, latency) → `query_loki_logs` (correlated logs) → `get_sift_analysis` |
| **Deployment validation** | `create_annotation` (mark deploy) → `query_prometheus` (compare pre/post) → `get_panel_image` (screenshot for report) |
| **Alert rule authoring** | `query_prometheus` (test the PromQL) → `alerting_manage_rules` (create rule) |
| **On-call awareness during deploys** | `get_current_oncall_users` before any prod change |
| **Runbook screenshot** | `get_panel_image` → embed in Notion runbook via Notion MCP |
| **Cost / capacity review** | `query_prometheus` (CPU/memory per namespace) → `query_loki_stats` (log volume by service) |

## Multi-instance setup

Configure a second Grafana instance (e.g., staging vs. production) as `grafana-w2` in settings. Tools are identical; the prefix distinguishes which instance to query.

## Notes

- Timestamp parameters without timezone offset are interpreted as UTC. Use `-05:00` offset or relative syntax (`now-1h`).
- `get_sift_analysis` requires Grafana Sift (available on Grafana Cloud).
- `get_panel_image` requires the Grafana Image Renderer plugin installed on the Grafana instance.
