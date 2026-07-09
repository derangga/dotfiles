# Use this for default preset starship no symbol
{ ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    presets = [ "no-runtime-versions" ];
  };
}
