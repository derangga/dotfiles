{ pkgs, ... }:
{
  # General homebrew configuration shared across all hosts
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    taps = [ ];

    brews = [ ];

    casks = [
      "sf-symbols"
      "font-sf-mono"
      "font-sf-pro"
      "ghostty"
    ];
  };
}
