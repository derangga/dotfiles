{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    pm2
    yaak
  ];

  # Second Claude account (work) in its own config dir. A function, not an
  # abbreviation: abbrs only expand while typing in an interactive shell.
  programs.fish.functions.claude-work = "CLAUDE_CONFIG_DIR=$HOME/.claude-work claude $argv";
}
