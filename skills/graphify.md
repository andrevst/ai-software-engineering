# Graphify — Knowledge Graph Skill

Installed globally via `~/.claude/CLAUDE.md`. Trigger: `/graphify`.

Turns any folder of files (code, docs, PDFs, images, video) into a persistent, queryable knowledge graph with community detection, an audit trail (EXTRACTED / INFERRED / AMBIGUOUS edges), and three automatic outputs:

- **Interactive HTML** visualization with node clustering
- **GraphRAG-ready JSON** (`graphify-out/graph.json`) for agent queries
- **GRAPH_REPORT.md** — plain-language community summaries

## Installation

```bash
# Install graphify Python package
uv tool install graphifyy
# or
pip install graphifyy

# The skill activates via /graphify in any Claude Code session
# where ~/.claude/CLAUDE.md contains: /graphify
```

## Commands

```bash
/graphify                                    # current directory
/graphify <path>                             # specific path
/graphify https://github.com/org/repo        # clone + graph
/graphify <url1> <url2>                      # multi-repo merge
/graphify <path> --mode deep                 # thorough extraction, richer inferred edges
/graphify <path> --update                    # incremental — only new/changed files
/graphify <path> --directed                  # preserve edge direction (source→target)
/graphify <path> --mcp                       # start MCP stdio server
/graphify <path> --wiki                      # agent-crawlable wiki (index.md + community articles)
/graphify <path> --obsidian                  # write Obsidian vault
/graphify <path> --neo4j-push bolt://localhost:7687
/graphify <path> --falkordb-push falkordb://localhost:6379
/graphify <path> --svg                       # also export SVG
/graphify <path> --graphml                   # export GraphML (Gephi, yEd)
/graphify <path> --no-viz                    # skip HTML, just report + JSON
/graphify <path> --watch                     # auto-rebuild on file changes

# Query an existing graph (no rebuild if graphify-out/graph.json exists)
/graphify query "<question>"                 # BFS — broad context
/graphify query "<question>" --dfs           # DFS — trace a specific path
/graphify path "AuthModule" "Database"       # shortest path between two concepts
/graphify explain "RLSPolicy"               # plain-language node explanation
/graphify add <url>                          # fetch URL, add to corpus, update graph
```

## Fast path

If `graphify-out/graph.json` exists and the request is a question about the codebase, the skill queries the existing graph directly — no rebuild needed. The graph persists across sessions.

## Export formats

| Format | Flag | Use |
|--------|------|-----|
| HTML (default) | (none) | Interactive browser visualization |
| SVG | `--svg` | Embed in Notion, GitHub README |
| GraphML | `--graphml` | Gephi, yEd for layout editing |
| Neo4j Cypher | `--neo4j` / `--neo4j-push` | Graph database for advanced queries |
| FalkorDB Cypher | `--falkordb` / `--falkordb-push` | Redis-based graph DB |
| MCP server | `--mcp` | Any agent can call `graphify query` as a tool |

## Works on

Code (any language), Markdown, PDFs, papers, images, video/audio (Whisper transcription via `--whisper-model`)

## DevOps use cases

| Use case | Command |
|---------|---------|
| Map Terraform module dependency graph | `/graphify terraform/modules --directed` |
| Understand inherited service mesh | `/graphify src --mode deep` |
| Multi-repo platform architecture | `/graphify https://github.com/org/infra https://github.com/org/app` |
| Agent-browsable runbook wiki | `/graphify docs --wiki` |
| Sync to Obsidian vault | `/graphify . --obsidian --obsidian-dir ~/vaults/platform` |
| Feed graph into RAG pipeline | `/graphify . --no-viz` → use `graphify-out/graph.json` |
| Live docs update (CI job) | `/graphify docs --watch` |
| Expose graph as MCP tool | `/graphify . --mcp` → any connected agent queries it |

## When to use graphify

- At the start of any session with an unfamiliar codebase (before `project-analizer`)
- When the answer to "how does X connect to Y" is not obvious from reading individual files
- When building agent context from a large multi-repo platform
- When the team needs a navigable, versioned knowledge base of architecture relationships
