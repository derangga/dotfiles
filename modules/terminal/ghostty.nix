{ config, lib, ... }:
lib.mkIf (config.terminal.use == "ghostty") {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = null;
    settings = {
      background-opacity = 0.9;
      background-blur = true;
      custom-shader = [
        "shaders/cursor_blaze_no_trail.glsl"
      ];
      font-family = "JetBrainsMono Nerd Font Mono";
      font-feature = "JetBrainsMono Nerd Font Mono";
      keybind = "shift+enter=text:\\x1b\\r";
      macos-option-as-alt = true;
      macos-window-shadow = false;
      macos-titlebar-style = "hidden";
      scrollbar = "never";
    };
  };

  xdg.configFile."ghostty/shaders".source = ./shaders;
}
