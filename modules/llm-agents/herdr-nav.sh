# herdr half of seamless ctrl+h/j/k/l navigation between nvim splits and herdr
# panes (the nvim half lives in modules/nixvim/plugins/extras.nix). Adapted from
# paulbkim-dev/vim-herdr-navigation's navigate.sh, minus its plugin manifest: a
# `type = "shell"` keybind gets the same environment, so there is nothing to
# `herdr plugin link`.
dir="${1:?usage: herdr-nav <left|down|up|right>}"
herdr="${HERDR_BIN_PATH:-herdr}"
# Shell keybinds get ACTIVE_; plugin actions and pane processes get the plain name.
pane="${HERDR_PANE_ID:-${HERDR_ACTIVE_PANE_ID:-}}"

case "$dir" in
  left) key="ctrl+h" ;;
  down) key="ctrl+j" ;;
  up) key="ctrl+k" ;;
  right) key="ctrl+l" ;;
  *)
    echo "herdr-nav: unknown direction: $dir" >&2
    exit 2
    ;;
esac

# Same matcher vim-tmux-navigator uses: vi, vim, nvim, view, gvim, *diff.
vim_re='^g?(view|l?n?vim?x?)(diff)?$'

if [ -n "$pane" ] && "$herdr" pane process-info --pane "$pane" 2>/dev/null |
  jq -e --arg vim "$vim_re" \
    '.result.process_info.foreground_processes[]?.name
     | ascii_downcase | select(test($vim))' >/dev/null 2>&1; then
  # Vim owns the pane: let it move its own splits. It calls back out to
  # `herdr pane focus` itself once it is already at an edge.
  exec "$herdr" pane send-keys "$pane" "$key"
elif [ -n "$pane" ]; then
  exec "$herdr" pane focus --direction "$dir" --pane "$pane"
else
  exec "$herdr" pane focus --direction "$dir" --current
fi
