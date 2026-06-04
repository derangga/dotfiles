{ config, lib, ... }:
let
  cfg = {
    enable = true;
    flavor = "macchiato"; # latte, frappe, macchiato, mocha
  };
in

{
  catppuccin.enable = true;
  catppuccin.autoEnable = false;

  catppuccin.bat = cfg;
  catppuccin.btop = cfg;
  catppuccin.fzf = cfg;
  catppuccin.gh-dash = cfg // {
    accent = "blue";
  };
  catppuccin.ghostty = lib.mkIf (config.terminal.use == "ghostty") cfg;
  catppuccin.kitty = lib.mkIf (config.terminal.use == "kitty") cfg;
  catppuccin.lazygit = cfg // {
    accent = "blue";
  };
  catppuccin.opencode = cfg;
  catppuccin.tmux = cfg // {
    extraConfig = ''
      # Configure Catppuccin
      set -g @catppuccin_status_background "none"
      set -g @catppuccin_window_status_style "none"
      set -g @catppuccin_pane_status_enabled "off"
      set -g @catppuccin_pane_border_status "off"

      # status left look and feel
      set -g status-left-length 100
      set -g status-left ""

      # status right look and feel
      set -g status-right-length 100
      set -g status-right ""
      set -ga status-right "#[fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"
      set -ga status-right "#[fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
      set -ga status-right "#[fg=#{@thm_maroon}]  #{pane_current_command} "
      set -ga status-right "#[fg=#{@thm_overlay_0},none]│"
      set -ga status-right "#[fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
      set -ga status-right "#[fg=#{@thm_overlay_0},none]│"
      set -ga status-right "#{?client_prefix,#{#[bg=#{@thm_blue},fg=#{@thm_bg},bold]  #[none,bg=#{@thm_bg},fg=#{@thm_bg}]#S },#{#[fg=#{@thm_green}]  #S }}"

      # Configure Tmux tab
      set -g status-position top
      set -g status-style "bg=#{@thm_bg}"
      set -g status-justify "left"

      # pane border look and feel
      setw -g pane-border-status top
      setw -g pane-border-format ""
      setw -g pane-active-border-style "bg=#{@thm_bg},fg=#{@thm_overlay_0}"
      setw -g pane-border-style "bg=#{@thm_bg},fg=#{@thm_surface_0}"
      setw -g pane-border-lines single

      # window look and feel
      set -wg automatic-rename on
      set -g automatic-rename-format "Window"

      set -g window-status-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-style "fg=#{@thm_rosewater}"
      set -g window-status-last-style "fg=#{@thm_peach}"
      set -g window-status-activity-style "bg=#{@thm_red},fg=#{@thm_bg}"
      set -g window-status-bell-style "bg=#{@thm_red},fg=#{@thm_bg},bold"
      set -gF window-status-separator "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}]│"

      set -g window-status-current-format " #I#{?#{!=:#{window_name},Window},: #W,} "
      set -g window-status-current-style "bg=#{@thm_peach},fg=#{@thm_bg},bold"
    '';
  };
  catppuccin.yazi = cfg // {
    accent = "blue";
  };
  catppuccin.zed = cfg // {
    accent = "blue";
    icons = cfg;
  };
  catppuccin.zsh-syntax-highlighting = cfg;

}
