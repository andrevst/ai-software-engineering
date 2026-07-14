# MADR Template — Architecture Decision Record

Minimal Architecture Decision Record format used by the `adrs-management:adr-generator` agent. Reference this when writing ADRs manually.

---

```markdown
# ADR-NNN — [Short noun-phrase title that completes "We decided to..."]

**Date:** YYYY-MM-DD  
**Status:** Accepted | Proposed | Deprecated | Superseded by [ADR-NNN](../path/ADR-NNN.md)  
**Related ADRs:** [ADR-NNN](../path/ADR-NNN.md) — brief relationship description

---

## Context

One paragraph. What problem exists and why a decision is needed now. Reference specific
files, prior incidents, or requirements. Do not hedge — state the problem directly.

## Decision Drivers

- [Driver 1 — specific constraint, requirement, or observation]
- [Driver 2]
- [Driver 3]

## Options Considered

### Option A — [Name] (chosen)

Brief description.

**Pros:** [specific advantage]  
**Cons:** [specific trade-off]

### Option B — [Name]

Brief description.

**Pros:** [specific advantage]  
**Cons:** [specific trade-off]

### Option C — [Name] (if applicable)

Brief description.

**Pros:** [specific advantage]  
**Cons:** [specific trade-off]

## Decision Outcome

**Chosen option: Option A**, because [primary reason in one sentence].

[NEEDS INPUT]: [Specific question that requires stakeholder or business context — one sentence.]

## Consequences

**Good:**
- [Concrete benefit]
- [Concrete benefit]

**Bad:**
- [Concrete trade-off]
- [Concrete trade-off]

**Action items:**
- [ ] [Specific task that must happen as a result of this decision]

## References

- [Source 1 — real, accessible URL](https://example.com)
- [Source 2 — real, accessible URL](https://example.com)
```

---

## Rules

- **One decision per ADR.** If the title needs "and", split it into two ADRs.
- **[NEEDS INPUT] max 4.** More means the decision is not ready to document.
- **No code blocks in the ADR body.** Describe architecture, not implementation.
- **No SQL, YAML, or JSON snippets.** Reference file paths instead.
- **Date is the decision date**, not the writing date.
- **Status "Proposed"** for ADRs that need team review before accepting.
- **Status "Superseded by"** when a newer ADR replaces this one — link to the replacement.
- **Related ADRs** must be bidirectional — if A links to B, B must link to A.
- ADR number is assigned by the reviewer at merge time. Use `NNN` as placeholder.
