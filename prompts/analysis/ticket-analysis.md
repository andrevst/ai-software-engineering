# Ticket Analysis Prompt

Analyze an engineering ticket before starting work. Ensures you understand the problem, have found all relevant context, and have validated the issue before writing code.

## How to use

Copy this prompt and fill in `[TICKET]` with the ticket ID, title, or content.

---

## Prompt

```
Analyze ticket: [TICKET]

Work through these steps in order. Do not skip steps to save time.

1. Understand the problem
   - State the problem in one sentence in your own words.
   - Identify: is this a bug, a feature request, a refactor, or a performance issue?
   - What is the expected behavior? What is the actual behavior?

2. Find relevant code
   - Search the codebase for the components, functions, or files most likely involved.
   - Read the full implementation of each relevant function — do not rely on names alone.
   - Trace the actual data flow end to end for the reported scenario.

3. Validate the problem
   - Does the code, as written, actually produce the reported behavior?
   - Is there a test that covers this path? If yes, does it pass or fail?
   - Are there any other callers of the affected code that would also be affected by a fix?

4. Check related context
   - Are there open PRs touching the same files?
   - Is there an ADR or design doc that explains why this code is written this way?
   - Has this path been touched recently? (git log --follow on the file)

5. Propose the fix scope
   - Where is the root cause? (Not the symptom — the place where all callers route through.)
   - What is the smallest correct change?
   - What could break if this change is made? Name specific call sites.

Output:
- One-paragraph problem summary
- Root cause location (file:line)
- Proposed fix scope
- List of files to change
- Any open questions that need clarification before starting
```
