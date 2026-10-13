{ ... }:
{
  # General homebrew configuration shared across all hosts
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    taps = [
      "derangga/formulae"
    ];

    brews = [
      "mole"
      "derangga/formulae/phunter"
    ];

    casks = [
      "cloudflare-warp"
      "sf-symbols"
      "font-sf-mono"
      "font-sf-pro"
      "zed"
    ];
  };
}
