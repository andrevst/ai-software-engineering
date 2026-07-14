# Google Drive MCP

Connects Claude Code to Google Drive. Useful for shared architecture docs, compliance artifacts, and team references.

## Key tools

| Tool | Use |
|------|-----|
| `list_recent_files` | List recently modified files |
| `search_files` | Find files by name or content |
| `read_file_content` | Read a file (Docs, Sheets, plain text, PDF) |
| `get_file_metadata` | File details (owner, last modified, sharing) |
| `get_file_permissions` | Who has access to a file |
| `create_file` | Create a new file in a folder |
| `copy_file` | Duplicate an existing file |
| `download_file_content` | Download binary content |

## DevOps / SRE use cases

| Scenario | Workflow |
|---------|---------|
| **Compliance artifacts** | `create_file` for audit reports from `project-analizer` output |
| **Architecture docs** | `read_file_content` to pull shared design docs into agent context |
| **Runbook sync** | `search_files` to find the current runbook; `read_file_content` for agent context during incidents |
| **Access review** | `get_file_permissions` to audit who can read sensitive architecture documents |
