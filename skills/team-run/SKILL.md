---
name: team-run
description: Run a folder of prompt files through the agent team, one agent per prompt in parallel, each result verified by the reviewer before it counts, and the whole batch closed with a report and draft tickets. Use when a project folder holds several numbered prompts or work items to execute or analyze, when a platform or codebase needs a multi-domain review, or when asked to run a prompt folder, fan out a batch of work items, or review something across several domains at once.
---

# Team Run

Take a folder of prompts, run one agent per prompt in parallel, verify every
result, and close the batch with one report.

The team is in [../../agents/README.md](../../agents/README.md). This skill is
how the team runs against many work items instead of one.

## The input contract

A folder of markdown files, each one a prompt. The convention is the one that
already exists in project prompt folders, not YAML frontmatter:

```markdown
# 05: Prove a GKE pod can reach Aurora in AWS

**Status:** `ready`
**Agent:** `cloud-solutions-architect`
**Linear:** COY-12162
**Created:** 2026-11-06

## Log

- **2026-11-06** Written. Split out of prompt 02.
```

| Field | Read for | Missing |
|---|---|---|
| `**Status:**` | whether to run this prompt at all | the file is skipped and listed as unrunnable. Never guess a status |
| `**Agent:**` | which role runs it | report the file as undeclared and ask. Never infer the role from the prompt text |
| `**Linear:**` | the ticket the close-out references | the item is carried as UNTRACKED |
| `## Log` | where this run appends what actually happened | create the section |

Status values and what the run does with them:

| Status | Action |
|---|---|
| `ready` | run it |
| `ongoing` | read the log first, then run from where it stopped |
| `done` | skip |
| `deprecated` | skip, and do not report it as skipped work |

**The folder is the state machine.** Status plus Log is the run ledger, so
resume is just re-running the folder: everything `done` drops out. Do not build
a separate progress file.

## The five stages

### Stage 0: the ref gate

Before any agent reads any file, record for every repository the batch will
touch:

```bash
git rev-parse --abbrev-ref HEAD
git rev-parse --short HEAD
git rev-list --count HEAD..origin/main
git status --porcelain | wc -l
```

Put the result in the run index, and put it in every agent's brief. An agent
that reads a stale working tree reports yesterday's platform as today's, and no
amount of content review catches it.

This gate exists because it has already failed once: a review read the tip of a
branch 270 commits behind `origin/main` with 51 dirty files and presented it as
current state. It was the most consequential error in that run and the cheapest
to prevent.

If a repo is behind or dirty, do not silently fetch or stash. State it, and ask
whether to run against the branch as-is or against `origin/main`.

### Stage 1: fan out, one agent per prompt

Dispatch the `ready` prompts in parallel, one agent each, role from `**Agent:**`.

Every brief carries, in this order:

1. The role's own definition file path, read first, followed exactly.
2. The engagement's fact sources in authority order, from the client `CLAUDE.md`.
3. The stage 0 ref record.
4. The prompt file's own content and its `## Log`.
5. The reviewer memory tables, if they exist (see Hard rules).
6. The run's constraints: what access this run has, and what it must not touch.
7. The output path for this item, and the instruction that the agent's final
   text is data for the orchestrator rather than a message to a person.

**Batch cap: 6 concurrent agents.** A folder with more prompts runs in batches.
State which prompts the batch covered and which it deferred, every time. A run
that quietly truncates a 21-prompt folder to the first 6 reads as full coverage
and is worse than refusing.

### Stage 2: verify each item as it lands

The `sre` agent verifies each result **as that result arrives**, not after the
whole batch. No barrier here.

This is the stage most often got wrong, including on the first run of this
pattern, where the reviewer waited for all four producers and the wall-clock
cost was the slowest producer plus the whole review, in sequence. Item A should
be in verification while item B is still being produced.

The reviewer runs on fresh context, reads the artifact before any producing
rationale, and re-runs the evidence command behind every Critical and High
claim. Its verdict shape is in its own definition. Two failure classes to hunt
by name, because both have already occurred:

- A field classified by its name rather than by its value. A key called
  `...SecretId` holding a literal secret, and `${env:...}` references read as
  literals. Both directions happen.
- An environment inflated. A nonproduction database described as live.

### Stage 3: close the batch

One barrier, then the `technical-manager`. This is the only justified barrier in
the run, because closing needs all items at once: reconciling duplicate findings
across prompts, reconciling the reviewer tables each producer drafted
independently, and deciding scope across the whole set.

It produces the report, classifies each item, drafts ticket content, and decides
what the engagement takes on now against what it defers with a promoting
condition. It files nothing.

### Stage 4: write back to the folder

For each prompt that ran, append one dated entry to its `## Log` saying where
the work actually went and where it stopped, then set `**Status:**`.

Write back **only after the verdict**, never between stages 1 and 2. A status of
`done` on an unverified result is the one write in this flow that corrupts the
next run.

## The output contract

```text
<run-folder>/
├── README.md                     index, ref record, authority order, known limits
├── 01-<slug>-<role>.md           one per prompt that ran
├── 02-<slug>-<role>.md
├── NN-verdicts.md                the reviewer's verification pass
└── NN+1-report-and-tickets.md    the close-out
```

The index states the authority order explicitly, because readers arrive at file
01 first and it is the least reliable file in the folder:

> **The verdicts file overrides the producer files. The report overrides the
> verdicts.** Producer files are first drafts and carry a first draft's errors.
> Never cite a producer finding without checking what the verdict pass did to it.

## Hard rules

| Rule | Why |
|---|---|
| Record the ref before reading. Stage 0 is not optional | A stale tree reported as current is undetectable downstream |
| Verify per item, never at a barrier | The wall-clock cost of a barrier is the slowest producer plus the whole review |
| Coverage is stated as measured | A sample presented as coverage is the defect this whole flow exists to catch. "Read 0.5% of source files" is a usable number; "reviewed the services" is not |
| Load the reviewer memory tables first | Without an already-fixed and a known-and-accepted table, every run re-reports settled findings, and a report that is mostly noise gets skipped |
| Never print a secret value | Confirm by file, line, field name, length, and at most a three-character prefix |
| Say what the batch deferred | No silent truncation, ever |
| Status write-back only after the verdict | `done` on an unverified result poisons the next run |
| State what the run could not reach | A run with no cloud access leaves real questions open. List them and name what would close them |

## Invoking it

```text
/team-run <prompt-folder> [--out <run-folder>] [--only 01,04,07] [--access read-only|none]
```

- `--access none` is the default for an analysis run: git and filesystem only,
  no cloud, no cluster, no package manager that touches the network. It is the
  fastest, cheapest and least risky mode, and it is honest about its ceiling.
- `--access read-only` closes the questions `none` cannot. Confirm the account
  and the context with the operator before the first agent starts.
- `--only` runs a named subset regardless of status, for re-running one item.

## When this is the wrong tool

| Situation | Use instead |
|---|---|
| One prompt, one item | Invoke the role directly. This skill's overhead buys nothing |
| The prompts depend on each other in sequence | Not a fan-out. Run them in order, and let each one read the previous output |
| The folder holds reference docs rather than work items | There is nothing to verify and nothing to close |
| More than about 24 prompts, or a run that keeps dying midway | The batching here is manual. A deterministic orchestrator with its own journal and token budget is the upgrade, and the trigger for building it is a run that actually died, not a folder that looks big |

## Writing

Every artifact follows [../../guidelines/writing-style.md](../../guidelines/writing-style.md).
Findings ordered worst first. Numbers beat adjectives. Every claim carries a
`file:line`, a command and its output, or a first-party URL.
