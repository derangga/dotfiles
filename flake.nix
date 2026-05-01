{
  description = "derangga nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      home-manager,
      catppuccin,
    }:
    let
      # Helper function to create configurations for different users
      mkDarwinConfig =
        { hostname, username }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit self hostname username; };

          modules = [
            ./darwin/configuration.nix

            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = username;
                autoMigrate = true;
              };
            }

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = {
                inherit hostname username catppuccin;
                modulesDir = ./modules;
              };

              home-manager.users.${username} = import ./home/home.nix;
            }
          ];
        };
    in
    {
      darwinConfigurations."maclop" = mkDarwinConfig {
        hostname = "maclop";
        username = "derangga";
      };

      darwinConfigurations."worklop" = mkDarwinConfig {
        hostname = "worklop";
        username = "sociolla";
      };

    };
}
