{
  pkgs,
  llm-agents,
  serena,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  llmPkgs = llm-agents.packages.${system};
  serenaPkgs = serena.packages.${system};
  herdrToml = pkgs.formats.toml { };
in
{
  home.packages = [
    llmPkgs.beads
    llmPkgs.claude-code
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
      prefix = "ctrl+b";
      new_workspace = "n";
      rename_workspace = "shift+n";
      close_workspace = "shift+d";
      new_tab = "c";
      rename_tab = ",";
      close_tab = "shift+w";
      split_vertical = "v";
      split_horizontal = "-";
      close_pane = "x";
      zoom = "z";
      indexed = {
        workspaces = "ctrl+shift";
        tabs = "ctrl";
        agents = "alt";
      };
    };
  };
}
