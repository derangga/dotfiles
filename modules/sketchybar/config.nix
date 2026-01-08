{ pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    config = {
      source = ./sketchybar-config;
      recursive = true;
    };
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;
    service.enable = true;
  };
}
