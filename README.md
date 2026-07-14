# ai-software-engineering

Way of work, skills, prompts, guidelines, and tools for AI-assisted software engineering.

Use this repo as the parent folder of your project repos. The skills and guidelines apply workspace-wide; individual repos carry their own `CLAUDE.md` for project-specific rules.

## Purpose

- Define a consistent AI working style across projects
- Version reusable prompts, templates, and agent workflows
- Document which tools, MCPs, and plugins are tested and recommended
- Serve as a guardrail layer complementing each project's own AI config

## Structure

```
ai-software-engineering/
├── docs/           # Reference knowledge: AI tools, security, ecosystem
├── guidelines/     # Coding and documentation standards (language-specific)
├── mcps/           # Tested MCP servers — setup, capabilities, DevOps use cases
├── prompts/
│   ├── devops/     # DevOps / Platform Engineering agent playbook prompts
│   ├── analysis/   # Ticket analysis, debugging, investigation prompts
│   └── adrs/       # Architecture Decision Record workflow prompts
├── skills/         # Custom skills and slash commands
├── tools/          # Claude Code plugins and security tooling reference
└── templates/      # CLAUDE.md templates, project bootstrap files
```

## How to use

1. Place this folder as a sibling of your project repos:
   ```
   workspace/
   ├── ai-software-engineering/   ← this repo
   ├── my-app/
   └── my-infra/
   ```
2. Copy `templates/CLAUDE.md` into each project as a starting point.
3. Add project-specific rules, blast-radius docs, and slash commands inside the project's own `.claude/`.
4. Prompts in `prompts/` are self-contained briefs — copy and adapt to your platform context before running.

## Quick reference

| Need | Where to look |
|------|--------------|
| Which MCPs to install | `mcps/` |
| Reusable DevOps agent prompts | `prompts/devops/` |
| TypeScript coding standards | `guidelines/typescript.md` |
| Claude Code plugin marketplace guide | `tools/plugins.md` |
| Security tooling and OWASP coverage | `tools/security-guidance.md` + `docs/owasp-llm-security.md` |
| Full AI tools ecosystem reference | `docs/ai-tools-reference.md` |
| Graphify knowledge graph skill | `skills/graphify.md` |
| CLAUDE.md starter template | `templates/CLAUDE.md` |
