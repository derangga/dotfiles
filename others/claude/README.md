# Claude Status Line

A custom status line for Claude Code showing git branch, model, context usage, session usage, and time — styled with Catppuccin Macchiato colors.

## Setup

**1. Copy the script to `~/.claude/`:**

```bash
cp others/claude/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

**2. Update `~/.claude/settings.json` to use the status line:**

```json
{
  "statusCommand": "~/.claude/statusline.sh"
}
```

## What It Shows

- **Git branch** — current branch with dirty/stash/ahead/behind indicators
- **Model** — active Claude model name
- **Context** — usage percentage with a fill bar (green → yellow → red)
- **Session** — 5-hour rate limit usage (Claude.ai subscriptions only)
- **Time** — current time (HH:MM)
