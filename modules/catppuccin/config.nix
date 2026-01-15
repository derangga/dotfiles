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
}
