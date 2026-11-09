# AGENTS.md

Configuration and instructions for AI agents working in this repository or in projects that reference it.

## Default behavior

- Ponytail full mode is active: YAGNI enforced, deletion over addition, stdlib first.
- Graphify is available: use `/graphify` before exploring an unfamiliar codebase.
- Prompts in `prompts/` are templates — fill in the bracketed placeholders before running.

## Agent model selection

| Task type | Model |
|-----------|-------|
| Long-form reasoning, ADR writing, architecture synthesis | `claude-opus-4-8` |
| Code analysis, YAML/HCL/JSON generation, cross-file analysis | `claude-sonnet-4-6` |
| Narrow structured output (access entries, diffs, short reports) | `claude-haiku-4-5-20251001` |
| Parallel sub-agents (dependency audit, component analysis, ADR generation) | `claude-sonnet-4-6` |

## Organizing agents around a product

One role decides, every other role reviews or builds. Splitting agents by
decision boundary rather than by file type is what stops a roster becoming a
committee. The proposed team, the product architect's remit, and the roles
deliberately not created are in [`docs/product-team.md`](docs/product-team.md).

Every reviewer agent carries two tables: what is already fixed, and what is
known and accepted. Without them a reviewer re-reports resolved findings every
run, and a report that is mostly noise gets skipped.

## Parallel agent pattern

Fire independent agents simultaneously rather than sequentially. Each agent gets a self-contained prompt with no shared state. The orchestrator reads all outputs afterward.

Example: 10 ADR generator agents in parallel = ~90 seconds. Sequential = ~15 minutes.

## Safety

- Never commit real AWS account IDs, ARNs, or API keys. Use `000000000000` and `REPLACE` as placeholders.
- Confirm before destructive operations: `git reset --hard`, `rm -rf`, force-push, database drops.
- Document blast-radius layers in each project's CLAUDE.md before running autonomous agents.
- Dependencies and vulnerabilities follow [`guidelines/dependency-policy.md`](guidelines/dependency-policy.md): zero tolerance in the runtime tree, the ladder before any install, a register row in the same commit.
