# A product team of agents

A proposal for how to organize AI agents around a product, and the one rule
that keeps the arrangement from becoming a committee.

Validated on a working application: a Next.js base wired to Supabase, Stripe,
Sanity and Resend, documented with arc42 and eight ADRs. Seven of the roles
below exist and have done real work. The ones marked as proposed have not, and
say so.

## The organizing rule

**Exactly one role decides. Every other role reviews or builds.**

An agent roster without this rule produces two failure modes. Either every
agent has an opinion on everything, so nothing is settled and the human
arbitrates every call. Or agents are split by file type, which looks tidy and
owns nothing: two agents both touch a route handler and neither owns whether
the route should exist.

Splitting by decision boundary instead of by file type is what makes the team
work. The product architect holds the boundary. The reviewers hold veto over
specific classes of mistake. The builders hold nothing and that is correct.

## The team

| Role | Model | Decides, reviews or builds | Owns | Refuses |
|------|-------|----------------------------|------|---------|
| Product architect | Long-reasoning tier | Decides | The arc42 record and every ADR. The only role that may change a constraint | To record a decision without a named condition that reverses it |
| Security reviewer | Long-reasoning tier | Reviews | OWASP Top 10 and ASVS at the level the change touches | To pass a finding it cannot trace from entry point to sink |
| Dependency reviewer | Long-reasoning tier | Reviews | Supply chain: the ladder, the deep scan, the register row | A dependency that an earlier rung of the ladder would have covered |
| Documentation keeper | Long-reasoning tier | Reviews | Finding the sentences that became false after a change | To rewrite a section that is still true |
| Interface curator | Mid tier | Builds | The component catalogue. New UI composes catalogued primitives | Markup that restates a primitive's styles instead of using it |
| Verification engineer | Mid tier | Builds | Tests, browser checks, and the gates | To report success without the command output that proves it |
| Release checker | Mid tier | Reviews | The configuration CI cannot see | A deploy with a credential or a webhook unverified |
| Data migration writer | Mid tier | Builds | Schema changes as forward migrations, with access rules enabled on anything new | Proposed, not yet built |
| Copy reviewer | Mid tier | Reviews | User-facing strings against the writing guidelines | Proposed, not yet built |

Model tiers follow the table in [`AGENTS.md`](../AGENTS.md): long-reasoning for
judgement, mid tier for mechanical work with a clear spec.

## The product architect

The role worth describing in full, because it is the one most often left
implicit and then performed badly by whoever is typing.

**It decides.** Reviewers can block a decision on a specific class of mistake.
They cannot substitute a different decision. When a reviewer and the architect
disagree on direction rather than on a defect, the human decides, and the
outcome becomes an ADR.

**Its output is a decision record, not a recommendation.** Every ADR names the
options that lost, the criterion that decided, and the condition under which
the losing option becomes correct. That last part is what stops a decision
being re-argued from scratch in three months, and it is the part most often
skipped.

**It owns constraints, and constraints are not decisions.** The deploy target,
the language, the paid services: those were fixed before design started. The
architect records them and designs within them. Changing one is a new ADR with
the migration cost stated.

**It is also the role that says no to work.** The cheapest architecture
decision is the feature that does not get built. An architect that only ever
designs what it is handed is a drafting service.

### What a good decision record contains

| Part | Why it is there |
|------|-----------------|
| Context, one paragraph | What problem exists and why a decision is needed now |
| Decision drivers | The constraints that narrow the field, stated before the options |
| Options, including the ones that lost | A record with one option is a justification, not a decision |
| A comparison table | Three to five measurable criteria. Not "pros" and "cons" |
| The deciding criterion, named | Usually one criterion decides. Say which |
| The reversal condition | What has to change for the losing option to win |
| Consequences | Files and modules that change, and the ongoing commitment |

## Three lessons that cost real time

These are the ones worth copying, because each was learned by getting it wrong
first.

**An agent needs to know what is already fixed.** A reviewer without that list
re-reports resolved findings every run, and a report that is mostly noise gets
skipped, which is worse than having no reviewer. Every reviewer in the team
carries an "already fixed, do not re-report" table and a separate "known and
accepted" table.

**A catalogue that is not executable rots.** A component library documented in
a page nobody opens drifts from the code within weeks. Wiring the catalogue's
stories into the test run, so a component that stops rendering fails the build,
is what makes the interface curator's work hold.

**Reviewers must not also be builders.** The role that proposes a dependency
cannot be the role that approves it, for the same reason it does not work with
people. The dependency reviewer's default answer is no, and that only means
something if it did not write the install.

## Roles deliberately not created

| Not created | Why |
|-------------|-----|
| Product manager | No decision boundary that the architect does not already hold. It would produce opinions, not decisions |
| Tech lead | Overlaps the architect on decisions and the reviewers on defects. Two owners for one boundary |
| One reviewer per language or framework | Splits by file type, which is the failure mode this arrangement exists to avoid |
| A generalist code reviewer | Finds what the specific reviewers find, later and with less confidence. Specific beats broad when the invariants are written down |

## Getting from here to a team

The order matters. Each step is useful before the next exists.

1. **Write the constraints down.** Deploy target, language, paid services. One
   page. Without this the architect has nothing to design within.
2. **Add the product architect.** Record the decisions that already exist
   implicitly in the code. Most projects have five to ten.
3. **Add the security reviewer.** It is the role whose absence costs the most,
   and the one whose findings are most concrete.
4. **Add the dependency reviewer.** Supply chain is the one risk that grows
   without anyone touching the code.
5. **Add the verification engineer and make the gates real.** A gate nobody
   runs is documentation.
6. **Then the rest, when a specific mistake repeats.** A role invented before
   the mistake it prevents is a guess.

A worked example of this team, with the agent definitions and the eight ADRs
they produced, is at
[arqui-dev/sweai-base-apps](https://github.com/arqui-dev/sweai-base-apps).
