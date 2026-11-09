{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.omniwm = {
    enable = true;
    # ponytail: nixpkgs lags the releases (0.6.8 pinned, 0.8.0 current) and this
    # host runs a newer macOS than 0.6.8 was built for. Drop the override once
    # nixpkgs ships 0.8.0 or later.
    package = pkgs.omniwm.overrideAttrs rec {
      version = "0.8.0";
      src = pkgs.fetchurl {
        url = "https://github.com/OmniNull/OmniWM/releases/download/v${version}/OmniWM-v${version}.zip";
        hash = "sha256-b3+z4hHeOoPncrExgAaAyz0g1MY4gRofAhIP0iXwPMc=";
      };
    };
    settings = import ./settings.nix { inherit lib; };
  };

  # Since 0.8.0 OmniWM writes through symlinks instead of replacing them, so a
  # link into the store blocks every save. Install writable copies instead; each
  # switch still overwrites them, so Settings window changes last until then.
  xdg.configFile."omniwm/settings.toml".enable = lib.mkForce false;
  home.activation.omniwmSettings =
    let
      toml = (pkgs.formats.toml { }).generate;
      dir = "${config.xdg.configHome}/omniwm";
      settings = toml "omniwm-settings.toml" config.programs.omniwm.settings;
      shell = toml "omniwm-shell.toml" (import ./shell.nix);
    in
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run rm -f "${dir}/settings.toml" "${dir}/shell/shell.toml"
      run install -D -m 644 ${settings} "${dir}/settings.toml"
      run install -D -m 644 ${shell} "${dir}/shell/shell.toml"
      run rm -rf "${dir}/shell/wayline"
    '';
}
