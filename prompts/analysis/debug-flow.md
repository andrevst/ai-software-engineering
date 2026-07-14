# Debug Flow Prompt

Structured debugging with a documented investigation trail. Forces reproducibility and prevents circular investigation loops.

## The pattern

Every debugging step documents: what action was taken, in what system, and what result was observed. Each result leads to either a conclusion or a new hypothesis.

```
Executed [ACTION] in [SYSTEM/COMPONENT] and got [RESULT].
From this result I conclude [INFERENCE], which leads me to [NEXT ACTION or FINAL CONCLUSION].
```

## How to use

Start a debug session by filling in the initial observation, then follow the trail.

---

## Prompt

```
Debug this issue: [DESCRIPTION OF OBSERVED PROBLEM]

Environment:
- System: [application name, environment: production/staging/local]
- When it happens: [always / intermittent / specific conditions]
- First observed: [timestamp or event]
- Affected users or scope: [all users / specific user / specific request path]

Debugging trail format — use this for every step:
  Executed [ACTION] in [SYSTEM] and got [RESULT].
  From this result I conclude [INFERENCE].
  This leads me to [NEXT ACTION or FINAL CONCLUSION].

Start with:
1. Reproduce the issue or find evidence it occurred (logs, traces, metrics).
2. Isolate the failure boundary — what is the last point where the system behaved correctly?
3. Form one hypothesis. Test it. Document the result.
4. Repeat until you reach the root cause.

Rules:
- Do not jump to solutions before confirming the root cause.
- Every hypothesis must be tested, not assumed.
- If a tool (Grafana, Loki, traces) shows no evidence, document that explicitly — absence of data is also a data point.
- Stop and ask if you reach a dead end rather than guessing.

Output at end of investigation:
- Root cause (one sentence)
- Evidence trail (the documented steps)
- Fix (code change or config change)
- How to verify the fix worked
- Whether other components could have the same root cause
```
