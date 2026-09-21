{
  description = "derangga nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    den.url = "github:denful/den/v0.18.0";

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

    herdr-annotate = {
      url = "github:plannotator/herdr-annotate";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      den =
        (inputs.nixpkgs.lib.evalModules {
          modules = [ ./den.nix ];
          specialArgs.inputs = inputs;
        }).config;
    in
    {
      inherit (den.flake) darwinConfigurations;
    };
}
