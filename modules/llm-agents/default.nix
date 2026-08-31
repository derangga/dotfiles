{
  pkgs,
  lib,
  fff-nvim,
  llm-agents,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  fffMcp = fff-nvim.packages.${system}.fff-mcp;
  llmPkgs = llm-agents.packages.${system};
  herdrToml = pkgs.formats.toml { };
  hunkToml = pkgs.formats.toml { };
  fffMcpBin = "${fffMcp}/bin/fff-mcp";
  codebaseMemoryMcp = pkgs.callPackage ./codebase-memory-mcp.nix { };

  herdrNav = pkgs.writeShellApplication {
    name = "herdr-nav";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./herdr-nav.sh;
  };

  navKey = dir: key: {
    inherit key;
    type = "shell";
    command = "${herdrNav}/bin/herdr-nav ${dir}";
    description = "navigate ${dir} (vim/herdr)";
  };
in
{
  home.packages = [
    codebaseMemoryMcp
    fffMcp
    llmPkgs.agent-browser
    llmPkgs.beads
    llmPkgs.beads-viewer
    llmPkgs.claude-code
    llmPkgs.herdr
    llmPkgs.hunk
    llmPkgs.opencode
    llmPkgs.rtk
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
      sidebar_min_width = 32;
    };
    keys = {
      rename_tab = "prefix+,";
      indexed = {
        workspaces = "ctrl+shift";
        tabs = "ctrl";
        agents = "alt";
      };
      command = [
        (navKey "left" "ctrl+h")
        (navKey "down" "ctrl+j")
        (navKey "up" "ctrl+k")
        (navKey "right" "ctrl+l")
      ];
    };
  };

  xdg.configFile."hunk/config.toml".source = hunkToml.generate "hunk-config" {
    agent_notes = true;
    theme = "catppuccin-macchiato";
    mode = "auto";
    vcs = "git";
  };

  # opencode config is static (never mutated at runtime, unlike ~/.claude.json),
  # so it can be managed declaratively as a symlink.
  xdg.configFile."opencode/opencode.jsonc".text = ''
    {
      "$schema": "https://opencode.ai/config.json",
      "lsp": true,
      "mcp": {
        "fff": {
          "type": "local",
          "command": ["${fffMcpBin}"],
          "enabled": true
        }
      }
    }
  '';

  xdg.configFile."opencode/AGENTS.md".text = ''
    For any file search or grep in the current git-indexed directory, use fff mcp tools instead of grep/glob.
  '';

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
