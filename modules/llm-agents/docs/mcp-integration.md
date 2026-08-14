# codebase-memory-mcp — per-project MCP integration

Replaces gitnexus. The binary is installed by
`modules/llm-agents/codebase-memory-mcp.nix` and is **not** wired globally on
purpose: the graph is per-repository, so each project opts in.

## Binary path

Use the per-user profile path, not a `/nix/store/...` path — it stays valid
across rebuilds:

```
/etc/profiles/per-user/<username>/bin/codebase-memory-mcp
```

`<username>` is `derangga` on `maclop`, `sociolla` on `worklop`. Confirm with
`which codebase-memory-mcp`.

## Claude Code

Create `.mcp.json` in the project root:

```json
{
  "mcpServers": {
    "codebase-memory": {
      "type": "stdio",
      "command": "/etc/profiles/per-user/sociolla/bin/codebase-memory-mcp",
      "args": []
    }
  }
}
```

- On the next start Claude Code asks to approve the project-scoped server; the
  approval is stored in `.claude/settings.local.json` (per-user, gitignored),
  while `.mcp.json` itself is safe to commit for the team.
- Verify with `/mcp` — `codebase-memory` should list 15 tools.
- First use: ask *"index this project"*, or index it yourself first
  (see `quick-start.md`).

If a repo should not share the config, put the same block in
`~/.claude.json` under `projects.<abs-path>.mcpServers` instead.

## opencode

Create `opencode.json` in the project root (same shape as the global
`~/.config/opencode/opencode.jsonc`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "codebase-memory": {
      "type": "local",
      "command": ["/etc/profiles/per-user/sociolla/bin/codebase-memory-mcp"],
      "enabled": true
    }
  }
}
```

Project config is merged over the global one, so this adds the server for this
repo only.

## Optional per-project files

| File | Purpose |
|------|---------|
| `.cbmignore` | Extra ignore patterns, gitignore syntax. Applied after `.gitignore`. |
| `.codebase-memory.json` | `{"extra_extensions": {".blade.php": "php"}}` — map odd extensions to a language. |
| `.codebase-memory/graph.db.zst` | Compressed graph snapshot. Commit it and teammates skip the full reindex; otherwise add `.codebase-memory/` to `.gitignore`. |

## Environment knobs

Set in the MCP server's `env` block or your shell:

- `CBM_CACHE_DIR` — index/config location (default `~/.cache/codebase-memory-mcp`).
  One value per account; close all sessions before changing it.
- `CBM_ALLOWED_ROOT` — confine `index_repository` to paths under this directory.
- `CBM_LOG_LEVEL` — `debug|info|warn|error|none`.

## Do not run `install` / `update` / `uninstall`

Those upstream commands rewrite agent config files and try to replace the
binary in place. The binary lives read-only in the Nix store and the MCP wiring
is the per-project files above. To upgrade, bump `version` and the `sha256`
values in `modules/llm-agents/codebase-memory-mcp.nix`
(hashes come from the release's `checksums.txt`), then rebuild.
