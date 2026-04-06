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
      enabled_layouts = "splits";
    };
    keybindings = {
      "shift+enter" = "send_text all \\x1b\\r";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      "cmd+d" = "launch --location=vsplit --cwd=current";
      "cmd+shift+d" = "launch --location=hsplit --cwd=current";
      "cmd+w" = "close_window";
    };
  };
}
