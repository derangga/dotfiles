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
      "golang-migrate"
      "mole"
      "derangga/formulae/aerogesture"
      "derangga/formulae/phunter"
    ];

    casks = [
      "cloudflare-warp"
      "sf-symbols"
      "font-sf-mono"
      "font-sf-pro"
      "tailscale-app"
      "zed"
    ];
  };
}
