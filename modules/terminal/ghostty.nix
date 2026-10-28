{
  config,
  terminal,
  lib,
  ...
}:
lib.mkIf (terminal == "ghostty") {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    package = null;
    settings = {
      background-opacity = 0.94;
      background-blur = true;
      bold-is-bright = true;
      # Optional include (?) of the runtime fragment ghost-watch rewrites; absent
      # or empty means no face and no custom shader.
      config-file = "?${config.home.homeDirectory}/.local/state/ghost-in-the-machine/ghostty.conf";
      font-family = "Kode Mono";
      font-feature = "liga,calt,dlig";
      macos-option-as-alt = true;
      macos-window-shadow = false;
      macos-titlebar-style = "hidden";
      scrollbar = "never";
      window-padding-x = 8;
    };
  };

  xdg.configFile."ghostty/shaders".source = ./shaders;
}
