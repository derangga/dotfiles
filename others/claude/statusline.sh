#!/usr/bin/env bash
# Claude Code status line — inspired by Starship config (catppuccin macchiato)

input=$(cat)

# Extract fields from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty') # needed for git
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limits (Claude.ai subscription — may be absent)
rl_5h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# Git branch and status (skip if not a git repo)
git_info=""
if git -C "${cwd:-$(pwd)}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" symbolic-ref --short HEAD 2>/dev/null ||
    GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Build status indicators (mirrors starship git_status: $all_status$ahead_behind)
    git_flags=""
    git_status_output=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" status --porcelain=v1 2>/dev/null)
    [ -n "$git_status_output" ] && git_flags="*"
    stash_count=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" stash list 2>/dev/null | wc -l | tr -d ' ')
    [ "$stash_count" -gt 0 ] && git_flags="${git_flags}\$${stash_count}"
    ahead=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
    behind=$(GIT_OPTIONAL_LOCKS=0 git -C "${cwd:-$(pwd)}" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
    [ "$ahead" -gt 0 ] && git_flags="${git_flags}+${ahead}"
    [ "$behind" -gt 0 ] && git_flags="${git_flags}-${behind}"
    git_info=" $(printf '\ue0a0') ${branch}"
    [ -n "$git_flags" ] && git_info="${git_info} ${git_flags}"
  fi
fi

# ── Context usage ────────────────────────────────────────────────────────────
ctx_info=""
ctx_color=""
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")

  ctx_info=" context:${used_int}%"

  # Threshold-aware colour: green < 60, yellow < 85, pink >= 85
  if [ "$used_int" -ge 85 ]; then
    ctx_color='\033[38;2;237;135;150m' # red (maroon)
  elif [ "$used_int" -ge 60 ]; then
    ctx_color='\033[38;2;238;212;159m' # yellow
  else
    ctx_color='\033[38;2;166;218;149m' # green
  fi
fi

# ── Current session usage (Claude.ai subscription) ───────────────────────
session_info=""
session_color=""
if [ -n "$rl_5h" ]; then
  session_int=$(printf "%.0f" "$rl_5h")
  session_info=" session:${session_int}%"
  if [ "$session_int" -ge 85 ]; then
    session_color='\033[38;2;237;135;150m'
  elif [ "$session_int" -ge 60 ]; then
    session_color='\033[38;2;238;212;159m'
  else
    session_color='\033[38;2;166;218;149m'
  fi
fi

# Compose with ANSI colors (dimmed-friendly, no background blocks)
# Catppuccin Macchiato palette:
#   peach    #f5a97f  directory
#   yellow   #eed49f  git, warning ctx/session
#   lavender #b7bdf8  model
#   green    #a6da95  ctx/session ok
#   maroon   #ed8796  ctx/session critical
C_GIT='\033[38;2;238;212;159m'   # yellow
C_MODEL='\033[38;2;183;189;248m' # lavender
C_RESET='\033[0m'

[ -n "$git_info" ] && printf '%b%s%b' "$C_GIT" "$git_info" "$C_RESET"
[ -n "$model" ] && printf '%b  %s%b' "$C_MODEL" "$model" "$C_RESET"
[ -n "$ctx_info" ] && printf '%b%s%b' "$ctx_color" "$ctx_info" "$C_RESET"
[ -n "$session_info" ] && printf '%b%s%b' "$session_color" "$session_info" "$C_RESET"
printf '\n'
