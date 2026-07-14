# AI Tools Reference — DevOps as a Service with AI

**Last updated:** 2026-07-14  
**Source:** Built from a full Claude Code plugin session (FamilyHub + k8s_project LGTM platform). All tools, MCPs, and skills were tested in production-like conditions.

---

## 1. Claude Code Plugin Marketplaces

Three plugin marketplaces are installed and tested.

### 1.1 devfullcycle (`devfullcycle/claude-mkt-place`)

Four plugins covering the full analysis-to-documentation pipeline.

#### `project-analizer` (sic)

Multi-phase, multi-agent codebase analysis. Three specialized sub-agents.

| Agent | Purpose | Output |
|-------|---------|--------|
| `dependency-auditor` | CVE scan, EOL detection, version drift | `docs/agents/dependency-auditor/dependencies-report-YYYY-MM-DD.md` |
| `architectural-analyzer` | Component map, 39-component inventory, critical findings | `docs/agents/architectural-analyzer/architectural-report-YYYY-MM-DD.md` |
| `component-deep-analyzer` | Deep-dive per component: business rules, test coverage, security | `docs/agents/component-deep-analyzer/component-analysis-NAME-YYYY-MM-DD.md` |

Commands:
- `/run-dependency-audit` — standalone dependency audit
- `/generate-architectural-report` — full pipeline (Phases 1–6): MANIFEST init → dependency + arch in parallel → component deep-dives in parallel → PROJECT-OVERVIEW synthesis → README index
- `/run-component-analysis` — targeted single-component analysis

**DevOps/SRE use cases:**
- Pre-release dependency CVE gate (complements `npm audit`, `trivy`)
- Platform onboarding audit for inherited codebases
- Architecture drift detection between design docs and actual code
- Security posture snapshot for compliance reviews

**Findings from FamilyHub run:**
- Kong 2.8.x identified as 15+ months past EOL
- GoTrue CVE-2026-31813 (CVSS 4.8) flagged
- ADR-001 stated Postgres 16; actual image was 17.6.1 — caught automatically
- Non-atomic `createFamily()` and `kid_visible` RLS gap surfaced from component analysis, not manual review

#### `adrs-management`

Four-phase ADR pipeline. Three sub-agents.

| Agent | Phase | Input → Output |
|-------|-------|---------------|
| `adr-analyzer` (phase 1) | Map | codebase → `docs/adrs/mapping.md` with module sizes |
| `adr-analyzer` (phase 2) | Identify | mapping.md → `docs/adrs/potential-adrs/` (must-document + consider tiers) |
| `adr-generator` | Generate | single potential ADR file → formal MADR in `docs/adrs/generated/MODULE/` |
| `adr-linker` | Link | all ADR files → bidirectional Markdown link graph |

Commands:
- `/adr-map` — phase 1
- `/adr-identify` — phase 2 (per module, parallelizable)
- `/adr-generate` — phase 3 (one per potential ADR; launch in parallel)
- `/adr-link` — phase 4 (idempotent, safe to re-run)

**DevOps/SRE use cases:**
- Document infrastructure choices on greenfield platforms before they become tribal knowledge
- Retroactively capture IaC decisions on inherited platforms (Terraform module split rationale, state file topology)
- Generate ADRs for multi-cloud or hybrid patterns (AWS + GCP, Kubernetes vs ECS vs Lambda)
- Compliance: traceable decision audit trail for SOC 2 / ISO 27001

**Tip:** Run `adr-generator` agents in parallel (one per potential ADR file) — 10 agents in parallel took ~90 seconds total vs. sequential ~15 minutes.

#### `diagrams-generator`

Two diagram agents for C4 and Mermaid output.

| Agent | Format | Input |
|-------|--------|-------|
| `c4-diagram-generator` | PlantUML C4 (C1–C4 levels) | FDD or architecture doc |
| `mermaid-diagram-generator` | Mermaid (8 diagram types) | FDD or architecture doc |

Commands:
- `/generate-c4 <path-to-fdd.md>` — generates `.puml` files + analysis `.md`
- `/generate-mermaid <path-to-fdd.md>` — generates `diagrams.md` with embedded Mermaid

**DevOps/SRE use cases:**
- Auto-generate runbook diagrams from infrastructure specs
- Container topology visualization from Docker Compose / Kubernetes manifests
- Auth flow sequence diagrams for security reviews
- ER diagrams for database schema documentation

**No FDD? No problem:** `docs/stack.md` (a comprehensive service map with runbook) worked as FDD substitute — the agents extracted sufficient structure from it.

#### `development-guidelines`

Command: `/guidelines-generate`

Generates project-specific development guidelines document. Output in FamilyHub: 1,726-line TypeScript guidelines with 82 code blocks, 26 sections. Includes DevOps-specific patterns: Zod env validation, AsyncLocalStorage correlation IDs, Result types, AbortSignal patterns for graceful shutdown.

**DevOps/SRE use cases:**
- Codify IaC standards (Terraform module conventions, IRSA scoping rules)
- Generate platform engineering onboarding guidelines
- Produce AI-readable guardrails for sub-agent prompts

---

### 1.2 Superpowers (`anthropics/claude-plugins-official`)

Process skills that change how Claude Code approaches tasks. Invoke via `/skill superpowers:<name>`.

| Skill | When to use |
|-------|------------|
| `brainstorming` | Before any new feature or architecture design — enumerate options before deciding |
| `systematic-debugging` | Incident RCA, flaky test investigation, infrastructure drift |
| `writing-plans` | Before a multi-step infrastructure change; get alignment before touching prod |
| `executing-plans` | Step-by-step execution of an approved plan with checkpoints |
| `subagent-driven-development` | Decompose complex tasks across parallel agents |
| `dispatching-parallel-agents` | Fire N independent agents simultaneously (e.g., 10 ADR generators) |
| `using-git-worktrees` | Parallel branch work without checkout conflicts |
| `verification-before-completion` | Checklist gate before marking any task done |
| `requesting-code-review` | Structured PR description generation |
| `receiving-code-review` | Process review feedback systematically |

**Other notable plugins in `claude-plugins-official`:**

| Plugin | Purpose |
|--------|---------|
| `code-review` / `pr-review-toolkit` | Automated PR review with configurable depth |
| `session-report` | End-of-session summary and handoff document |
| `hookify` | Claude Code hook configuration assistant |
| `security-guidance` | Security review checklist generator |
| `mcp-server-dev` | Scaffold new MCP servers |
| `mcp-tunnels` | Expose local MCP servers through tunnels |
| `feature-dev` | Feature development workflow |
| `project-artifact` | Project artifact management |
| `skill-creator` | Create new skills from patterns |
| `ralph-loop` | Autonomous loop patterns |
| `agent-sdk-dev` | Claude Agent SDK scaffolding |

---

### 1.3 Ponytail (`DietrichGebert/ponytail`)

Lazy senior developer mode. Enforces YAGNI, deletion over addition, stdlib first.

| Level | Behavior |
|-------|---------|
| `full` (default) | Ladder enforced: YAGNI → reuse → stdlib → native → installed dep → one line → minimum code |
| `lite` | Suggestions only, no blocking |
| `ultra` | Maximum deletion pressure |

Skills: `ponytail`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-review`, `ponytail-help`

**Proven result on k8s_project:** Ponytail audit on Terraform code found 132 removable lines — unused variables, duplicated locals, over-specified tag merges, unnecessary outputs. Zero functional changes.

**DevOps/SRE use cases:**
- Terraform module review before Atlantis PRs
- Helm values pruning (remove chart defaults that were explicitly set)
- Docker Compose simplification
- GitHub Actions workflow deduplication
- IRSA policy over-scoping detection

---

## 2. MCP Servers

### 2.1 Connected in This Setup

| MCP | Tools | DevOps/SRE Use |
|-----|-------|---------------|
| `grafana` | Dashboards, PromQL, LogQL, Loki, incidents, on-call, alerting | Query metrics during incidents; create annotations; manage on-call shifts |
| `grafana-w2` | Same as above (second Grafana instance) | Multi-environment Grafana federation |
| `claude_ai_Notion` | Create/update pages, databases, comments | Runbook authoring; incident post-mortem documentation |
| `claude_ai_Google_Drive` | Read/write/search files | Shared architecture docs; compliance artifacts |
| `claude_ai_Gmail` | Send/read email | Incident notification drafting; vendor communications |
| `claude_ai_Google_Calendar` | Event management | On-call schedule coordination; maintenance windows |

**Grafana MCP capabilities (DevOps focus):**
- `query_loki_logs` / `find_error_pattern_logs` — AI-assisted log triage during incidents
- `find_slow_requests` — SLO breach investigation
- `create_incident` / `add_activity_to_incident` — AI-driven incident management
- `alerting_manage_rules` — Alert rule authoring from Claude Code
- `get_sift_analysis` / `get_sift_investigation` — Automated root cause analysis
- `get_current_oncall_users` — On-call rotation awareness during deployments

### 2.2 External Plugin MCPs (`claude-plugins-official`)

Available as installable external plugins:

| MCP | Category | Use Case |
|-----|---------|---------|
| `context7` | Documentation | Real-time library docs in context (no hallucinated APIs) |
| `github` | SCM | PR creation, issue management, release drafting |
| `gitlab` | SCM | Same for GitLab-hosted repos |
| `terraform` | IaC | Terraform plan/apply from Claude Code |
| `linear` | Project management | Ticket creation from architectural findings |
| `asana` | Project management | Sprint management |
| `playwright` | Testing | Browser automation; UI smoke tests post-deploy |
| `greptile` | Code search | Semantic codebase search across large repos |
| `serena` | LSP | Language server integration for accurate refactoring |
| `firebase` | Backend | Firebase project management |

---

## 3. Graphify Skill

Installed globally via `~/.claude/CLAUDE.md`. Trigger: `/graphify`.

Turns any input (code, docs, papers, images, videos) into a persistent knowledge graph with community detection, god nodes, and an audit trail. Three outputs per run: interactive HTML visualization, GraphRAG-ready JSON, and `GRAPH_REPORT.md` in plain language.

### Commands

```bash
/graphify                            # full pipeline on current directory
/graphify <path>                     # specific path
/graphify https://github.com/org/repo  # clone + graph
/graphify <url1> <url2>              # multi-repo merge into single graph
/graphify <path> --mode deep         # thorough extraction, richer inferred edges
/graphify <path> --update            # incremental — only new/changed files
/graphify <path> --directed          # preserve edge direction (source→target)
/graphify <path> --mcp               # start MCP stdio server for agent access
/graphify <path> --wiki              # agent-crawlable wiki (index.md + one page per community)
/graphify <path> --obsidian          # write Obsidian vault
/graphify <path> --neo4j-push bolt://localhost:7687  # push to Neo4j
/graphify <path> --falkordb-push falkordb://localhost:6379
/graphify query "<question>"         # BFS traversal — broad context
/graphify query "<question>" --dfs   # DFS — trace a specific path
/graphify path "AuthModule" "Database"  # shortest path between two concepts
/graphify explain "SwinTransformer"  # plain-language explanation of a node
```

**Fast path:** If `graphify-out/graph.json` exists and the request is a question about the codebase, graphify queries the existing graph directly — no rebuild.

### Export formats

HTML (default), SVG, GraphML (Gephi/yEd), Neo4j Cypher, FalkorDB Cypher

### Works on

Code, Markdown docs, PDFs/papers, images, video/audio (Whisper transcription)

### DevOps/SRE use cases

| Use case | Command |
|---------|---------|
| Map Terraform module dependency graph | `/graphify terraform/modules --directed` |
| Visualize service-to-service call graph | `/graphify src --mode deep` |
| Multi-repo platform architecture graph | `/graphify https://github.com/org/infra https://github.com/org/app` |
| Agent-browsable runbook wiki | `/graphify docs --wiki` |
| Sync to team Obsidian vault | `/graphify . --obsidian --obsidian-dir ~/vaults/platform` |
| Feed graph to RAG pipeline | `/graphify . --no-viz` → use `graphify-out/graph.json` |
| Watch mode for live docs update | `/graphify docs --watch` |

The `--mcp` flag makes graphify available as an MCP tool — any connected agent can call `graphify query` without re-running the full pipeline.

---

## 4. Security Tooling

### 4.1 `security-guidance` (claude-plugins-official)

Install: `/plugin install security-guidance@claude-plugins-official`

Three-layer automatic security review wired into the Claude Code edit/commit cycle:

| Layer | Trigger | What it does |
|-------|---------|-------------|
| 1. Pattern warnings | Every `Edit`/`Write` tool call | Regex match against 25 known-dangerous patterns; blocks the response with an inline warning |
| 2. LLM diff review | End of each Claude turn (Stop hook) | Sends the full diff to Opus 4.8 for semantic review; feeds high-severity findings back to Claude before you see the response |
| 3. Agentic commit review | `git commit` | Spawns an SDK agent that reads related files (`Read`/`Grep`/`Glob`) and traces data flow across the codebase — catches multi-file vulnerabilities (IDOR, auth bypass, SSRF) that single-file pattern matching misses |

**25 Pattern rules by OWASP Web Top 10 class:**

| OWASP Class | Rules |
|------------|-------|
| A03 Injection | `child_process_exec`, `eval_injection`, `new_function_injection`, `os_system_injection`, `python_subprocess_shell`, `go_exec_shell_injection`, `github_actions_workflow` |
| A07 XSS | `react_dangerously_set_html`, `document_write_xss`, `innerHTML_xss`, `outerHTML_xss`, `insertAdjacentHTML_xss`, `script_src_without_sri` |
| A08 Insecure Deserialization | `pickle_deserialization`, `pickle_variants_load`, `pickle_wrapper_load`, `marshal_loads`, `shelve_open`, `torch_unsafe_load` |
| A05 Security Misconfiguration | `unsafe_yaml_load`, `yaml_unsafe_load_variants`, `xml_unsafe_parse`, `tls_verification_disabled` |
| A02 Crypto Failures | `node_createcipher_no_iv`, `aes_ecb_mode` |

**Configuration:**

```bash
# Disable specific layers
ENABLE_PATTERN_RULES=0         # disable regex layer
ENABLE_STOP_REVIEW=0           # disable LLM diff review (useful in multi-agent setups)
ENABLE_COMMIT_REVIEW=0         # disable agentic commit reviewer
SECURITY_GUIDANCE_DISABLE=1    # kill switch

# Higher recall (2× cost)
SG_DUAL_OR=on                  # two parallel review calls, union of findings

# Custom model
SECURITY_REVIEW_MODEL=claude-opus-4-8

# Org-specific policy file (add project-specific rules)
# .claude/claude-security-guidance.md
```

**Custom policy pattern (DevOps use):**
```markdown
# Platform security rules
- All DB queries must use parameterized statements via the supabase client, never string concatenation.
- SUPABASE_SERVICE_ROLE_KEY must never appear in client-side bundles or Next.js NEXT_PUBLIC_ variables.
- child_visible RLS must be verified present on every new cards table query that filters by family_id.
```

**Coverage gaps vs. OWASP Web Top 10:** A01 (Broken Access Control) and A04 (Insecure Design) require semantic reasoning — the LLM diff review (layer 2) and agentic commit review (layer 3) cover these but without dedicated pattern rules.

---

### 4.2 OWASP LLM Top 10 — Gap Analysis

The available tooling covers OWASP **Web** Top 10 well. For AI/LLM-specific threats (OWASP LLM Top 10, 2025 edition), there is no dedicated installed tool. Current coverage and gaps:

| OWASP LLM Risk | Current Coverage | Gap |
|---------------|-----------------|-----|
| **LLM01 Prompt Injection** | Claude Code refuses malicious prompt injection by system prompt | No automated scanner for user-facing prompts in application code |
| **LLM02 Insecure Output Handling** | `innerHTML_xss`, `react_dangerously_set_html` catch LLM output rendered as HTML | No check that LLM output is sanitized before DB writes or shell calls |
| **LLM03 Training Data Poisoning** | Out of scope for application-layer tooling | No tooling |
| **LLM04 Model DoS** | No coverage | No rate-limit or token-budget enforcement checker |
| **LLM05 Supply Chain** | `dependency-auditor` plugin catches outdated AI SDK versions | No model provenance or SBOM tooling for ML models |
| **LLM06 Sensitive Info Disclosure** | `security-guidance` catches hardcoded secrets in patterns | No check that PII/PHI is excluded from prompt context |
| **LLM07 Insecure Plugin Design** | `mcp-server-dev` plugin includes tool-design security references | No automated MCP permission scope auditor |
| **LLM08 Excessive Agency** | Claude Code's built-in confirmation prompts for destructive actions | No formal principle-of-least-privilege auditor for agent tool grants |
| **LLM09 Overreliance** | Human-in-the-loop by design (user approves tool calls) | No hallucination detection in generated outputs |
| **LLM10 Model Theft** | Out of scope | No tooling |

**What to build / install for DevOps-as-a-Service AI security:**

1. **Custom `claude-security-guidance.md` for AI output paths** — project-level policy file that adds rules: "LLM output rendered to DOM must pass through DOMPurify", "prompt context must not include raw DB rows from tables with PII columns".

2. **Prompt injection test suite** — add to CI: fuzz the application's AI-facing endpoints with OWASP LLM Top 10 test payloads (available at `owasp.org/www-project-llm-top-10`).

3. **MCP scope auditor** — a `ponytail-audit`-style review that checks each MCP server's exposed tools against the principle of least privilege: read-only MCPs should not expose write tools.

4. **AI dependency audit** — extend the `project-analizer` dependency audit to flag AI-specific supply chain risks: pinned model IDs vs. floating aliases (`claude-sonnet-latest` vs `claude-sonnet-4-6`), SDK versions, and embedding model versions.

---

## 5. AI Playbook Patterns (from k8s_project LGTM Platform)

Eight structured agent workflows, each a self-contained prompt template that any AI assistant can execute. From `/Users/andre/Work/arqui.dev/k8s_project/docs/AI-PLAYBOOK.md`.

| # | Playbook | Model | When |
|---|---------|-------|------|
| 1 | Terraform module change review | Sonnet 4.6 | Before every Atlantis PR |
| 2 | ArgoCD application onboarding | Sonnet 4.6 | Adding new platform component |
| 3 | Access entry change | Haiku 4.5 | IAM/EKS access modifications |
| 4 | ADR writing | Opus 4.8 | New tool selection or design decision |
| 5 | OTLP source onboarding guide | Opus 4.8 | Product team telemetry setup |
| 6 | LGTM component version upgrade | Sonnet 4.6 | Helm chart version bumps |
| 7 | PrivateLink consumer setup | Sonnet 4.6 | Source account network connectivity |
| 8 | Cost attribution / FinOps query | Sonnet 4.6 | Per-tenant cost analysis, S3 growth |

**Model selection rationale from k8s_project:**
- Opus 4.8: long-form reasoning, trade-off synthesis, multi-page documentation
- Sonnet 4.6: code analysis, YAML/HCL generation, cross-file analysis
- Haiku 4.5: narrow, structured output, low complexity, low latency

**Project slash commands pattern:** The k8s_project codifies the 8 playbooks as `.claude/commands/` files:
- `/project:tf-review` — Terraform change review
- `/project:app-onboard` — ArgoCD application manifest generation
- `/project:adr` — ADR writing

This pattern (AI Playbook → slash command → CLAUDE.md activation) is the repeatable template for any DevOps platform.

**Architecture patterns documented in k8s_project:**
- Blast-radius layers: network > eks > data > dns > k8s-access (each with independent TF state)
- IRSA per-component scoping (one role per LGTM component, one S3 bucket per role)
- App-of-apps GitOps with explicit `destination.name` (prevents cross-cluster mis-targeting)
- Karpenter node pool split: system/stateful (On-Demand) vs elastic (Spot)
- Tenant identity via `X-Scope-OrgID` at the OTel gateway layer (not app-layer)
- arc42 architecture template for platform documentation
- Ponytail in IaC context: found 132 removable lines in production Terraform code

---

## 6. ai-software-engineering Repo Patterns

Source: `/Users/andre/Work/ai-software-engineering/`

A "way of work" framework — personal AI operating model that sits above individual project repos.

**Structure:**
```
ai-software-engineering/
├── mcps/          # Recommended and tested MCPs with setup guides
├── prompts/       # Versioned reusable prompt templates
├── skills/        # Custom skills
└── AGENTS.md      # Agent configuration
```

**Core pattern:** Mount this as a parent directory above project repos. The skills and guidelines apply workspace-wide, while individual repos have their own CLAUDE.md for project-specific rules. The two layers complement rather than conflict.

**Prompt versioning principle:** Treat prompts like code — version them, test them, iterate. A prompt that works for Terraform review today is a reusable asset for the next platform project.

---

## 7. DevOps as a Service with AI — Service Design

### 6.1 Value Proposition

Traditional DaaS sells human-hours. AI-augmented DaaS sells outcomes: architecture decisions documented, dependency CVEs surfaced, runbooks generated, incidents resolved — delivered in minutes, not days.

### 6.2 Service Tiers

**Tier 1 — Platform Assessment (one-time)**

Deliverables from a single Claude Code session:
- Dependency audit report (CVEs, EOL versions, risk matrix)
- Architectural analysis (component inventory, critical findings)
- Component deep-dives (business rules, security gaps, test coverage)
- C4 diagrams (system context through code level)
- Mermaid stack diagrams (container topology, auth flow, ER)
- ADR backlog (must-document + consider tiers)
- Development guidelines document
- Project overview synthesis

Tools: `project-analizer` + `diagrams-generator` + `adrs-management` + `development-guidelines`  
Agent count: 20–30 parallel agents  
Elapsed time: 2–3 hours (including context switches)

**Tier 2 — Ongoing Platform Engineering (subscription)**

Monthly recurring:
- `/ponytail-audit` run on Terraform modules → pull request with removals
- Dependency audit re-run → delta report vs previous month
- New ADR generation for each infrastructure decision
- AI Playbook maintenance (add/update prompt templates as platform evolves)

Weekly:
- Grafana MCP-assisted incident summaries (LogQL + PromQL queries via AI)
- PR review via `code-review` or `pr-review-toolkit` plugin

**Tier 3 — AIOps Integration (enterprise)**

Live incident management:
- Grafana MCP: `create_incident` → `add_activity_to_incident` → `get_sift_analysis` → post-mortem draft
- Loki query patterns for error triage embedded in AI context
- Alert rule authoring via `alerting_manage_rules`
- On-call awareness during deployments via `get_current_oncall_users`

### 6.3 Tool Stack by Function

| Function | Tool | Trigger |
|---------|------|---------|
| Codebase audit | `project-analizer` | Onboarding, quarterly review |
| Architecture docs | `adrs-management` + `diagrams-generator` | New platform, design change |
| Code quality | `ponytail` | Every PR, monthly audit |
| IaC review | AI Playbook #1 + Ponytail | Before every Atlantis run |
| Incident management | Grafana MCP + `systematic-debugging` | On-call, SLO breach |
| Documentation | `development-guidelines` + Notion MCP | Platform onboarding |
| PR reviews | `pr-review-toolkit` | Continuous |
| Security | `security-guidance` + dependency audit | Release gates |
| Cost | AI Playbook #8 + Grafana MCP | Monthly FinOps review |

### 6.4 Agent Parallelism Model

The key operational insight from this session: **parallel agents are the multiplier**.

- Sequential: 10 ADR generators × 8 min each = 80 minutes
- Parallel: 10 ADR generators simultaneously = 90 seconds

Pattern:
1. One orchestrator agent reads the codebase and produces a work plan
2. N specialized agents execute in parallel, each scoped to one file/component/module
3. One linker/synthesizer agent aggregates outputs

This matches the k8s_project model: Terraform blast-radius layers enforce independent state → each layer is a parallel agent target.

### 6.5 CLAUDE.md as Service Configuration

Every client engagement gets a CLAUDE.md with:
- Active plugins (`ponytail`, `graphify`, etc.)
- Project-specific guardrails (placeholder conventions, forbidden patterns)
- AI Playbook slash commands for recurring tasks
- Blast-radius documentation (what can and cannot be changed autonomously)
- MCP server config for the client's observability stack

Template from k8s_project CLAUDE.md:
```markdown
# Plugin activation
/ponytail full
/graphify

# Blast-radius layers (highest to lowest)
# 1. network — VPC, subnets, NLB
# 2. eks — EKS cluster, node groups
# 3. data — S3 buckets, Aurora, Secrets Manager
# 4. dns — Route53, ACM
# 5. k8s-access — EKS access entries (lowest risk)

# Placeholder convention
# account_id = "000000000000" and REPLACE are intentional
```

---

## 8. Key Learnings

### From FamilyHub Session

1. **Self-hosted Supabase as a DevOps teaching platform:** 10 containers, complex init sequence, Kong DB-less config — all surfaced automatically by `project-analizer`. No manual archaeology needed.

2. **AI finds what reviews miss:** The `kid_visible` RLS gap (children can read adult tasks) was found independently by two separate component deep-dive agents — neither knew about the other's finding. This is architectural trust-but-verify.

3. **NEEDS INPUT markers are useful artifacts:** Tier 2 ADRs (placed in `needs-input/`) are not failures — they're traceable gaps. The deployment target tension in `next-standalone-output-mode` ADR (Vercel vs self-hosted) is a real unresolved question that needed surfacing, not resolving.

4. **Parallel agents at rate limits:** Three attempts were needed before all agents succeeded (two hit the session rate limit before producing output). Strategy: re-launch identically after reset. Do not reduce batch size — the parallelism is the value.

5. **Docs as FDD substitute:** No formal Feature Design Document existed. `docs/stack.md` (a 500-line runbook-style service map) produced correct C4 and Mermaid diagrams. The agents extract structure from whatever documentation exists.

### From k8s_project Session

1. **Blast-radius layers enable autonomous agent safety:** When the codebase documents which modules are high vs. low risk, agents can operate within lower-risk layers without asking for confirmation. The human-in-the-loop only engages at network/EKS tier changes.

2. **Ponytail on Terraform is immediately valuable:** 132 removable lines found in ~10 minutes. No tests broken, no behavior changed. The YAGNI discipline matters more in IaC than in application code because Terraform state drift is expensive to debug.

3. **IRSA per-component scoping is the right primitive for AI-assisted access reviews:** Each LGTM component (Mimir, Loki, Tempo) has its own IRSA role scoped to its own S3 bucket. An AI reviewing a new component's IRSA policy has a clear, checkable invariant: does it access only its bucket?

4. **arc42 template + AI = accelerated architecture documentation:** The k8s_project ARCHITECTURE.md follows arc42 (8 sections: context, constraints, solution strategy, building blocks, runtime view, deployment view, crosscutting concepts, ADRs). An AI agent with this template can produce a complete architecture document from a Terraform repo and Helm values in one session.

5. **Tenant identity at the gateway layer:** Using `X-Scope-OrgID` at the OTel gateway (not in each application) means tenancy is a platform concern, not an SDK concern. This is the right split for a DevOps-as-a-Service offering — the client's applications don't know about tenancy, the platform enforces it.

---

## 9. Quick Reference

### Plugin Installation

```bash
# Install marketplaces
/plugin add-marketplace devfullcycle https://github.com/devfullcycle/claude-mkt-place

# Install individual plugins
/plugin install devfullcycle/project-analizer
/plugin install devfullcycle/adrs-management
/plugin install devfullcycle/diagrams-generator
/plugin install devfullcycle/development-guidelines
/plugin install ponytail
```

### Standard Session Startup (DevOps engagement)

```
/ponytail full           # activate YAGNI mode
/graphify                # explore codebase structure
/generate-architectural-report --ignore-folders=node_modules,.git,.terraform,vendor
/guidelines-generate
```

### ADR Generation Pipeline

```
/adr-map                 # phase 1: module mapping
/adr-identify INFRA      # phase 2: per-module (run in parallel)
/adr-identify AUTH
/adr-identify DB
# ... then for each must-document file:
/adr-generate docs/adrs/potential-adrs/must-document/INFRA/foo.md
# ... run all generators in parallel, then:
/adr-link                # phase 4: wire relationships
```

### Model Selection

| Task | Model |
|------|-------|
| ADR writing, architecture synthesis | `claude-opus-4-8` |
| Code analysis, YAML/HCL/JSON generation | `claude-sonnet-4-6` |
| Structured narrow output (access entries, simple diffs) | `claude-haiku-4-5` |
| Parallel sub-agents (dependency audit, component analysis) | `claude-sonnet-4-6` |
