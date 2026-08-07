{
  pkgs,
  hostname,
  username,
  catppuccin,
  nixvim,
  ...
}:
{
  imports = [
    catppuccin.homeModules.catppuccin
    nixvim.homeModules.nixvim

    ./aerospace
    ./catppuccin
    ./ghost
    ./git
    ./llm-agents
    ./terminal
    ./nixvim
    ./presenterm
    ./starship/no-version.nix
    ./sketchybar/config.nix
    ./hosts/${hostname}.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    bun
    cargo
    fnm
    go
    orbstack
    rust-analyzer
    rustc
  ];

  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
      # keep Up as plain previous-command; atuin only owns Ctrl-R
      flags = [ "--disable-up-arrow" ];
      settings = {
        style = "compact";
        inline_height = 20;
        filter_mode = "global";
        search_mode = "fuzzy";
      };
    };

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

    vscode = {
      enable = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
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

      history = {
        ignoreAllDups = true;
        saveNoDups = true;
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
      };

      shellAliases = {
        drb = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
        drl = "sudo darwin-rebuild --list-generations";
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
