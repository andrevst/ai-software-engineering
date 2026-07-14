# CLAUDE.md — Project Template

Copy this file into your project root and fill in the sections below.

## Plugin activation

```
/ponytail full
/graphify
```

## Project context

<!-- One paragraph: what this repo is, what it owns, and what it does not own. -->

## Blast-radius layers

<!-- List modules/areas ordered from highest to lowest change risk. Agents use this to decide when to ask before acting. -->

<!--
Example (Terraform platform):
1. network — VPC, subnets, NLB (highest risk)
2. eks — EKS cluster, node groups
3. data — S3 buckets, Aurora, Secrets Manager
4. dns — Route53, ACM
5. k8s-access — EKS access entries (lowest risk)
-->

## Placeholder convention

<!-- Define intentional placeholder values so agents don't flag them as errors. -->

<!--
Example:
- `account_id = "000000000000"` — intentional placeholder, not a real account ID
- `REPLACE` — value that must be filled in by the operator before applying
-->

## Forbidden patterns

<!-- List patterns agents must never introduce. -->

<!--
Examples:
- No hardcoded AWS credentials anywhere in the repo
- No helm_release resources in Terraform modules
- No aws-auth ConfigMap patterns (cluster uses EKS Access Entries API mode)
- SUPABASE_SERVICE_ROLE_KEY must never appear in NEXT_PUBLIC_ variables
-->

## Project slash commands

<!-- List commands available in .claude/commands/ -->

<!--
| Command | File | Use when |
|---------|------|----------|
| `/project:tf-review` | `.claude/commands/tf-review.md` | Before any Atlantis PR |
| `/project:adr` | `.claude/commands/adr.md` | Recording a new architecture decision |
-->

## MCP servers in use

<!-- List which MCPs are active and what they connect to. -->

<!--
- grafana: https://grafana.internal — dashboards, alerts, Loki/Prometheus queries
- notion: team runbook workspace
-->
