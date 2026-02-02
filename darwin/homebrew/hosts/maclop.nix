{ pkgs, ... }:
{
  # Homebrew packages specific to maclop (derangga)
  homebrew = {
    taps = [ ];
    brews = [
      "mole"
    ];
    casks = [ ];
  };
}
