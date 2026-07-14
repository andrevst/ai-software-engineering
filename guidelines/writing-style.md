# Writing Style Guide

Rules for all prose written by agents in documentation, ADRs, runbooks, and commit messages.

Adapted from k8s_project `writting-style.md` conventions, tested across architecture docs and AI Playbook prompts.

## Core rules

- **Active voice.** "The system stores credentials in Secrets Manager" not "Credentials are stored in Secrets Manager by the system."
- **No em dashes.** Use hyphens, colons, commas, or parentheses instead. Em dashes sneak in from autocorrect and are inconsistent across editors.
- **No buzzwords.** Not "robust", "seamless", "transformative", "game-changer", "best-in-class", "cutting-edge". Name the actual property instead: "retries on transient errors", "single sign-on", "42% faster p99 latency".
- **US English spelling.** "organize" not "organise", "behavior" not "behaviour".
- **Specific over vague.** "Latency increased from 45ms to 380ms after the deploy" beats "performance degraded". Numbers always beat adjectives.
- **No trailing summaries in code responses.** The diff is the proof. Prose that re-explains what the code does is noise.

## Document structure

- Lead with the finding or decision, not the background. Background is supporting evidence, not the headline.
- One idea per paragraph. If a paragraph has two ideas, split it.
- Tables for comparison. Prose for rationale. Never mix: don't explain a table in prose and don't embed rationale inside table cells.
- Code blocks for all file paths, commands, config values, and environment variable names — even inline.

## ADR-specific rules

- **Context paragraph:** one paragraph. What problem exists and why a decision is needed now. Reference specific files, incidents, or requirements.
- **Comparison table:** three to five criteria rows. Specific, measurable, or operationally meaningful criteria only. Not "pros" and "cons".
- **Recommendation:** one to two paragraphs. Name the chosen option, the primary reason, and the condition under which the alternative becomes correct. Do not re-list trade-offs already in the table.
- **Consequences:** what changes in this repo (files, modules), and the ongoing operational commitment.
- **Sources:** at least two external links. Real, accessible URLs only.
- Do not assign ADR numbers in the document — the reviewer assigns them at merge time.

## Commit messages

- Imperative mood: "add", "fix", "remove", "update" — not "added", "fixes", "removing".
- First line under 72 characters.
- Body: why the change was made, not what was changed (the diff shows what).
- Format: `<type>(<scope>): <subject>` — type is one of: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `perf`.

## What not to write

- "As you can see in the code above..."
- "This is a good approach because..."
- "Feel free to ask if you have questions."
- "I hope this helps!"
- Any sentence that starts with "Note that..." — just say the thing.
