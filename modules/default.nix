{
  hostname,
  username,
  ...
}:
{
  imports = [
    ./aerospace/config.nix
    ./lazyvim/config.nix
    ./starship/config.nix
    (import ./zsh/config.nix { inherit hostname username; })
  ];
}
