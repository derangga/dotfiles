{ config, lib, ... }:
let
  cfg = {
    enable = true;
    flavor = "macchiato"; # latte, frappe, macchiato, mocha
  };
in

{
  catppuccin.bat = cfg;
  catppuccin.btop = cfg;
  catppuccin.fzf = cfg;
  catppuccin.gh-dash = cfg // {
    accent = "blue";
  };
  catppuccin.ghostty = cfg;
  catppuccin.kitty = lib.mkIf (config.terminal.use == "kitty") cfg;
  catppuccin.lazygit = cfg // {
    accent = "blue";
  };
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
      set -ga status-left "#{?client_prefix,#{#[bg=#{@thm_blue},fg=#{@thm_bg},bold]  #[none,bg=#{@thm_bg},fg=#{@thm_bg}]#S },#{#[fg=#{@thm_green}]  #S }}"
      set -ga status-left "#[fg=#{@thm_overlay_0},none]│"
      set -ga status-left "#[fg=#{@thm_maroon}]  #{pane_current_command} "
      set -ga status-left "#[fg=#{@thm_overlay_0},none]│"
      set -ga status-left "#[fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
      set -ga status-left "#[fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
      set -ga status-left "#[fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"

      # status right look and feel
      set -g status-right-length 100
      set -g status-right ""
      set -ga status-right "#[fg=#{@thm_blue}] 󰔟 #[fg=@thm_blue]#{E:@catppuccin_uptime_text}#[fg=@thm_blue]"
      set -ga status-right " "

      # Configure Tmux
      set -g status-position top
      set -g status-style "bg=#{@thm_bg}"
      set -g status-justify "absolute-centre"

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
