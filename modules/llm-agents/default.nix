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
  toml = pkgs.formats.toml { };
  fffMcpBin = "${fffMcp}/bin/fff-mcp";
  codebaseMemoryMcp = pkgs.callPackage ./codebase-memory-mcp.nix { };
  herdrReview = pkgs.callPackage ./herdr-review.nix { };
  # Only the binary goes on PATH, not the plugin tree with its README.md and manifest.
  herdrReviewBin = pkgs.runCommandLocal "herdr-review-bin" { } ''
    mkdir -p $out/bin
    ln -s ${herdrReview}/bin/herdr-review $out/bin/herdr-review
  '';

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

  pluginKey = plugin: key: command: description: {
    inherit key description;
    type = "plugin_action";
    command = "${plugin}.${command}";
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
    llmPkgs.rtk
    herdrReviewBin
  ];

  home.file.".agents/skills/herdr-review/SKILL.md".source =
    "${herdrReview}/skills/herdr-review/SKILL.md";

  home.activation.linkHerdrReview = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${llmPkgs.herdr}/bin/herdr plugin link ${herdrReview}
  '';

  xdg.configFile."herdr/config.toml".source = toml.generate "herdr-config" {
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
      sidebar_start_collapsed = true;
      sidebar_collapsed_mode = "hidden";
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
        (pluginKey "review" "prefix+i" "open" "review the diff")
        (pluginKey "review" "prefix+shift+i" "send" "send review comments to the agent")
        (pluginKey "review" "prefix+o" "message" "review the agent's last message")
      ];
    };
  };

  # Claude Code mutates ~/.claude.json at runtime, so it can't be a managed
  # symlink; patch the fff MCP entry in place on each activation instead.
  home.activation.configureFffMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    patch_fff() {
      claudeJson="$1"
      [ -f "$claudeJson" ] || [[ -v DRY_RUN ]] || echo '{}' > "$claudeJson"
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
    line="For any file search or grep in the current git-indexed directory, use fff mcp tools."
    patch_md() {
      claudeMd="$1/CLAUDE.md"
      $DRY_RUN_CMD mkdir -p "$1"
      $DRY_RUN_CMD touch "$claudeMd"
      ${pkgs.gnugrep}/bin/grep -qF "$line" "$claudeMd" 2>/dev/null || [[ -v DRY_RUN ]] || \
        printf '\n%s\n' "$line" >> "$claudeMd"
    }
    patch_md "$HOME/.claude"
    [ -d "$HOME/.claude-work" ] && patch_md "$HOME/.claude-work"
  '';
}
