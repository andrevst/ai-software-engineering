#!/usr/bin/env bash
#
# Prints the live AI tooling inventory for the current project.
#
# Pair with templates/ai-tooling.md: that file carries the judgement about what
# each thing is for, which cannot be generated. This script carries the counts
# and the connection status, which drift. Run it before editing that file.
#
#   ../ai-software-engineering/tools/ai-inventory.sh
set -uo pipefail

line() { printf '\n== %s\n' "$1"; }

line "Plugins"
claude plugin list 2>/dev/null | grep -viE 'deprecat|^$' | sed 's/^/  /'

line "MCP servers"
claude mcp list 2>/dev/null | grep -viE 'deprecat|^$' | sed 's/^/  /'

line "What each plugin ships"
for d in "$HOME"/.claude/plugins/cache/*/*/*/; do
  [ -d "$d" ] || continue
  n=$(echo "$d" | awk -F/ '{print $(NF-2)}')
  v=$(echo "$d" | awk -F/ '{print $(NF-1)}')
  printf '  %-22s v%-9s skills=%-3s cmds=%-3s agents=%-3s hooks=%-4s mcp=%s\n' \
    "$n" "$v" \
    "$(ls "$d/skills"   2>/dev/null | wc -l | tr -d ' ')" \
    "$(ls "$d/commands" 2>/dev/null | wc -l | tr -d ' ')" \
    "$(ls "$d/agents"   2>/dev/null | wc -l | tr -d ' ')" \
    "$([ -f "$d/hooks/hooks.json" ] && echo yes || echo no)" \
    "$([ -f "$d/.mcp.json" ] && echo yes || echo no)"
done | sort -u

line "User skills"
ls "$HOME/.claude/skills" 2>/dev/null | sed 's/^/  /'

line "This project's agents"
if [ -d .claude/agents ]; then
  for f in .claude/agents/*.md; do
    [ -f "$f" ] || continue
    printf '  %-24s model=%s\n' "$(basename "$f" .md)" "$(sed -n 's/^model: //p' "$f" | head -1)"
  done
else
  echo "  (no .claude/agents in $(pwd))"
fi

line "Workspace assets"
W="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for sub in prompts guidelines mcps skills tools templates docs; do
  printf '  %-12s %s markdown files\n' "$sub" \
    "$(find "$W/$sub" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
done
