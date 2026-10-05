{
  inputs,
  den,
  lib,
  ...
}:
let
  # den calls instantiate with { modules = [ ... ]; } and nothing else, so the
  # specialArgs mkDarwinConfig used to pass have to be re-added here. Doing it
  # this way also sidesteps den defaulting the darwin builder to
  # `inputs.darwin`, which this flake calls `nix-darwin`.
  mkDarwin =
    {
      hostname,
      username,
      terminal,
    }:
    args:
    inputs.nix-darwin.lib.darwinSystem (
      args
      // {
        specialArgs = {
          inherit (inputs) self;
          inherit hostname username terminal;
        };
      }
    );

  # The host attrs and the instantiate call take their values from here, since
  # instantiate cannot read the host entity it belongs to.
  mkHost =
    hostname:
    {
      username,
      terminal ? "ghostty",
    }:
    {
      inherit terminal;
      users.${username} = { };
      instantiate = mkDarwin { inherit hostname username terminal; };
    };
in
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.schema.host.includes = [
    {
      darwin.imports = [
        ./darwin/configuration.nix
        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
    }

    # useGlobalPkgs and useUserPackages default to false in den; mkDarwinConfig
    # set both. Without them home-manager builds its own nixpkgs and
    # nixpkgs.config.allowUnfree stops reaching it, silently.
    # ponytail: one extraSpecialArgs set per host, correct while each host has
    # exactly one home-manager user. Route per-user if that changes.
    (
      { host, user, ... }:
      {
        name = "host-wiring";
        darwin = {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = user.userName;
            autoMigrate = true;
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              inherit (inputs)
                catppuccin
                nixvim
                fff-nvim
                herdr-annotate
                llm-agents
                ;
              hostname = host.name;
              inherit (host) terminal;
            };
          };
        };
      }
    )
  ];

  den.schema.user.includes = [
    { homeManager.imports = [ ./modules ]; }
  ];

  den.hosts.aarch64-darwin = lib.mapAttrs mkHost {
    maclop.username = "derangga";
    worklop.username = "sociolla";
  };

  den.aspects.derangga = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    darwin.homebrew.casks = [ "obs" ];

    homeManager =
      { pkgs, ... }:
      {
        catppuccin.obs.enable = true;

        programs.vscode = {
          enable = true;
        };

        home.packages = with pkgs; [
          dbeaver-bin
        ];
      };
  };

  den.aspects.sociolla = {
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          pm2
          yaak
        ];

        # Second Claude account (work) in its own config dir. A function, not an
        # abbreviation: abbrs only expand while typing in an interactive shell.
        programs.fish.functions.claude-work = "CLAUDE_CONFIG_DIR=$HOME/.claude-work claude $argv";
      };
  };
}
