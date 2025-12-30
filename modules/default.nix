{
  pkgs,
  hostname,
  username,
  ...
}:
{
  imports = [
    ./aerospace/config.nix
    ./lazyvim/config.nix
    ./starship/config.nix
    ./extras/${username}.nix
  ];

  home.packages = [
    pkgs.dbeaver-bin
  ];

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
}
