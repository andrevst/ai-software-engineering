# Release: <period or identifier>

**Status:** Planning <!-- Planning | Preflight | In progress | Shipped | Rolled back -->
**Owner:** <name>
**Promotion order:** <read from the project CLAUDE.md, e.g. staging -> canary -> production>
**Exclusions:** <components deliberately not in this release>

---

## 1. Manifest

One row per component per environment. No row says "latest".

| Component | Version | Delivery mechanism | Target environments |
|---|---|---|---|
| | | | |

### Delta against the previous release

| Component | Previous | This release |
|---|---|---|
| | | |

**Not in this release:** <components, and why>

### Configuration changes this release needs

| File | Field | New value |
|---|---|---|
| | | |

---

## 2. Preflight

Every row records what was run and what it returned. A failing row blocks.

| Check | Command or source | Result |
|---|---|---|
| Artifacts exist at the named tags | | |
| Configuration changes committed and pushed | | |
| Rendering succeeds for every affected file | | |
| Key set did not shrink | | |
| Deploy target and credentials confirmed | | |
| Rollback version named per component | | |
| Monitoring open for the window | | |

---

## 3. Rollout log

Append during the release. Timestamps carry a time zone.

| When | Environment | Action | Result as observed |
|---|---|---|---|
| | | | |

### Interventions

<!-- Anything manual, retried, or unexpected, with the reason and a link to the captured output. -->

---

## 4. Validation

| Environment | Check | Result |
|---|---|---|
| | | |

Observations during the window (latency, errors, restarts, saturation):

---

## 5. Delivery metrics

Measured now, not reconstructed. A blank field carries a stated reason.

| Field | Value | Reason if blank |
|---|---|---|
| Release revision | | |
| First production deploy | | |
| Last production deploy | | |
| Fan-out duration | | |
| Lead time, deploy stage | | |
| Lead time, source to production | | |
| Artifacts deployed | | |
| Rollback required | | |
| Incident during the window | | |

---

## 6. Close-out

**Shipped:**

**Did not ship:**

**To-dos produced, with destinations:**

| To-do | Destination |
|---|---|
| | |

**Carry-forwards into the next release, with the reason they did not ship:**

| Item | Reason |
|---|---|
| | |
