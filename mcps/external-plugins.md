# External Plugin MCPs (claude-plugins-official)

These MCPs ship as part of the `claude-plugins-official` marketplace and install as MCP servers automatically when the plugin is installed.

Install via: `/plugin install <plugin-name>@claude-plugins-official`

## Development and code intelligence

| Plugin / MCP | Tools | Use case |
|-------------|-------|---------|
| `context7` | Library documentation lookup | Real-time, up-to-date library docs injected into context — eliminates hallucinated APIs |
| `greptile` | Semantic codebase search | Cross-repo semantic search; useful for large monorepos where `grep` misses intent |
| `serena` | Language server protocol (LSP) | Accurate symbol lookup, refactoring, go-to-definition across large codebases |
| `playwright` | Browser automation | UI smoke tests after deploy; accessibility checks; screenshot diffs |

## Source control

| Plugin / MCP | Tools | Use case |
|-------------|-------|---------|
| `github` | PRs, issues, releases, repos, checks | PR creation from Claude Code; issue triage; release notes generation |
| `gitlab` | Same as github for GitLab | GitLab-hosted repos and CI pipelines |

## Project management

| Plugin / MCP | Tools | Use case |
|-------------|-------|---------|
| `linear` | Issues, projects, cycles, teams | Create tickets from architectural findings or dependency audit results |
| `asana` | Tasks, projects, portfolios | Sprint management; milestone tracking |

## Infrastructure

| Plugin / MCP | Tools | Use case |
|-------------|-------|---------|
| `terraform` | plan, apply, workspace management | Terraform operations from Claude Code |
| `firebase` | Auth, Firestore, Functions, Hosting | Firebase project management and data queries |

## Communication

| Plugin / MCP | Tools | Use case |
|-------------|-------|---------|
| `discord` | Send messages, read channels | Incident notifications to engineering channels |
| `telegram` | Send messages | Alerting and status updates |
| `imessage` | Send messages | Personal alerting (macOS only) |

## MCP security checklist

Before adding any MCP to a project:

- [ ] Read-only tools only unless write access is explicitly needed
- [ ] Token/credential stored in `~/.claude/settings.json` secrets, not in project files
- [ ] Confirm the MCP does not expose admin or destructive tools (database drops, repo deletion)
- [ ] Document in the project's CLAUDE.md which MCPs are active and what they connect to
- [ ] For write-capable MCPs: confirm in CLAUDE.md that the agent must ask before any write operation
