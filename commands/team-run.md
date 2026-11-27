---
description: Run a folder of prompt files through the agent team, one agent per prompt in parallel, each result verified before it counts.
argument-hint: <prompt-folder> [--out <run-folder>] [--only 01,04] [--access read-only|none]
---

Invoke the `team-run` skill and follow it exactly.

Arguments: $ARGUMENTS

If no folder was given, list the candidate prompt folders you can see and ask
which one, rather than guessing. Before dispatching the first agent, confirm the
access mode with the operator and complete the skill's stage 0 ref gate.
