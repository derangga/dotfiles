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
  hunkToml = pkgs.formats.toml { };
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
    llmPkgs.hunk
    llmPkgs.opencode
    llmPkgs.rtk
    serenaPkgs.default
  ];

  xdg.configFile."herdr/config.toml".source = herdrToml.generate "herdr-config" {
    onboarding = false;
    theme.name = "catppuccin";
    ui = {
      toast.delivery = "terminal";
      sidebar = {
        agents.rows = [
          [
            "state_icon"
            "workspace"
          ]
          [
            "state_text"
            "agent"
          ]
        ];
      };
      sidebar_min_width = 24;
    };
    keys = {
      rename_tab = "prefix+,";
      indexed = {
        workspaces = "ctrl+shift";
        tabs = "ctrl";
        agents = "alt";
      };
    };
  };

  xdg.configFile."hunk/config.toml".source = hunkToml.generate "hunk-config" {
    agent_notes = true;
    theme = "catppuccin-macchiato";
    mode = "auto";
    vcs = "git";
  };

  # Claude Code mutates ~/.claude.json at runtime, so it can't be a managed
  # symlink; patch the fff MCP entry in place on each activation instead.
  home.activation.configureFffMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    patch_fff() {
      claudeJson="$1"
      [ -f "$claudeJson" ] || echo '{}' > "$claudeJson"
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq \
        '.mcpServers.fff = {type: "stdio", command: "${fffMcpBin}", args: []}' \
        "$claudeJson" > "$tmp" && $DRY_RUN_CMD mv "$tmp" "$claudeJson"
    }
    patch_fff "$HOME/.claude.json"
    # Second account (work) lives in its own config dir; patch it only if set up.
    [ -d "$HOME/.claude-work" ] && patch_fff "$HOME/.claude-work/.claude.json"
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
