{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    pm2
    yaak
  ];

  # Second Claude account (work) in its own config dir; merges into the
  # shared zsh aliases from ../default.nix.
  programs.zsh.shellAliases.claude-work = "CLAUDE_CONFIG_DIR=~/.claude-work claude";
}
