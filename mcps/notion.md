# Notion MCP

Connects Claude Code to a Notion workspace. Tested with personal and team workspaces.

## Key tools

| Tool | Use |
|------|-----|
| `notion-search` | Find pages and databases by keyword |
| `notion-fetch` | Read a page or database by URL or ID |
| `notion-create-pages` | Create new pages in a parent page or database |
| `notion-update-page` | Edit page content or properties |
| `notion-create-database` | Create a new database |
| `notion-query-database-view` | Query a database with filters and sorts |
| `notion-create-comment` | Add a comment to a page |
| `notion-get-comments` | Read comments on a page |
| `notion-duplicate-page` | Copy a page to a new location |
| `notion-move-pages` | Move pages within the workspace |
| `notion-create-attachment` | Attach a file to a page |
| `notion-query-meeting-notes` | Find meeting notes by date or attendees |
| `notion-get-teams`, `notion-get-users` | Workspace member information |

## DevOps / SRE use cases

| Scenario | Workflow |
|---------|---------|
| **Incident post-mortem** | After incident closes: `notion-create-pages` with timeline, root cause, and action items from incident data |
| **Runbook authoring** | `notion-create-pages` from architecture analysis output; `notion-create-attachment` for C4 diagrams |
| **ADR publishing** | `notion-create-pages` per ADR file; link them using `notion-update-page` |
| **Sprint planning** | `notion-create-database` with task cards; `notion-query-database-view` for status reports |
| **On-call handoff** | `notion-create-pages` for handoff note; `notion-query-meeting-notes` to pull context from previous week |
| **Architecture snapshots** | `notion-create-pages` from `docs/agents/PROJECT-OVERVIEW.md`; embed panel screenshots from Grafana MCP |
