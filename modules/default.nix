{
  pkgs,
  hostname,
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
  ];

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
      enableFishIntegration = true;
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
      enableFishIntegration = true;
      icons = "always";
    };

    fish = {
      enable = true;

      shellAbbrs = {
        drb = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
        drl = "sudo darwin-rebuild --list-generations";
        ngc = "nix-collect-garbage -d";
        agstart = "brew services start aerogesture";
        agstop = "brew services stop aerogesture";
        agrestart = "brew services restart aerogesture";
      };

      # lg is deliberately absent: programs.lazygit's fish integration defines
      # it as a function that cds to lazygit's exit directory.
      interactiveShellInit = ''
        set -g fish_greeting
        fnm env --use-on-cd --shell fish | source
      '';
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
      enableFishIntegration = true;
    };

    # fish turns this on to back `man` completions with apropos, but
    # home.stateVersion 26.05 leaves programs.man.package null on darwin, so
    # there is no mandb to build the cache and the option only warns.
    man.generateCaches = false;

    tmux = {
      baseIndex = 1;
      clock24 = true;
      enable = true;
      customPaneNavigationAndResize = true;
      escapeTime = 10;
      terminal = "tmux-256color";
      extraConfig = ''
        # enable extended keys (CSI encoding) for proper modifier support
        # allows shift+enter, ctrl+shift+<key>, etc. to work correctly in apps
        # also this config fix opencode behavior inside tmux
        set -s extended-keys on
        set -as terminal-features "xterm*:extkeys"

        # truecolor passthrough: outer TERM is xterm-ghostty / xterm-kitty
        set -as terminal-features "xterm*:RGB"
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
      enableFishIntegration = true;
      shellWrapperName = "y";
    };

    zed-editor = {
      enable = true;
      package = null;
      userSettings = {
        buffer_font_family = "JetBrainsMono Nerd Font Mono";
        terminal = {
          font_family = "JetBrainsMono Nerd Font Mono";
        };
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      # replacing cd with zoxide
      options = [ "--cmd cd" ];
    };
  };

  services.jankyborders = {
    enable = true;
    settings = {
      style = "round";
      width = 4.0;
      active_color = "0xff7dc4e4";
      inactive_color = "0xffcad3f5";
    };
  };
}
