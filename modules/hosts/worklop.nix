{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    pm2
    pyenv
  ];

  programs.zsh.initContent = ''
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
  '';
}
