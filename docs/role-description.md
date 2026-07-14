# Role Description — DevOps Managed Services with AIOps & Platform Engineering

Professional framing for CV, proposals, and client-facing positioning.

---

## Titles

| Context | Title |
|---------|-------|
| Technical audience | Principal Platform Engineer & AIOps Architect |
| Business / commercial | DevOps Managed Services Lead — Platform Engineering & AIOps |
| Consulting / fractional | AI-Augmented Platform Engineering Consultant |
| Broadest reach | Platform Engineering Lead \| DevOps as a Service \| AIOps |

---

## Professional Summary

Delivers DevOps Managed Services across the full maturity stack — from infrastructure stabilization and observability to GitOps-driven Platform Engineering and AI-assisted operations. Applies a structured AI toolchain (automated architecture analysis, parallel agent pipelines, AI Playbooks) to compress delivery timelines and surface risks that manual review misses. Drives clients from reactive managed services toward Internal Developer Platforms with AIOps capabilities as the target state.

---

## Maturity Model

```
Level 1 — Managed Services
  Reactive operations, defined SLAs, incident response, patching, monitoring.

Level 2 — AIOps
  AI-assisted triage, automated runbooks, intelligent alerting, pattern detection.

Level 3 — Platform Engineering  ← target state
  Internal Developer Platform, golden paths, self-service, GitOps, full observability.
```

The engagement model follows this path: we start where the client is and progressively build toward Platform Engineering as a product. AI accelerates every tier — from the initial architecture audit through ongoing operations.

---

## Responsibilities

### Level 1 — Managed Services

- Design and operate cloud infrastructure for client environments (AWS EKS, Terraform, Docker Compose) with defined SLAs and incident response runbooks
- Deliver dependency audits, security posture reviews, and architecture gap analyses as recurring service deliverables — automated via AI agent pipelines in hours rather than weeks
- Author and maintain Architecture Decision Records (ADRs) for all significant platform choices, creating a traceable decision audit trail for compliance reviews and team onboarding
- Maintain CLAUDE.md and AI Playbook configuration per client so platform knowledge is codified, queryable, and transferable across engineers

### Level 2 — AIOps

- Build AI-assisted incident workflows: Grafana MCP integration with Claude Code for real-time log triage (LogQL), metric correlation (PromQL), automated incident creation, and post-mortem drafting
- Codify recurring operational tasks as versioned AI Playbook prompt templates (Terraform review, ArgoCD onboarding, OTLP source onboarding, EKS access entry changes, FinOps cost reviews) — each executable by any AI agent given platform context
- Instrument three-layer automated security review on all code changes: regex pattern scanning against 25 OWASP Web Top 10 rules, LLM diff review, and agentic commit-time data flow analysis across files
- Maintain OWASP LLM Top 10 gap analysis per client engagement and implement mitigations (prompt injection test suites, PII exclusion from prompt context, MCP scope audits)

### Level 3 — Platform Engineering

- Design and deliver Internal Developer Platforms on Kubernetes: GitOps via ArgoCD (app-of-apps pattern), Karpenter node pool split (system / stateful / elastic), IRSA per-component scoping, Terraform state organized by blast-radius layer
- Build central observability platforms (Grafana LGTM stack: Mimir, Loki, Tempo) with multi-tenant OTLP ingest via AWS PrivateLink and per-tenant attribution at the OTel gateway layer (no SDK-level tenant awareness required from product teams)
- Generate and maintain full architecture documentation: C4 diagrams (system context through code level), Mermaid stack diagrams, component deep-dive reports, and development guidelines — all produced automatically from codebase analysis
- Define client-specific AI operating models: plugin activation (ponytail, graphify, security-guidance), project slash commands, agent safety guardrails (blast-radius layers, placeholder conventions, forbidden patterns), and parallel agent pipelines for recurring analytical workloads

---

## Key Achievements

- Ran 20+ parallel AI agents to produce a full architecture analysis, 10 ADRs, C4 diagrams, and Mermaid stack diagrams for a client codebase in a single session — equivalent to 2–3 engineer-weeks of manual work
- Identified 10 critical security and operational gaps (Kong EOL, non-atomic DB transactions, RLS enforcement bypass, broken production auth redirect) in an inherited codebase before first production deployment
- Reduced ADR generation time from manual drafting (~4h per ADR) to ~90 seconds per ADR using 10 parallel agents
- Detected and removed 132 unnecessary lines from production Terraform via AI-assisted code review with zero functional change and zero test regressions
- Built a reusable AI Playbook covering 8 DevOps task types, each a self-contained prompt template executable by any AI agent — eliminating the need to re-derive platform context on every recurring task

---

## Technical Stack

### Infrastructure & Platform

| Layer | Tools |
|-------|-------|
| Cloud | AWS (EKS, EC2, S3, Aurora, Secrets Manager, PrivateLink, Route53, IAM) |
| IaC | Terraform (blast-radius modules), Atlantis (PR automation) |
| GitOps | ArgoCD (app-of-apps), Karpenter, Helm |
| Containers | Kubernetes, Docker, Docker Compose |
| Observability | Grafana LGTM (Mimir, Loki, Tempo), OpenTelemetry, ADOT |
| Auth | AWS IAM, IRSA, EKS Access Entries, Supabase GoTrue, PostgreSQL RLS |

### AI Toolchain

| Category | Tools |
|---------|-------|
| Core | Claude Code (CLI + IDE), Claude API (Opus 4.8, Sonnet 4.6, Haiku 4.5) |
| Plugins | devfullcycle (project-analizer, adrs-management, diagrams-generator, development-guidelines), superpowers, ponytail, security-guidance |
| MCPs | Grafana, Notion, Google Drive, GitHub, Linear, Terraform, Playwright, context7 |
| Skills | graphify (knowledge graph), systematic-debugging, dispatching-parallel-agents |
| Security | security-guidance (25 OWASP rules + LLM diff review + agentic commit review) |

### Application

| Layer | Tools |
|-------|-------|
| Backend | Next.js 15 (App Router, Server Actions, RSC), Node.js, TypeScript |
| Database | PostgreSQL 17, Supabase (PostgREST, Realtime, Storage), Row Level Security |
| Frontend | Tailwind CSS v4, React |
| Observability | Sentry (3 runtimes: server, client, edge) |

---

## Proposal Language

### For technical decision-makers

> The engagement follows a three-tier maturity path. We start with infrastructure stabilization, defined runbooks, and automated dependency and security audits. From there we introduce AIOps capabilities — AI-assisted incident triage, intelligent alerting, and codified operational playbooks that any engineer can run. The target state is Platform Engineering: a self-service Internal Developer Platform where teams ship faster because the platform handles the complexity.
>
> AI is not an add-on at the top of the stack. It compresses every tier: the initial architecture audit runs in hours instead of weeks, ADRs are generated automatically from codebase evidence, security review is continuous rather than periodic, and operational knowledge is captured in versioned prompt templates rather than tribal memory.

### For business stakeholders

> We manage your infrastructure so your engineering team can focus on product. As your platform matures, we progressively reduce manual operational burden and increase automation — from AI-assisted monitoring that surfaces issues before they page, to a self-service developer platform where deploying a new service is a pull request, not a two-week project.
>
> Every step is documented. Every decision has a traceable record. And every recurring task is codified so it can be audited, improved, and handed off.

---

## Open Questions to Sharpen Positioning

Before finalizing for a specific CV or proposal, clarify:

1. **Delivery model** — solo consulting, fractional, or agency with a team?
2. **Target market** — startups, scale-ups, or enterprise? Which sector (fintech, health, general tech)?
3. **Language** — English CV, Portuguese CV, or both?
4. **Primary differentiator to lead with** — the AI toolchain, the Platform Engineering maturity model, or the managed service SLA?
