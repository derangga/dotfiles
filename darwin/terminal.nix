{ lib, config, ... }:
{
  options = import ../modules/terminal/options.nix { inherit lib; };

  config = lib.mkMerge [
    (lib.mkIf (config.terminal.use == "kitty") {
      homebrew.casks = [ "kitty" ];
    })
    (lib.mkIf (config.terminal.use == "ghostty") {
      homebrew.casks = [ "ghostty" ];
    })
  ];
}
