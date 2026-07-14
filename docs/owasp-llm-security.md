# OWASP LLM Top 10 — Security Guide for AI-Assisted Engineering

**Reference:** [OWASP Top 10 for LLM Applications 2025](https://owasp.org/www-project-top-10-for-large-language-model-applications/)  
**Last updated:** 2026-07-14

---

## What is covered by existing tooling

### `security-guidance` plugin (OWASP Web Top 10)

Install: `/plugin install security-guidance@claude-plugins-official`

Three-layer review wired into the Claude Code edit/commit lifecycle:

| Layer | Trigger | Mechanism |
|-------|---------|-----------|
| 1. Pattern warnings | Every `Edit`/`Write` | Regex match against 25 known-dangerous patterns |
| 2. LLM diff review | End of each Claude turn (Stop hook) | Opus 4.8 reads the full diff; feeds findings back before the user sees the response |
| 3. Agentic commit review | `git commit` | SDK agent traces data flow across files — catches IDOR, auth bypass, SSRF that single-file matching misses |

**25 rules by OWASP Web Top 10 class:**

| OWASP Class | Rules covered |
|------------|--------------|
| A03 Injection | `child_process_exec`, `eval_injection`, `new_function_injection`, `os_system_injection`, `python_subprocess_shell`, `go_exec_shell_injection`, `github_actions_workflow` |
| A07 XSS | `react_dangerously_set_html`, `document_write_xss`, `innerHTML_xss`, `outerHTML_xss`, `insertAdjacentHTML_xss`, `script_src_without_sri` |
| A08 Insecure Deserialization | `pickle_deserialization`, `pickle_variants_load`, `pickle_wrapper_load`, `marshal_loads`, `shelve_open`, `torch_unsafe_load` |
| A05 Security Misconfiguration | `unsafe_yaml_load`, `yaml_unsafe_load_variants`, `xml_unsafe_parse`, `tls_verification_disabled` |
| A02 Crypto Failures | `node_createcipher_no_iv`, `aes_ecb_mode` |

A01 (Broken Access Control) and A04 (Insecure Design) have no pattern rules — covered by the LLM diff review (layer 2) and agentic commit review (layer 3) through semantic reasoning.

---

## OWASP LLM Top 10 — Gap analysis and mitigations

| # | Risk | Current tool coverage | Gap | Mitigation |
|---|------|-----------------------|-----|-----------|
| LLM01 | Prompt Injection | Claude Code refuses malicious injection via system prompt | No scanner for user-facing prompts in application code | Add fuzz tests at CI for AI-facing endpoints using OWASP LLM test payloads |
| LLM02 | Insecure Output Handling | `innerHTML_xss` + `react_dangerously_set_html` catch LLM output rendered as HTML | No check that LLM output is sanitized before DB writes or shell execution | Add to `claude-security-guidance.md`: LLM output that reaches `exec`, `db.query`, or DOM must be sanitized |
| LLM03 | Training Data Poisoning | Out of scope for application-layer tooling | No tooling | Governance process: track training dataset provenance separately |
| LLM04 | Model DoS | No coverage | No rate-limit or token-budget checker | Enforce rate limits at the API gateway; set max_tokens caps in all LLM client calls |
| LLM05 | Supply Chain | `dependency-auditor` catches outdated AI SDK versions | No model provenance or SBOM for ML models | Pin model IDs explicitly (`claude-sonnet-4-6` not `claude-sonnet-latest`); audit in dependency report |
| LLM06 | Sensitive Information Disclosure | `security-guidance` catches hardcoded secrets | No check that PII/PHI is excluded from prompt context | Add rule to `claude-security-guidance.md`: prompt context must not include raw rows from tables with PII columns |
| LLM07 | Insecure Plugin Design | `mcp-server-dev` plugin includes tool-design security references | No automated MCP permission scope auditor | Review each MCP server's exposed tools against principle of least privilege; read-only MCPs must not expose write tools |
| LLM08 | Excessive Agency | Claude Code confirmation prompts for destructive actions; blast-radius layers in CLAUDE.md | No formal least-privilege auditor for agent tool grants | Document allowed tools per agent in AGENTS.md; use `allowed-tools:` frontmatter in command files |
| LLM09 | Overreliance | Human-in-the-loop by design (user approves tool calls) | No hallucination detection in generated outputs | Require human review of all AI-generated ADRs, runbooks, and security documents before merging |
| LLM10 | Model Theft | Out of scope | No tooling | Restrict API key scopes; monitor token usage anomalies via billing dashboards |

---

## Custom security policy file

Drop a `claude-security-guidance.md` in `.claude/` to add project-specific rules to the LLM diff review (layer 2). All three files are concatenated: `~/.claude/` (user-wide) → `.claude/claude-security-guidance.md` (project) → `.claude/claude-security-guidance.local.md` (local, gitignored).

**Template for AI output paths:**
```markdown
# AI output security rules

- LLM output rendered to DOM must pass through DOMPurify or equivalent sanitizer before innerHTML assignment.
- LLM output passed to shell execution (exec, spawn, system) must be rejected — log and surface as an error, never execute.
- Prompt context must not include raw DB rows from tables containing PII columns (email, name, phone, address, date_of_birth).
- Model IDs must be pinned explicitly in all LLM client calls — no floating aliases like "claude-sonnet-latest".
- All AI-generated documents (ADRs, runbooks, security reviews) require human review before merging to main.
```

**Template for infrastructure/IaC repos:**
```markdown
# IaC security rules

- No real AWS account IDs or ARNs in any committed file. Use 000000000000 and REPLACE.
- IRSA roles must be scoped to a single component's resources (one bucket ARN, one secret ARN).
- No static AWS credentials. IAM roles only.
- No shell: true in subprocess calls or exec() with string concatenation.
- GitHub Actions workflows must use environment variables for all user-controlled inputs.
```

---

## Configuration reference

```bash
# Disable specific layers (useful in CI or multi-agent setups)
ENABLE_PATTERN_RULES=0         # disable regex layer
ENABLE_STOP_REVIEW=0           # disable LLM diff review (keep for multi-agent shared worktrees)
ENABLE_COMMIT_REVIEW=0         # disable agentic commit reviewer
SECURITY_GUIDANCE_DISABLE=1    # kill switch for entire plugin

# Higher recall (2x cost, ~3% more findings)
SG_DUAL_OR=on

# Override model (default: claude-opus-4-8)
SECURITY_REVIEW_MODEL=claude-opus-4-8
SG_AGENTIC_MODEL=claude-opus-4-8
```

---

## What to build next

1. **Prompt injection CI test suite** — fuzz AI-facing endpoints with OWASP LLM Top 10 test payloads on every PR.
2. **MCP scope auditor** — `ponytail-audit`-style review that checks each MCP server's exposed tools against least privilege.
3. **AI dependency audit extension** — extend `project-analizer` dependency audit to flag pinned vs. floating model IDs, AI SDK versions, and embedding model versions.
4. **PII prompt context scanner** — static analysis pass that checks which DB columns flow into prompt context builders, flagging any column tagged as PII.
