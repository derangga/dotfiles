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

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    fff-nvim.url = "github:dmtrKovalenko/fff.nvim";
    fff-nvim.inputs.nixpkgs.follows = "nixpkgs";

    # LLM Tools
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    serena.url = "git+https://github.com/oraios/serena";
    serena.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self, ... }:
    let
      # Helper function to create configurations for different users
      mkDarwinConfig =
        {
          hostname,
          username,
          terminal,
        }:
        inputs.nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit
              self
              hostname
              username
              terminal
              ;
          };

          modules = [
            ./darwin/configuration.nix

            inputs.nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = username;
                autoMigrate = true;
              };
            }

            inputs.home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.extraSpecialArgs = {
                inherit hostname username terminal;
                inherit (inputs)
                  catppuccin
                  nixvim
                  fff-nvim
                  llm-agents
                  serena
                  ;
              };

              home-manager.users.${username} = import ./modules;
            }
          ];
        };
    in
    {
      darwinConfigurations."maclop" = mkDarwinConfig {
        hostname = "maclop";
        username = "derangga";
        terminal = "ghostty";
      };

      darwinConfigurations."worklop" = mkDarwinConfig {
        hostname = "worklop";
        username = "sociolla";
        terminal = "ghostty";
      };
    };
}
