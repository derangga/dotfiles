{ ... }:

{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    package = null;
    settings = {
      theme = "Catppuccin Macchiato";
      macos-option-as-alt = true;
      macos-window-shadow = false;
      macos-titlebar-style = "hidden";
      background-opacity = 0.9;
      background-blur = true;
      keybind = "shift+enter=text:\\x1b\\r";
      scrollbar = "never";
    };
  };

  xdg.configFile."ghostty/shaders".source = ./shaders;
}
