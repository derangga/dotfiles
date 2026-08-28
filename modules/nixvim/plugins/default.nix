{ ... }:

{
  imports = [
    ./snacks.nix
    ./catppuccin.nix
    # ./tokyonight.nix # enable to switch to Tokyo Night (disable ./catppuccin.nix above)
    ./treesitter.nix
    ./lsp.nix
    ./formatting.nix
    ./linting.nix
    ./ui.nix
    ./editor.nix
    ./explorer.nix
    ./coding.nix
    ./extras.nix
    ./git.nix
    ./finder.nix
    ./ai.nix
    ./dap.nix
    ./flutter.nix
    ./completion.nix
  ];
}
