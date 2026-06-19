{
  pkgs,
  fff-nvim,
  llm-agents,
  serena,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  fffMcp = fff-nvim.packages.${system}.fff-mcp;
  llmPkgs = llm-agents.packages.${system};
  serenaPkgs = serena.packages.${system};
  herdrToml = pkgs.formats.toml { };
in
{
  home.packages = [
    fffMcp
    llmPkgs.beads
    llmPkgs.beads-viewer
    llmPkgs.claude-code
    llmPkgs.gitnexus
    llmPkgs.herdr
    llmPkgs.opencode
    llmPkgs.rtk
    serenaPkgs.default
  ];

  xdg.configFile."herdr/config.toml".source = herdrToml.generate "herdr-config" {
    onboarding = false;
    theme.name = "catppuccin";
    ui.toast.delivery = "terminal";
    keys = {
      rename_tab = "prefix+,";
      indexed = {
        workspaces = "ctrl+shift";
        tabs = "ctrl";
        agents = "alt";
      };
    };
  };
}
