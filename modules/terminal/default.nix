{ lib, ... }:
{
  imports = [
    ./kitty.nix
    ./ghostty.nix
  ];

  options = import ./options.nix { inherit lib; };
}
