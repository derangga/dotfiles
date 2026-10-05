{ pkgs, lib, ... }:
let
  helpers = pkgs.stdenv.mkDerivation {
    pname = "sketchybar-helpers";
    version = "0";

    src = lib.fileset.toSource {
      root = ./lua/helpers;
      fileset = lib.fileset.fileFilter (
        file: file.hasExt "c" || file.hasExt "h" || file.name == "makefile"
      ) ./lua/helpers;
    };

    # event_providers/makefile skips memory_load, so build each directory itself.
    buildPhase = ''
      runHook preBuild
      for dir in event_providers/*_load menus; do
        make -C "$dir"
      done
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      for bin in event_providers/*_load/bin/* menus/bin/*; do
        install -Dm755 "$bin" "$out/$bin"
      done
      runHook postInstall
    '';
  };
in
{
  xdg.configFile."sketchybar/helpers" = {
    source = helpers;
    recursive = true;
  };

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
