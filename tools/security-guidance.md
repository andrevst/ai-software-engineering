# security-guidance Plugin

Automatic security review for Claude Code. Three layers wired into the edit/commit lifecycle.

Install: `/plugin install security-guidance@claude-plugins-official`

## Architecture

```
Edit/Write tool call
    → Layer 1: regex pattern match against 25 rules
    → instant inline warning if matched

Claude turn ends (Stop hook)
    → Layer 2: LLM diff review (Opus 4.8)
    → feeds high-severity findings back to Claude before user sees the response

git commit
    → Layer 3: agentic commit review
    → SDK agent reads related files (Read/Grep/Glob)
    → traces data flow across codebase
    → catches IDOR, auth bypass, cross-file SSRF
```

## The 25 pattern rules

Organized by OWASP Web Top 10 class:

**A03 — Injection**
- `child_process_exec` — Node.js `exec()` / `execSync()` (shell injection risk)
- `eval_injection` — JavaScript `eval()`
- `new_function_injection` — `new Function()` (eval equivalent)
- `os_system_injection` — Python `os.system()`
- `python_subprocess_shell` — `subprocess` with `shell=True`
- `go_exec_shell_injection` — Go `exec.Command()` with shell string
- `github_actions_workflow` — CI/CD expression injection (`${{ github.event.* }}` in `run:`)

**A07 — XSS**
- `react_dangerously_set_html` — `dangerouslySetInnerHTML`
- `document_write_xss` — `document.write()`
- `innerHTML_xss` — direct `.innerHTML` assignment
- `outerHTML_xss` — direct `.outerHTML` assignment
- `insertAdjacentHTML_xss` — `.insertAdjacentHTML()`
- `script_src_without_sri` — `<script src>` without `integrity` attribute

**A08 — Insecure Deserialization**
- `pickle_deserialization` — Python `pickle.load()`
- `pickle_variants_load` — cPickle, cloudpickle, dill, joblib, numpy `allow_pickle=True`
- `pickle_wrapper_load` — shelve, joblib wrappers
- `marshal_loads` — Python `marshal.loads()`
- `shelve_open` — Python `shelve.open()`
- `torch_unsafe_load` — `torch.load(weights_only=False)` (arbitrary code execution)

**A05 — Security Misconfiguration**
- `unsafe_yaml_load` — `yaml.load()` / `yaml.unsafe_load()`
- `yaml_unsafe_load_variants` — PyYAML Loader variants that allow Python object tags
- `xml_unsafe_parse` — XML parsing without XXE protection
- `tls_verification_disabled` — `verify=False`, `rejectUnauthorized: false`

**A02 — Cryptographic Failures**
- `node_createcipher_no_iv` — Node.js `crypto.createCipher()` (no IV)
- `aes_ecb_mode` — AES-ECB mode (deterministic, pattern-preserving)

## Configuration

```bash
# Disable specific layers
ENABLE_PATTERN_RULES=0         # disable layer 1 (regex warnings)
ENABLE_STOP_REVIEW=0           # disable layer 2 (LLM diff review)
ENABLE_COMMIT_REVIEW=0         # disable layer 3 (agentic commit reviewer)
SECURITY_GUIDANCE_DISABLE=1    # kill switch — disable entire plugin

# Higher recall (two parallel review calls, union of findings — ~2x cost)
SG_DUAL_OR=on

# Model override (default: claude-opus-4-8)
SECURITY_REVIEW_MODEL=claude-opus-4-8
SG_AGENTIC_MODEL=claude-opus-4-8
```

**Disable layer 2 for multi-agent setups:** When multiple agents share a worktree, another agent may move HEAD between turns. Set `ENABLE_STOP_REVIEW=0` to avoid reviewing a diff that wasn't written by this agent.

## Custom policy file

Drop `claude-security-guidance.md` in `.claude/` (project-scoped) or `~/.claude/` (user-wide). All files concatenate into the layer 2 prompt in order: user → project → project-local (gitignored).

8 KB budget; if exceeded, project-local is truncated first.

**Template:**
```markdown
# Project security rules

- All DB queries must use parameterized statements via the Supabase client — never string concatenation with user input.
- SUPABASE_SERVICE_ROLE_KEY must never appear in NEXT_PUBLIC_ variables or client-side bundles.
- LLM output passed to any shell execution path must be rejected, not sanitized.
- Prompt context must not include raw rows from tables with PII columns (email, name, phone, address).
- Model IDs must be pinned explicitly — no floating aliases like "claude-sonnet-latest".
```

## Coverage gaps

- **A01 Broken Access Control / IDOR** — no pattern rule; covered by layer 3 (agentic commit review traces data flow across files)
- **A04 Insecure Design** — no pattern rule; covered by layer 2 (LLM diff review reasons about design)
- **OWASP LLM Top 10** — not covered by pattern rules; see `docs/owasp-llm-security.md` for full gap analysis and mitigations
