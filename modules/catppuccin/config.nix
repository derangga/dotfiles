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
  catppuccin.yazi = {
    accent = "blue";
    enable = true;
    flavor = "macchiato";
  };
  catppuccin.zellij = config;
}
