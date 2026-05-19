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
in
{
  home.packages = [
    llmPkgs.claude-code
    llmPkgs.opencode
    llmPkgs.beads
    llmPkgs.rtk
    serenaPkgs.default
  ];
}
