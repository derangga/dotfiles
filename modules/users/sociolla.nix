{
  pkgs,
  hostname,
  ...
}:
{
  home.packages = with pkgs; [
    pm2
    pyenv
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
      vim = "nvim";
    };

    initContent = ''
      export EDITOR=nvim

      eval "$(fnm env --use-on-cd --shell zsh)"

      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"
    '';
  };

}
