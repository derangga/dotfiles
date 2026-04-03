{ config, lib, ... }:
lib.mkIf (config.terminal.use == "kitty") {
  programs.kitty = {
    enable = true;
    enableGitIntegration = true;
    font = {
      name = "JetBrainsMono Nerd Font";
    };
    settings = {
      modify_font = "cell_height 120%";
      macos_option_as_alt = "left";
      hide_window_decorations = "titlebar-only";
      background_opacity = "0.9";
      background_blur = 20;
      tab_bar_style = "powerline";
      tab_powerline_style = "round";
      tab_bar_min_tabs = 2;
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";
    };
    keybindings = {
      "shift+enter" = "send_text all \\x1b\\r";
    };
  };
}
