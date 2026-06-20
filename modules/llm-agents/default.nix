{
  pkgs,
  lib,
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
  fffMcpBin = "${fffMcp}/bin/fff-mcp";
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

  # Claude Code mutates ~/.claude.json at runtime, so it can't be a managed
  # symlink; patch the fff MCP entry in place on each activation instead.
  home.activation.configureFffMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    claudeJson="$HOME/.claude.json"
    [ -f "$claudeJson" ] || echo '{}' > "$claudeJson"
    tmp=$(mktemp)
    ${pkgs.jq}/bin/jq \
      '.mcpServers.fff = {type: "stdio", command: "${fffMcpBin}", args: []}' \
      "$claudeJson" > "$tmp" && $DRY_RUN_CMD mv "$tmp" "$claudeJson"
  '';

  # Append the fff usage instruction to the global CLAUDE.md if not already set,
  # preserving the existing content (e.g. the @RTK.md include).
  home.activation.configureFffClaudeMd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    claudeMd="$HOME/.claude/CLAUDE.md"
    line="For any file search or grep in the current git-indexed directory, use fff mcp tools."
    $DRY_RUN_CMD mkdir -p "$(dirname "$claudeMd")"
    touch "$claudeMd"
    ${pkgs.gnugrep}/bin/grep -qF "$line" "$claudeMd" || \
      printf '\n%s\n' "$line" >> "$claudeMd"
  '';
}
