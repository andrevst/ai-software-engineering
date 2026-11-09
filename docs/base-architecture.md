# A validated base architecture for product work

The stack, the eight decisions behind it, and what each one costs. Use it as a
starting point or as a worked example of recording decisions properly.

Validated by building it: a consulting landing page with a blog, a one-off
payment paywall, a newsletter, two lead lists and five selectable themes. The
full source, the arc42 record and the eight ADRs are at
[arqui-dev/sweai-base-apps](https://github.com/arqui-dev/sweai-base-apps).

## The stack

| Layer | Choice | Not chosen |
|-------|--------|------------|
| Framework | Next.js App Router, React, TypeScript strict | A separate backend service |
| Styling | Tailwind with CSS custom properties per theme | A component library, a theming library |
| Hosting | Vercel, one project per deployable | A monorepo, before a second app exists |
| Identity and data | Supabase: magic-link auth, Postgres with row level security | An ORM, application-level authorization |
| Payments | Stripe hosted Checkout | Any card handling in the application |
| Content | Headless CMS, editor hosted by the vendor | The editor embedded in the application |
| Email | Transactional API | SMTP, a mail server |
| Validation | One schema library at every trust boundary | Hand-written type guards |

Twelve production dependencies. Zero runtime vulnerabilities, gated in CI.

## The decisions

Each row is a full ADR in the reference implementation. The last column is the
part most often omitted and the most valuable: what has to change for the
losing option to win.

| # | Decision | Deciding criterion | Reverses when |
|---|----------|--------------------|---------------|
| 1 | Framework route handlers, not a separate backend service | The backend is six short request-response operations. A service framework's value shows up in problems this does not have | A second client needs the same API, or background work outlives a request |
| 2 | Row level security as the authorization layer | The failure mode. With policies, a forgotten check returns no rows. With application filters, it returns every row | Rules depend on a third service that policies express badly. Then use a database function called from a policy, not application filters |
| 3 | Entitlements keyed by email, user id optional | A forced sign-in before a small payment is the largest cost in the only flow that earns money | Entitlements carry real value, where stable identity beats convenient identity |
| 4 | Themes as CSS custom properties | The themes differ in token values, not in structure, so tokens are the right granularity | A theme needs different markup. That is a different product, not a theme |
| 5 | Paywall enforced in the content query | The failure mode. Fetch-then-truncate leaks silently the first time someone passes the object to a client component, and no reviewer would catch it | Content must load incrementally, section by section |
| 6 | Content editor hosted by the vendor | The wrapper that embeds it pulls the editor's CLI into the production tree: 21 advisories, 3 high, unfixable without a major downgrade | The wrapper moves the editor to an optional dependency |
| 7 | Zero runtime vulnerabilities, enforced in CI | An audit that permanently reports high findings is an audit nobody reads | Never. The scope split is negotiable; the tolerance is not |
| 8 | One hosting project per deployable, no monorepo | The useful part of a monorepo is a shared package, and its boundary can only be drawn correctly once a second consumer exists to argue with | A second deployable application exists. Then extract only what it actually imports |

## What the base deliberately does not have

The register of rejected dependencies, which doubles as the list of problems
the platform already solves.

| Not added | What does the job |
|-----------|-------------------|
| State manager | Component state, and a cookie for the one value the server must also know |
| Component library | Five class-string helpers, so the same styles apply to a button, an anchor and a framework link without a polymorphic prop |
| Form library | Native input validation, one pending flag, schema validation on the server |
| Theming library | CSS custom properties under one attribute |
| ORM or query builder | The database client, with row level security as authorization |
| Logging library | Twelve lines around `console`, one JSON object per line, collected by the host |
| HTML sanitizer | Nine lines for escaping into our own templates. A sanitizer is required for rendering untrusted documents, which this never does |
| URL validation library | Nine lines over the built-in URL parser and a three-scheme allowlist |
| Rate limiter | A map and a fixed window, with its per-instance ceiling written in the file |
| Crypto helper | The language's crypto module |

## Three patterns worth copying

**Unset configuration must fail closed.** Every environment variable may be
empty, so the application deploys before any account exists: pages render,
writes answer 503 naming what is unset, reads log and fall back. Secrets never
fall back to a committed placeholder value, because those are public. An unset
secret gets random bytes, which makes every signature and token check fail
closed. Substituting the placeholder instead would mean anyone who can read the
repository can authenticate.

**Degrade loudly.** A page that falls back on a failed query still logs the
reason. Four silent catch blocks once made a misconfigured content project
render as a working, empty page with no trace of why.

**Put the invariant in one expression, and test that.** The read rule for paid
content lives in one function that the page and the test both call, so they
cannot drift. A second assertion throws if a locked item ever carries a body,
which converts a future regression into an error instead of a leak.

## What it costs

Stated so the trade is visible.

- Authorization lives in SQL, so it has no unit test until a database runs in
  CI. Policies are short and reviewed, which is a mitigation and not a test.
- The deliberate shortcuts are real: a per-instance rate limiter, a
  report-only content security policy, no alerting. Each carries a comment in
  the code naming its ceiling and the trigger to replace it.
- One hosting project per deployable means every build installs the whole
  repository. Irrelevant at this size, and an ignored-build-step setting
  handles it long before a monorepo is justified.
