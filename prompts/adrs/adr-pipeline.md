# ADR Generation Pipeline

Four-phase workflow using the `adrs-management` plugin (devfullcycle marketplace) to produce formal MADR-format ADRs from a codebase.

## Prerequisites

```bash
/plugin install devfullcycle/adrs-management
```

## Phase 1 — Map

```bash
/adr-map
```

Analyzes the codebase and produces `docs/adrs/mapping.md` — a table of logical modules with estimated ADR density (Large/Medium/Small).

**Output:** `docs/adrs/mapping.md`

## Phase 2 — Identify

Run per module. Can run multiple modules in parallel in separate Claude Code sessions.

```bash
/adr-identify INFRA
/adr-identify AUTH
/adr-identify DB
/adr-identify API
/adr-identify DEVOPS
/adr-identify DOMAIN
```

For each module, produces files in `docs/adrs/potential-adrs/must-document/` and `docs/adrs/potential-adrs/consider/`.

**Output:** `docs/adrs/potential-adrs-index.md` + individual potential ADR files per module

**Two tiers:**
- `must-document/` — decisions that are already made and must be captured (high documentation value, low risk of change)
- `consider/` — decisions where the rationale needs stakeholder input before documenting

## Phase 3 — Generate

Run one agent per potential ADR file. All can run in parallel — 10 agents simultaneously takes ~90 seconds.

```bash
/adr-generate docs/adrs/potential-adrs/must-document/INFRA/supabase-self-hosted.md
/adr-generate docs/adrs/potential-adrs/must-document/DB/rls-as-multi-tenancy.md
# ... one per file, all in parallel
```

Each agent produces a formal MADR-format ADR in `docs/adrs/generated/MODULE/`.

**ADR tiers:**
- Tier 1 (complete): placed directly in `generated/MODULE/` — full technical evidence available
- Tier 2 (needs-input): placed in `generated/MODULE/needs-input/` — business or regulatory context missing

**[NEEDS INPUT] markers:** Each ADR is allowed up to 4 `[NEEDS INPUT]` markers for specific gaps. More than 4 means the decision is not ready to document.

## Phase 4 — Link

```bash
/adr-link
```

Reads all ADRs and adds bidirectional Markdown links between related decisions. Relationships: `supersedes`, `depends-on`, `related-to`, `used-by`. Idempotent — safe to re-run.

## Parallel execution tip

The rate limit risk is highest when launching many agents at once. If you hit a session limit:
- Do not reduce batch size
- Wait for the rate limit to reset
- Re-launch the same batch — agents that failed produced no output, so re-running is safe

## Output structure

```
docs/adrs/
├── mapping.md                        # Phase 1 output
├── potential-adrs-index.md           # Phase 2 index
├── potential-adrs/
│   ├── must-document/MODULE/*.md     # Phase 2 detailed files
│   ├── consider/MODULE/*.md
│   └── done/MODULE/*.md              # Archived after Phase 3
└── generated/
    ├── MODULE/ADR-NNN-*.md           # Tier 1 complete ADRs
    └── MODULE/needs-input/ADR-NNN-*.md  # Tier 2 incomplete ADRs
```
