{ pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    config = {
      source = ./lua;
      recursive = true;
    };
    configType = "lua";
    extraPackages = with pkgs; [
      aerospace
      jq
      switchaudio-osx
    ];
    sbarLuaPackage = pkgs.sbarlua;
    service.enable = true;
  };
}
