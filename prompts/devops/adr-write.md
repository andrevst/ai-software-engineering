Write a new Architecture Decision Record to append to docs/ARCHITECTURE.md.

Ask the user for:
- The decision topic (one clear question this ADR answers)
- The options considered (at least two, including the one recommended)
- The recommendation and the primary reason for it
- Any context about constraints, prior incidents, or requirements that make this decision necessary now

Then write the ADR following this exact structure (match the existing ADRs in docs/ARCHITECTURE.md):

### ADR-N <Title>

Context: one paragraph explaining what problem exists and why a decision is needed now. Reference specific files, prior incidents, or requirements where relevant.

| Criterion | Option A | Option B | Option C (if applicable) |
|-----------|----------|----------|--------------------------|
[Three to five criteria rows. Be specific: operational weight, AWS fit, cost, prior experience, migration risk.]

Recommendation: one to two paragraphs. Name the chosen option, the primary reason, and the condition under which the alternative becomes the right choice. Do not hedge or list all trade-offs again: the table already did that.

Consequences: what changes in this repo (which files, which modules), and what is the ongoing operational commitment.

Sources: at least two external references as markdown links. Links must be real, accessible URLs.

---

Format rules (writting-style.md):
- Active voice throughout.
- No em dashes. Use hyphens, colons, commas, or parentheses.
- No buzzwords: not "robust," "seamless," "transformative," "game-changer."
- US English spelling.
- Do not assign the ADR number; write ADR-N and note that the reviewer assigns the final number.
- Do not reference local documentation files as if they are externally accessible. Internal file paths (like ARCHITECTURE.md) are fine as relative references.
