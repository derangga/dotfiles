# Use this for default preset starship no symbol
{ ... }:
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    presets = [ "no-runtime-versions" ];
  };
}
