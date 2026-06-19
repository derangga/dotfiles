# FFF MCP

FFF (Fast File Finder) MCP server provides frecency-ranked file search for Claude Code.

## Global Configuration

Add to `~/.claude.json` under the top-level `mcpServers` key:

```json
"mcpServers": {
  "fff": {
    "type": "stdio",
    "command": "/etc/profiles/per-user/sociolla/bin/fff-mcp",
    "args": []
  }
}
```

The `command` path points to the fff-mcp binary installed via Nix at `modules/llm-agents/default.nix`.

## Global CLAUDE.md Instruction

Add to `~/.claude/CLAUDE.md` to enforce fff usage for all projects:

```
For any file search or grep in the current git-indexed directory, use fff mcp tools.
```

## Available Tools

- **`find_files`** — fuzzy file search by name (not contents). Use when looking for a file by name or path pattern.
- **`grep`** — search file contents by identifier or keyword. Use for definitions, usage patterns, and symbol lookups.
- **`multi_grep`** — OR logic across multiple patterns. Use for case variants or multiple identifiers at once.

## Usage Notes

- Search bare identifiers only — avoid regex or multi-word queries
- Results are frecency-ranked (frequent + recent files boosted, git-dirty files surfaced first)
- Stop after 2 grep calls and read the file — more greps rarely help
