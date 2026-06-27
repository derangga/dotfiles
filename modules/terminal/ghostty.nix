{ config, lib, ... }:
lib.mkIf (config.terminal.use == "ghostty") {
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = null;
    settings = {
      background-opacity = 0.94;
      background-blur = true;
      bold-is-bright = true;
      custom-shader = [
        "shaders/cursor_blaze_no_trail.glsl"
      ];
      font-family = "Kode Mono";
      font-feature = "liga,calt,dlig";
      keybind = "shift+enter=text:\\x1b\\r";
      macos-option-as-alt = true;
      macos-window-shadow = false;
      macos-titlebar-style = "hidden";
      scrollbar = "never";
      window-padding-x = 8;
    };
  };

  xdg.configFile."ghostty/shaders".source = ./shaders;
}
