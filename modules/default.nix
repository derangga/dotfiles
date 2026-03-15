{
  pkgs,
  hostname,
  username,
  ...
}:
{
  imports = [
    ./aerospace/config.nix
    ./catppuccin/config.nix
    ./ghostty/config.nix
    ./lazyvim/config.nix
    ./starship/config.nix
    ./sketchybar/config.nix
    ./hosts/${hostname}.nix
  ];

  programs.zsh = {
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
    };

    initContent = ''
      eval "$(fnm env --use-on-cd --shell zsh)"
    '';
  };

  programs.bat = {
    enable = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
    };
  };

  programs.eza = {
    colors = "always";
    enable = true;
    enableZshIntegration = true;
    icons = "always";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  programs.gh-dash = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    baseIndex = 1;
    clock24 = true;
    enable = true;
    customPaneNavigationAndResize = true;
    escapeTime = 10;
    focusEvents = true;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
  };

  programs.vscode = {
    enable = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  # llm tools
  programs.claude-code = {
    enable = true;
  };

  programs.opencode = {
    enable = true;
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
