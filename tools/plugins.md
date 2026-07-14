# Claude Code Plugin Marketplaces

All tested plugins across the three installed marketplaces. Install via `/plugin install <name>` or `/plugin install <name>@<marketplace>`.

## Marketplaces

```bash
# Add marketplaces
/plugin add-marketplace devfullcycle https://github.com/devfullcycle/claude-mkt-place
# ponytail and claude-plugins-official are available by default
```

---

## devfullcycle (`devfullcycle/claude-mkt-place`)

Full analysis-to-documentation pipeline. Four plugins, seven sub-agents.

### `project-analizer` (sic)

```bash
/plugin install devfullcycle/project-analizer
```

| Agent | Command | Output |
|-------|---------|--------|
| `dependency-auditor` | `/run-dependency-audit` | CVE scan, EOL detection, version drift report |
| `architectural-analyzer` | `/generate-architectural-report` | Component map, 39+ component inventory, critical findings |
| `component-deep-analyzer` | (auto-launched by `generate-architectural-report`) | Deep-dive: business rules, test coverage, security per component |

Full pipeline command:
```bash
/generate-architectural-report --ignore-folders=node_modules,.git,.terraform,vendor
```

Runs 6 phases: MANIFEST init → dependency + architecture in parallel → component deep-dives in parallel → PROJECT-OVERVIEW → README index.

### `adrs-management`

```bash
/plugin install devfullcycle/adrs-management
```

| Command | Phase | What it does |
|---------|-------|-------------|
| `/adr-map` | 1 | Maps codebase into modules with ADR density |
| `/adr-identify <MODULE>` | 2 | Finds must-document and consider ADRs per module |
| `/adr-generate <file>` | 3 | Generates one formal MADR from a potential ADR file |
| `/adr-link` | 4 | Wires bidirectional links across all ADRs |

See `prompts/adrs/adr-pipeline.md` for the full workflow guide.

### `diagrams-generator`

```bash
/plugin install devfullcycle/diagrams-generator
```

| Command | Output |
|---------|--------|
| `/generate-c4 <path-to-fdd.md>` | 4 PlantUML C4 diagrams (C1–C4) + analysis markdown |
| `/generate-mermaid <path-to-fdd.md>` | Up to 8 Mermaid diagrams embedded in one markdown file |

No formal FDD required — a comprehensive `stack.md` or runbook works as input.

### `development-guidelines`

```bash
/plugin install devfullcycle/development-guidelines
```

```bash
/guidelines-generate
```

Generates a project-specific development guidelines document. TypeScript output: 1,726 lines, 82 code blocks, 26 sections. Includes DevOps-specific patterns: Zod env validation, AsyncLocalStorage correlation IDs, Result types, AbortSignal graceful shutdown.

---

## claude-plugins-official (`anthropics/claude-plugins-official`)

### `superpowers`

```bash
/plugin install superpowers@claude-plugins-official
```

Process skills that change how Claude Code approaches tasks. Invoke via `/skill superpowers:<name>`.

| Skill | When to use |
|-------|------------|
| `brainstorming` | Before any design or architecture decision |
| `systematic-debugging` | Incident RCA, flaky tests, infrastructure drift |
| `writing-plans` | Before multi-step infra changes — align before touching prod |
| `executing-plans` | Step-by-step plan execution with checkpoints |
| `subagent-driven-development` | Decompose complex tasks across parallel agents |
| `dispatching-parallel-agents` | Fire N independent agents simultaneously |
| `using-git-worktrees` | Parallel branch work without checkout conflicts |
| `verification-before-completion` | Checklist gate before marking any task done |
| `requesting-code-review` | Structured PR description generation |
| `receiving-code-review` | Process review feedback systematically |
| `test-driven-development` | TDD workflow enforcement |
| `finishing-a-development-branch` | Branch cleanup before PR |

### `security-guidance`

```bash
/plugin install security-guidance@claude-plugins-official
```

Three-layer automatic security review. See `tools/security-guidance.md` and `docs/owasp-llm-security.md` for full details.

### Other notable plugins

| Plugin | Purpose |
|--------|---------|
| `code-review` / `pr-review-toolkit` | Automated PR review with configurable depth |
| `session-report` | End-of-session summary and handoff document |
| `hookify` | Claude Code hook configuration assistant |
| `mcp-server-dev` | Scaffold new MCP servers |
| `mcp-tunnels` | Expose local MCP servers through tunnels |
| `feature-dev` | Feature development workflow |
| `project-artifact` | Project artifact management |
| `skill-creator` | Create new skills from patterns |
| `agent-sdk-dev` | Claude Agent SDK scaffolding |
| `ralph-loop` | Autonomous loop patterns |
| `claude-md-management` | CLAUDE.md file management |
| `code-modernization` | Upgrade code to modern language features |
| `code-simplifier` | Remove unnecessary complexity |
| `commit-commands` | Structured commit message generation |
| `session-report` | Per-session handoff reports |

---

## ponytail

```bash
/plugin install ponytail
```

Lazy senior developer mode. YAGNI enforcer. Deletion over addition, stdlib first.

| Level | Activate with | Behavior |
|-------|--------------|---------|
| `full` (default) | `/ponytail full` | Full ladder enforced — YAGNI → reuse → stdlib → native → installed dep → one line |
| `lite` | `/ponytail lite` | Suggestions only, no blocking |
| `ultra` | `/ponytail ultra` | Maximum deletion pressure |

Skills: `ponytail`, `ponytail-audit`, `ponytail-debt`, `ponytail-gain`, `ponytail-review`, `ponytail-help`

**Proven result:** Terraform audit on production repo found 132 removable lines — unused variables, duplicated locals, over-specified tag merges, unnecessary outputs. Zero functional changes. Zero tests broken.

**DevOps use cases:**
- Terraform module review before Atlantis PRs
- Helm values pruning (remove chart defaults that were explicitly set)
- GitHub Actions workflow deduplication
- IRSA policy over-scoping detection
- Docker Compose simplification
