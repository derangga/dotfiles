{ pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    config = {
      source = ./sketchybar-config;
      recursive = true;
    };
    configType = "lua";
    extraPackages = with pkgs; [
      jq
      switchaudio-osx
    ];
    sbarLuaPackage = pkgs.sbarlua;
    service.enable = true;
  };
}
