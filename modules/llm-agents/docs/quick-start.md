# codebase-memory-mcp — manual quick start

Everything the MCP server exposes is also runnable from the shell:
`codebase-memory-mcp cli <tool> [--flags]`. CLI mode is one-shot — it starts no
daemon and leaves no process behind. `cli <tool> --help` prints the flags for
that tool.

Progress goes to stderr, results to stdout, so `| jq` is always safe. Add
`--json` for the full MCP envelope, `--progress` to force progress output when
stderr is not a terminal.

## 1. Index a repo

```bash
cd ~/my-project
codebase-memory-mcp cli index_repository --repo-path "$PWD"
```

Useful flags:

- `--mode fast|moderate|full` — `full` adds similarity + semantic edges,
  `fast` skips them. Semantic search (`--semantic-query`) needs `moderate`/`full`.
- `--name <project>` — override the derived project name.
- `--persistence true` — also write `.codebase-memory/graph.db.zst` for the team.

Then:

```bash
codebase-memory-mcp cli list_projects            # project names + node/edge counts
codebase-memory-mcp cli index_status --project my-project
codebase-memory-mcp cli delete_project --project my-project
```

The `name` from `list_projects` is the `--project` value everywhere else.

## 2. Explore

```bash
# What is in the graph — run this first
codebase-memory-mcp cli get_graph_schema --project my-project

# Bird's-eye view: languages, packages, entry points, routes, hotspots
codebase-memory-mcp cli get_architecture --project my-project

# Find symbols
codebase-memory-mcp cli search_graph --project my-project \
  --name-pattern '.*Handler.*' --label Function

# Full-text/BM25 instead of a regex
codebase-memory-mcp cli search_graph --project my-project --query "upload avatar"

# Who calls it / what it calls
codebase-memory-mcp cli trace_path --project my-project \
  --function-name Search --direction both

# Read the source of a symbol (qualified name from search_graph)
codebase-memory-mcp cli get_code_snippet --project my-project \
  --qualified-name my-project.src.search.Search

# Grep, but only over indexed files
codebase-memory-mcp cli search_code --project my-project --query "TODO"

# Uncommitted changes → affected symbols + risk
codebase-memory-mcp cli detect_changes --project my-project

# Cypher (read-only subset)
codebase-memory-mcp cli query_graph --project my-project \
  --query 'MATCH (f:Function) RETURN f.name LIMIT 5'

# Dead code
codebase-memory-mcp cli query_graph --project my-project \
  --query 'MATCH (f:Function) WHERE NOT EXISTS { (f)<-[:CALLS]-() } RETURN f.name LIMIT 20'
```

Piping works as expected:

```bash
codebase-memory-mcp cli search_graph --project my-project --label Function --format json \
  | jq '.'
```

## 3. Graph UI

The UI is served by CBM's shared coordination daemon, and that daemon only
lives while at least one MCP session is connected. `cli` commands never start
it. So there is nothing to "serve" separately — you enable it once, then it is
up whenever an agent has the MCP server connected:

```bash
codebase-memory-mcp --ui=true --port=9749   # persists ui_enabled/ui_port, then exits
```

(Stored in `~/.cache/codebase-memory-mcp/config.json`. `--ui=false` turns it off.)

Open <http://localhost:9749> while Claude Code or opencode has `codebase-memory`
connected. Close every such session and the daemon stops — the port goes away
with it (`daemon.runtime_stopping reason=last_committed_client_disconnected`).

To browse without an agent session, run the server yourself and leave it
running — it is an MCP stdio server, so keep the terminal open and stop it with
Ctrl-C:

```bash
codebase-memory-mcp        # blocks; UI is live at :9749 until you stop it
```

## 4. Settings

```bash
codebase-memory-mcp config list
codebase-memory-mcp config set auto_index true       # index new projects on MCP session start
codebase-memory-mcp config set auto_index_limit 50000
codebase-memory-mcp config set auto_watch false      # don't register the background git watcher
codebase-memory-mcp config reset auto_index
```

## 5. State and cleanup

Everything lives under `~/.cache/codebase-memory-mcp/` (override with
`CBM_CACHE_DIR`), **one SQLite file per indexed project**, named after the repo
path with `/` replaced by `-`:

```
~/.cache/codebase-memory-mcp/
  Users-johndoe-Documents-johndoe-bj-admin.db   14.9M   ← one project
  Users-johndoe-nix.db                                   ← another
  _config.db                                              ← config set/reset values
  config.json                                             ← ui_enabled / ui_port
  logs/                                                   ← daemon logs
```

### See what is using space

```bash
du -sh ~/.cache/codebase-memory-mcp/*.db | sort -h   # biggest last
codebase-memory-mcp cli list_projects               # names + node/edge counts
```

### Drop a project

```bash
codebase-memory-mcp cli delete_project --project my-project
```

Use this rather than deleting the file — it also clears the project's registry
and watcher state. **Close any agent session connected to that project first**:
graph mutations take a per-project lock, so a delete will block on (or fail
against) a live session. `rm`-ing the `.db` works as a fallback since nothing
else references it, but only with no CBM session running.

### Keep them from growing back

- `.cbmignore` in the repo root (gitignore syntax) — the cheapest fix when one
  project's `.db` is disproportionate; usually generated code or vendored trees.
- `--mode fast` on reindex — skips similarity + semantic edges, which are the
  bulk of a `full` graph. You lose `--semantic-query`.
- `config set auto_index false` — stop indexing every new repo an agent opens.
- `config set auto_watch false` — stop background reindexing of projects you
  only touched once.

### Full reset

```bash
rm -rf ~/.cache/codebase-memory-mcp/
```

Drops every index plus the `auto_index`/UI settings. Everything reindexes on
next use.

Do **not** run `install`, `update`, or `uninstall` — see `mcp-integration.md`.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `trace_path` returns nothing | Find the exact name first: `search_graph --name-pattern '.*Partial.*'`. |
| Results from the wrong repo | Pass `--project`; check names with `list_projects`. |
| `index_repository` fails | Use an absolute `--repo-path`. |
| Too much indexed / too little | `.cbmignore` in the repo root, `.codebase-memory.json` for extra extensions. |
| "another CBM process is active" | All CBM processes must share one version and cache root — close other agent sessions first. |
