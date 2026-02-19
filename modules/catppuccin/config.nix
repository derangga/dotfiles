{ ... }:
let
  config = {
    enable = true;
    flavor = "macchiato";
  };
in

{
  catppuccin.bat = config;
  catppuccin.btop = config;
  catppuccin.fzf = config;
  catppuccin.lazygit = config;
  catppuccin.opencode = config;
  catppuccin.tmux = {
    enable = true;
    flavor = "macchiato";
    extraConfig = ''
      # Window (tab) style - options: rounded, slanted, basic, none
      set -g @catppuccin_window_status_style "rounded"

      # Active/inactive window styles
      set -g @catppuccin_window_text " #W"
      set -g @catppuccin_window_current_text " #W"

      # Status bar
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""

      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"
    '';
  };
  catppuccin.yazi = {
    accent = "blue";
    enable = true;
    flavor = "macchiato";
  };
}
