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
        {
          hostname,
          username,
          extraHomePackages ? [ ],
        }:
        let
          configuration =
            { pkgs, config, ... }:
            {
              system.primaryUser = username;
              nixpkgs.config.allowUnfree = true;

              environment.systemPackages = [
                pkgs.android-tools
                pkgs.bun
                pkgs.btop
                pkgs.colima
                pkgs.docker
                pkgs.docker-compose
                pkgs.fd
                pkgs.fnm
                pkgs.ffmpeg
                pkgs.gcc
                pkgs.gnupg
                pkgs.go
                pkgs.git
                pkgs.jq
                pkgs.javaPackages.compiler.openjdk17
                pkgs.lua
                pkgs.mkalias
                pkgs.nixfmt
                pkgs.pnpm
                pkgs.ripgrep
                pkgs.rbenv
              ];

              fonts.packages = [
                pkgs.nerd-fonts.jetbrains-mono
              ];

              users.users.${username} = {
                name = username;
                home = "/Users/${username}";
              };

              homebrew = {
                enable = true;
                onActivation.cleanup = "zap";
                casks = [
                  # Add casks here
                  # "sf-symbols"
                  # "font-sf-mono"
                  # "font-sf-pro"
                  "ghostty"
                ];
              };

              system.activationScripts.applications.text =
                let
                  env = pkgs.buildEnv {
                    name = "system-applications";
                    paths = config.environment.systemPackages;
                    pathsToLink = [ "/Applications" ];
                  };
                in
                pkgs.lib.mkForce ''
                  # Set up applications
                  echo "setting up /Applications..." >&2
                  rm -rf /Applications/Nix\ Apps/
                  mkdir -p /Applications/Nix\ Apps/
                  find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
                  while read -r src; do
                    app_name=$(basename "$src")
                    echo "copying $src" >&2
                    ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix\ Apps/$app_name"
                  done
                '';

              nix.settings.experimental-features = "nix-command flakes";
              system.configurationRevision = self.rev or self.dirtyRev or null;
              system.stateVersion = 6;
              nixpkgs.hostPlatform = "aarch64-darwin";
            };
        in
        nix-darwin.lib.darwinSystem {
          modules = [
            configuration
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
              home-manager.users.${username} =
                { pkgs, ... }:
                {
                  imports = [
                    catppuccin.homeModules.catppuccin
                    (import ./config { inherit hostname username; })
                  ];

                  home.stateVersion = "25.11";
                  home.username = username;
                  home.homeDirectory = "/Users/${username}";

                  home.packages = [
                    pkgs.dbeaver-bin
                  ]
                  ++ (extraHomePackages pkgs);

                  programs.btop = {
                    enable = true;
                    settings = {
                      theme_background = false;
                    };
                  };
                  catppuccin.btop = {
                    enable = true;
                    flavor = "macchiato";
                  };

                  programs.eza = {
                    enable = true;
                    enableZshIntegration = true;
                    icons = "always";
                  };

                  programs.fzf = {
                    enable = true;
                    enableZshIntegration = true;
                  };
                  catppuccin.fzf = {
                    enable = true;
                    flavor = "macchiato";
                  };

                  programs.lazygit = {
                    enable = true;
                    enableZshIntegration = true;
                  };
                  catppuccin.lazygit = {
                    enable = true;
                    flavor = "macchiato";
                  };

                  programs.vscode = {
                    enable = true;
                  };

                  programs.yazi = {
                    enable = true;
                    enableZshIntegration = true;
                    shellWrapperName = "y";
                  };
                  catppuccin.yazi = {
                    enable = true;
                    flavor = "macchiato";
                  };
                };
            }
          ];
        };
    in
    {
      # Personal laptop configuration
      darwinConfigurations."maclop" = mkDarwinConfig {
        hostname = "maclop";
        username = "derangga";
        extraHomePackages = (
          pkgs: [
            pkgs.cloudflared
          ]
        );
      };

      # Work laptop configuration
      darwinConfigurations."worklop" = mkDarwinConfig {
        hostname = "worklop";
        username = "sociolla";
        extraHomePackages = (
          pkgs: [
            pkgs.pm2
            pkgs.pyenv
          ]
        );
      };

      # Default package output for personal laptop
      darwinPackages = self.darwinConfigurations."maclop".pkgs;
    };
}
