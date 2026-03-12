{ ... }:
{
  # General homebrew configuration shared across all hosts
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    brews = [
      "golang-migrate"
      "mole"
    ];

    casks = [
      "sf-symbols"
      "font-sf-mono"
      "font-sf-pro"
      "ghostty"
    ];
  };
}
