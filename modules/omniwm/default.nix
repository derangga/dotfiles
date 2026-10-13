{ pkgs, lib, ... }:
{
  programs.omniwm = {
    enable = true;
    # ponytail: nixpkgs lags the releases (0.6.8 pinned, 0.7.6 current) and this
    # host runs a newer macOS than 0.6.8 was built for. Drop the override once
    # nixpkgs ships 0.7.6 or later.
    package = pkgs.omniwm.overrideAttrs rec {
      version = "0.7.6";
      src = pkgs.fetchurl {
        url = "https://github.com/OmniNull/OmniWM/releases/download/v${version}/OmniWM-v${version}.zip";
        hash = "sha256-7IxhRqbyGnnhxArHDWESF2K5PPU80wjmPrROis4g/Nw=";
      };
    };
    settings = import ./settings.nix { inherit lib; };
  };
}
