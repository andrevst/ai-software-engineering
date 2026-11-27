---
name: release-management
description: Prepare, run, log, and close a release on a client platform, and record the delivery metrics the engagement reports on. Use when a release needs a manifest before it ships, a preflight check of the artifacts it names, a running log during the rollout, or a close-out with carry-forwards and metrics. Covers the document and the checks, not the deploy.
---

# Release Management

One document per release. It is written before the release, updated during it,
and closed after it. The document is the record; the deploy belongs to the
operator.

Read the project's `CLAUDE.md` for the environment names, the promotion order,
the artifact registry, and the deploy mechanism. If the promotion order is not
stated anywhere, stop and ask. Guessing it is how a release reaches production
first.

## Scope

| Covered | Not covered |
|---|---|
| The manifest of what ships | Running the deploy |
| Preflight verification of artifacts and config | The production sign-off |
| The rollout log | Any credentialed action |
| Validation results and metrics | Accepting risk on a failing check |
| Carry-forwards into the next release | |

A complete release document is not a completed release. Never imply otherwise.

## Modes

Run them in order. Each mode has an exit condition.

### `prep`

Create the document from
[templates/release.md](./templates/release.md), named by the project's
convention.

1. Collect what ships: service, version, delivery mechanism, target
   environments.
2. Normalize it into the manifest table. One row per service per environment.
3. Compute the delta against the previous release document, per service. A
   service with no previous row is new; say so.
4. List what is explicitly **not** in this release. The omissions are what
   people ask about later.
5. List the configuration changes the release needs, as file, field, and new
   value.

**Exit:** every row has a version, a mechanism, and a target. No row says "latest".

### `preflight`

Verify the release can happen before it starts. Each check is run, and its
output recorded.

| Check | Why |
|---|---|
| Every artifact the manifest names exists in the registry, at that exact tag | A manifest naming a tag that was never pushed fails mid-rollout, after the first environment already moved |
| Every configuration change is committed and pushed | A rollout that reads git gets the old value until the change lands |
| Rendering succeeds for every affected configuration file, not only the edited ones | A reference defined in one file and missing from its siblings fails for every sibling |
| The key set did not shrink in any configuration file | A dropped key is invisible in an additive text diff and gets restored by hand weeks later |
| The deploy target matches the intended environment | Confirm the active context and credentials profile, and record what they were |
| Rollback is named per service | The previous version, resolved from git history rather than from memory |
| Monitoring is open for the rollout window | Name the dashboards or queries |

**Exit:** every check has a recorded result. A failing check blocks the release,
and the document says which check failed. Never proceed on a check that was not
run.

### `log`

Append during the rollout. One row per action, with a timestamp and a time zone.

- Record the action, the target, and the result as observed, not as expected.
- Record interventions, retries, and anything manual, with the reason.
- After each environment, record the reconciliation or health state before
  moving to the next.
- Never filter or grep the output of a deploy script into the log. Capture the
  full output to a file and reference it. Filtering hides the warnings that
  explain the next failure.

**Exit:** every environment in the promotion order has a row, including the ones
that were skipped, with the reason.

### `wrap`

Close the document.

1. Summarize what shipped and what did not.
2. Record the validation results per environment.
3. Record the delivery metrics in the metrics table, measured now rather than
   reconstructed later. A field that cannot be measured is left blank and marked
   blank, never estimated silently.
4. List the to-dos the release produced, each with a destination: a ticket, a
   runbook, or a follow-up release.
5. Move carry-forwards into the next release document, with the reason they did
   not ship.

**Exit:** no blank metric field without a stated reason, and every to-do has a
destination.

## Delivery metrics

Record these per release. They are the inputs a delivery report reads, and a
blank row means the period cannot be counted.

| Field | How to get it |
|---|---|
| Release revision | the commit or commits that reached production |
| First production deploy | timestamp, from the deploy system's own history |
| Last production deploy | timestamp, same source |
| Fan-out duration | last minus first: how long the promotion took to converge |
| Lead time, deploy stage | release commit timestamp to first production deploy |
| Lead time, source to production | source commit timestamp to first production deploy |
| Artifacts deployed | count of components whose running version changed |
| Rollback required | yes or no. A redeploy of the previous version, not a retry |
| Incident during the window | yes or no, with a link if yes |

Rollback and incident are the two fields most often left blank, and they are the
two the change-failure rate needs. A release document missing them removes that
release from every delivery metric the engagement reports.

## Hard rules

- Never proceed past a failing preflight check.
- Never record a result that was not observed.
- Never filter deploy output.
- Never deploy. Prepare, verify, log, close, and hand the deploy to the
  operator.
- Normalize the release commit subject to one form per project and keep it.
  A convention caught in the week it appears costs nothing; caught a quarter
  later it costs a migration.

## Writing

Follow [../../guidelines/writing-style.md](../../guidelines/writing-style.md).
Tables for the manifest and the log. Prose only for the rationale in the
close-out.
