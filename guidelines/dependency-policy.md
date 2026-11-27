# Dependency and vulnerability policy

Rules for adding dependencies and for what counts as an acceptable
vulnerability. Written after a project reached zero runtime vulnerabilities and
found that nothing stopped the next commit from undoing it.

This matters more in a base repository than in a normal application. A
dependency added carelessly is inherited by every product started from the
base, and so is the habit.

## 1. Vulnerabilities

**Never accept one that can run in a request.**

| Scope | Gate | Tolerance |
|-------|------|-----------|
| Runtime tree | `npm audit --omit=dev --audit-level=info` | Zero. Any advisory, any severity, fails the build |
| Build and editor tooling | `npm audit`, reported | Allowed, with a written reachability argument |

No triage step and no accepted-risk list for the runtime tree. A vulnerability
with no available fix means the dependency is removed, replaced, or the feature
that needs it is dropped.

The split is not a loophole. It is the same reachability test a severity rating
already requires: a bundler plugin cannot be reached by an HTTP request. Gating
on what is reachable keeps the gate credible, and a credible gate is the only
kind that survives contact with a deadline. Gating the whole tree instead
sounds stricter and ends with the gate switched off within a week.

**Continuous beats point-in-time.** A merge-day audit only proves the tree was
clean that day. Configure Dependabot or Renovate for both the package manager
and the CI action versions.

## 2. The ladder

Climb this before installing anything. Stop at the first rung that holds.

1. Does the feature need to exist at all?
2. Is it already in the tree, directly or transitively?
3. Do the language's built-ins do it? Node's `node:crypto` covers HMAC and
   constant-time comparison.
4. Does the platform do it? A CSS custom property replaces a theming library.
   The Popover API replaces a menu component, including focus handling and
   dismiss. `<input type="email">` replaces a validation library.
5. Can it be a few lines here, with a test?

If an earlier rung would have worked, that is the finding, and the scan
afterward is irrelevant.

**Never hand-roll**, regardless of how few lines it looks like:
cryptography, TLS, payment handling, authentication token formats, HTML
sanitizers for untrusted documents, or anything with a published specification
and a maintained implementation. Being lazy about code is not the same as being
lazy about correctness.

## 3. Deep scan before the install is committed

```bash
PKG=<name>
npm view "$PKG" maintainers dist-tags time.created repository license
npm view "$PKG" dependencies peerDependencies --json
npm ls "$PKG" --all --omit=dev
grep -rl '"\(pre\|post\)install"' node_modules/"$PKG" 2>/dev/null
```

Reject, or escalate for a human decision, on any of:

| Signal | Why |
|--------|-----|
| An install script with no stated reason | The standard malware entry point. Installation executes code with the runner's privileges |
| First publish within weeks, or a recent maintainer change on a critical package | Both precede most registry attacks |
| A name one edit away from a popular package | Typosquatting |
| A git or URL dependency on a branch rather than a commit SHA | The target can change after review |
| A floating range: `latest`, `*`, or a bare major | Tooling writes these. One framework's installer added two `"latest"` entries that had to be pinned by hand |
| A transitive count out of proportion to the job | |
| An unsatisfiable peer range | One widely used package declared a peer whose range no published version satisfied, which crashed the package manager instead of reporting an unmet peer |

## 4. Measure honestly

`npm ls --omit=dev --all` follows optional peer edges and will report test
runners and platform binaries as production dependencies. They are not.
Measure what actually installs:

```bash
D=$(mktemp -d); cp package.json package-lock.json "$D"/
(cd "$D" && npm ci --omit=dev --ignore-scripts >/dev/null 2>&1 \
  && echo "top-level: $(ls node_modules | grep -cv '^\.')" \
  && echo "total:     $(find node_modules -name package.json | grep -vc '/node_modules/.*/node_modules/.*/node_modules/')")
```

A number written from the wrong command is worse than no number, because it
gets quoted.

## 5. Record it

Every production dependency gets a row in a register, in the same commit as
the install: what it is for, what it replaced or made unnecessary, its
transitive count, and which rung of the ladder it cleared.

Keep a second table for what was **deliberately not added**, with what does the
job instead. That table is the point of the register. It is cheaper to read
than to re-litigate, and it is the first thing a new contributor reaches for
when they are about to add a state manager.

A dependency without a row is a review failure. So is a row that only repeats
the package's own tagline.

## 6. The pipeline is part of the supply chain

It holds repository write access and production credentials, which makes it a
higher-value target than the application.

- `npm ci`, never `npm install`, in CI. A lockfile disagreement must fail the
  build rather than resolve something new.
- Third-party CI actions pinned by commit SHA, with the version in a trailing
  comment. Tags are mutable and can be repointed after review.
- `permissions:` declared explicitly, read-only by default.
- Any binary the pipeline downloads is version pinned and checksum verified. An
  unverified download inside the job that hunts for supply chain holes is one.
- No workflow trigger that combines untrusted code with secrets.
- No interpolation of attacker-controllable fields into a shell step.

## 7. Secret scanning

Scan full history, not the working tree, and gate the build on it.

Allowlist documented placeholders **by value, never by path**. Allowlisting a
file hides a real credential committed to that same file later. Verify the
allowlist is still tight by planting a realistic fake key in an allowlisted
file and confirming the scan still fails.

For a reviewed historical finding, use the scanner's fingerprint mechanism,
keyed to the exact commit, file, rule and line, with the reasoning written
next to it. Never widen a rule to silence one finding.
