# MCPs — Tested and Recommended

Model Context Protocol servers that are tested and used in production-like sessions. Each subfolder or section documents setup, available tools, and DevOps/SRE use cases.

## Connected MCPs (Claude Code desktop / CLI)

Configure in `~/.claude/claude_desktop_config.json` (desktop) or `~/.claude/settings.json` (CLI).

| MCP | What it connects to | Key DevOps tools |
|-----|-------------------|-----------------|
| [grafana](./grafana.md) | Grafana instance | Loki queries, Prometheus queries, incidents, on-call, alerting |
| [notion](./notion.md) | Notion workspace | Runbook pages, incident post-mortems, architecture docs |
| [google-drive](./google-drive.md) | Google Drive | Shared architecture docs, compliance artifacts, meeting notes |
| gmail | Gmail | Incident notification drafts, vendor communications |
| google-calendar | Google Calendar | On-call rotation coordination, maintenance window scheduling |

## External plugin MCPs (claude-plugins-official marketplace)

Install via `/plugin install <name>@claude-plugins-official`. These become available as MCP tools automatically after installation.

See [external-plugins.md](./external-plugins.md) for setup and use cases.

## Choosing an MCP vs. a skill/plugin

- **MCP:** connects to a live external system (databases, APIs, SaaS). Real-time data.
- **Plugin/skill:** changes how Claude Code behaves (code review style, security scanning, diagram generation). No external system needed.
- Use both: a Grafana MCP for live metric queries during an incident + `systematic-debugging` skill to structure the investigation.
