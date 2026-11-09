# AI tooling inventory

Copy this file into a project as `docs/ai-tooling.md` and fill it in. It exists
so a project can answer three questions without archaeology: what is available,
which layer owns it, and what has actually done work here.

Counts and connection status drift. Run `tools/ai-inventory.sh` for the live
picture before editing. The judgement about what each thing is *for* is written
by hand, because that part cannot be generated.

<!-- Snapshot line: date, and the totals from the script. -->
**Snapshot: YYYY-MM-DD.** N plugins, N MCP servers (N connected,
N unauthenticated), N user skills plus N shipped by plugins, N agents owned by
this repository.

## Five layers

Capability arrives from five places, and knowing which one owns a problem is
most of the debugging. Only the bottom two are yours.

| Layer | Owned by | Changes how often | Example |
|-------|----------|-------------------|---------|
| Harness | The vendor | On release | Skills, subagents, hooks, scheduled runs |
| Plugins | Third parties | On their release | Marketplace plugins |
| MCP servers | Service vendors | On their release | Issue tracker, hosting, payments, observability |
| Workspace | You, `ai-software-engineering` | When a convention changes | Language guidelines, shared prompts |
| This repository | You, `.claude/agents/` | Every feature | Project-specific reviewers |

Order the sections below that way. What you own goes first, because that is
what you evolve.

## 1. Agents we own

<!-- The only table that matters. Each row needs a trigger and an owned
     invariant, or the agent is decoration. -->

| Agent | Model | Fires on | Owns |
|-------|-------|----------|------|
| | | | |

Still to build: link the roadmap. The roadmap tracks what does not exist yet;
this table tracks what does.

## 2. Workspace conventions

<!-- What this project actually takes from ai-software-engineering, and where
     it deliberately overrides. Note the overrides: an unstated override is
     indistinguishable from a mistake. -->

| Asset | Used for | Overridden here |
|-------|----------|-----------------|
| `guidelines/typescript.md` | | |
| `guidelines/writing-style.md` | | |

## 3. MCP servers

<!-- Status straight from the script. An unauthenticated server that blocks
     work is a blocker, so write what it blocks and how to unblock it. -->

| Server | Status | What it unlocks here |
|--------|--------|----------------------|
| | | |

## 4. Plugins

| Plugin | Version | Ships | Used here for |
|--------|---------|-------|---------------|
| | | | |

## 5. Skills reached for in this project

<!-- The useful subset: skills that have done work. List the installed ones
     that have not separately, marked as unused. A skill nobody has run is not
     a capability, and claiming it as one is how an inventory starts lying. -->

| Skill | Source | Where it was used |
|-------|--------|-------------------|
| | | |

## Keeping this honest

Three rules, or the inventory becomes a list of things nobody runs.

1. A new agent gets a row in section 1 and a row in the project's agent
   instructions, and its roadmap line is deleted.
2. A skill or plugin that has never done work here belongs in section 5 marked
   as unused, not in a capability claim.
3. Run the inventory script before editing. A count written from memory is how
   a document starts lying.
