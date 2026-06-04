{
  pkgs,
  hostname,
  ...
}:
{
  imports = [
    ./aerospace/config.nix
    ./catppuccin/config.nix
    ./git/config.nix
    ./llm-agents
    ./terminal
    ./nixvim
    ./presenterm/config.nix
    ./starship/nosymbol.nix
    ./sketchybar/config.nix
    ./hosts/${hostname}.nix
  ];

  home.packages = with pkgs; [
    orbstack
  ];

  programs = {
    bat = {
      enable = true;
    };

    btop = {
      enable = true;
      settings = {
        theme_background = false;
      };
    };

    eza = {
      colors = "always";
      enable = true;
      enableZshIntegration = true;
      icons = "always";
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
      };
    };

    gh-dash = {
      enable = true;
    };

    lazygit = {
      enable = true;
      enableZshIntegration = true;
    };

    tmux = {
      baseIndex = 1;
      clock24 = true;
      enable = true;
      customPaneNavigationAndResize = true;
      escapeTime = 10;
      extraConfig = ''
        # enable extended keys (CSI encoding) for proper modifier support
        # allows shift+enter, ctrl+shift+<key>, etc. to work correctly in apps
        # also this config fix opencode behavior inside tmux
        set -s extended-keys on
        set -as terminal-features "xterm*:extkeys"
      '';
      focusEvents = true;
      keyMode = "vi";
      mouse = true;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
      ];
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };

    zed-editor = {
      enable = true;
      package = null;
      userSettings = {
        auto_install_extensions = {
          html = true;
          nix = true;
          tailwind = true;
          vue = true;
        };
        buffer_font_family = "JetBrainsMono Nerd Font Mono";
        terminal = {
          font_family = "JetBrainsMono Nerd Font Mono";
        };
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      # replacing cd with zoxide
      options = [ "--cmd cd" ];
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "fzf"
        ];
      };

      shellAliases = {
        drb = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
        ngc = "nix-collect-garbage -d";
        lg = "lazygit";
        agstart = "brew services start aerogesture";
        agstop = "brew services stop aerogesture";
        agrestart = "brew services restart aerogesture";
      };

      initContent = ''
        eval "$(fnm env --use-on-cd --shell zsh)"
      '';
    };

  };

  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 6.0;
      active_color = "0xff7dc4e4";
      inactive_color = "0xffcad3f5";
    };
  };
}
