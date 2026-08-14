<div align="center">

# My Nix Configs ❄️

</div>

<div align="center"><img src="screenshots/new-setup.png" height="500px"/></div>

## Motivation

Setting up a new laptop from scratch can be an incredibly time-consuming and tedious process. Installing all your favorite tools, configuring your environment, tweaking settings to your preferences, and ensuring everything works together seamlessly often takes hours or even days. Even worse, you have to repeat this painful process every time you get a new machine or need to restore your system.

This is where Nix Darwin comes to the rescue. My motivation for adopting Nix Darwin is simple: eliminate the repetitive burden of manual system configuration. With Nix, I can define my entire system setup in code once, and then deploy it consistently across all my devices. Whether I'm setting up a new MacBook or recovering from a system failure, I can have my perfect development environment up and running in minutes, not hours. One configuration to rule them all.

## What is Nix?

Nix is a powerful package manager and system configuration tool that takes a unique approach to software management. Unlike traditional package managers, Nix treats packages as immutable building blocks and uses a functional approach to system configuration.

### Key Benefits

- **Reproducibility**: Your system configuration produces the same results every time, eliminating "works on my machine" problems.
- **Declarative Configuration**: Declare what your system should look like in configuration files, and Nix handles the rest.
- **Atomic Updates and Rollbacks**: System changes either fully succeed or fail. Roll back to previous configurations instantly if needed.
- **Isolation**: Packages are installed in isolation, preventing dependency conflicts. Multiple versions can coexist peacefully.
- **Cross-Machine Consistency**: Use the same configuration across multiple machines for identical setups everywhere.

By leveraging Nix Darwin for macOS, I get all these benefits while maintaining a native Mac experience.

## Structure

`flake.nix` builds one configuration per host. System level settings live under `darwin/`, and everything user level is home-manager config under `modules/`, with `modules/default.nix` as the entry point that the flake imports directly. Per host overrides live in `modules/hosts/{hostname}.nix`.

```mermaid
flowchart TD
    flake["flake.nix<br/>mkDarwinConfig per host"]
    flake --> darwin["darwin/configuration.nix<br/>system level"]
    flake --> hm["home-manager"]
    darwin --> brew["darwin/homebrew<br/>casks and brews per host"]
    hm --> modules["modules/default.nix<br/>home-manager entry point"]
    modules --> apps["per app modules<br/>terminal, git, aerospace, catppuccin, starship, ..."]
    modules --> host["modules/hosts/{hostname}.nix<br/>host specific overrides"]
```

## What's Inside (Home Manager)

All the following applications are managed via home-manager and will be configured automatically on rebuild.

### Shell & Terminal
| Application | Description |
|---|---|
| Zsh + Oh My Zsh | Shell with git plugin; Atuin powers history search (Ctrl-R) |
| Starship | Cross-shell prompt |
| Kitty | GPU-accelerated terminal |
| Ghostty | Fast terminal emulator |

Kitty and Ghostty are both configured, but only one is active per host. The choice is a single `terminal` field in `flake.nix` (see the Configuration section) that drives both the Homebrew cask and the program config, so the two never drift apart.

### Development Tools
| Application | Description |
|---|---|
| Neovim (LazyVim) | Text editor with LazyVim config |
| Git | Version control |
| Lazygit | Terminal UI for Git |
| tmux | Terminal multiplexer |
| Zed | Modern, high-performance code editor |

### AI / Agentic Tools
Sourced from the [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix) flake input (see `modules/llm-agents/default.nix`).

| Application | Description |
|---|---|
| Claude Code | Agentic coding tool from Anthropic |
| OpenCode | AI coding assistant |
| Beads | Issue/task tracker for AI coding agents |
| RTK | Rust Token Killer, a token-optimizing CLI proxy |
| codebase-memory-mcp | MCP server indexing a repo into a code knowledge graph |

### CLI Utilities
| Application | Description |
|---|---|
| atuin | Shell history search (SQLite-backed, Ctrl-R) |
| bat | `cat` clone with syntax highlighting |
| btop | Resource monitor |
| eza | Modern `ls` replacement |
| yazi | Terminal file manager |
| zoxide | Smarter `cd` with frecency-based navigation |
| gh | GitHub CLI |
| gh-dash | GitHub dashboard in terminal |
| presenterm | Terminal slideshow presentation tool |

### Desktop & UI
| Application | Description |
|---|---|
| Aerospace | Tiling window manager |
| Sketchybar | Custom menu bar |
| JankyBorders | Rounded colored borders for focused windows |


## Usage

### Get to know Nix

New to Nix? No problem! While this repository is ready to use, having a basic understanding of how Nix works will help you customize it to fit your needs. The learning curve might seem steep at first, but trust me, it's worth every minute you invest.
I highly recommend starting with these excellent introductory resources to get yourself familiar with the core concepts:
- [Zero to nix](https://zero-to-nix.com/)
- [Nix explain from the ground up](https://youtu.be/5D3nUU1OVx8?si=ci8qjZqPHZc8I-P7)
- [Nix package manager for macOS](https://youtu.be/Z8BL8mdzWHI?si=iZcXCLDPtG-8fx0w)

### Prerequisite

1. Install nix

```
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

2. Clone this repository
```
# ensure you're in home dir
git clone https://github.com/derangga/dotfiles.git nix
```

### Configuration

1. Add your username, hostname, and terminal inside `flake.nix`. The `terminal` field accepts `"ghostty"` or `"kitty"` and drives both the Homebrew cask and the program config.
```
{
  darwinConfigurations."maclop" = mkDarwinConfig {
        hostname = "maclop";
        username = "derangga";
        terminal = "ghostty";
      };

  # Add your hostname here, you can check by run whoami
  darwinConfigurations."foo" = mkDarwinConfig {
        hostname = "foo";
        username = "foobar";
        terminal = "ghostty";
      };
}
```

2. Add a new file inside `./modules/hosts/{hostname}.nix` (host files are keyed by hostname, not username)
```
{
  pkgs,
  hostname,
  ...
}:
{
  home.packages = with pkgs; [ ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    oh-my-zsh.enable = true;

    shellAliases = {
      drb = "sudo darwin-rebuild switch --flake ~/nix#${hostname}";
      ngc = "nix-collect-garbage -d";
    };

    initContent = ''
      export EDITOR=nvim
    '';
  };

}
```

3. Now you can build it. Since this is a first time you can't use the alias yet
```
sudo darwin-rebuild switch --flake ~/nix#foo
```

## Agentic Tools

Agentic tooling (Claude Code, OpenCode, Beads, RTK, codebase-memory-mcp) is declared in `modules/llm-agents/default.nix` and installed automatically on rebuild.

`codebase-memory-mcp` is wired per-project rather than globally — see `modules/llm-agents/docs/mcp-integration.md` for the `.mcp.json` / `opencode.json` blocks, and `docs/quick-start.md` for manual CLI use.

## Resources
- [Nix store](https://search.nixos.org/packages?channel=25.11&)
- [Home manager](https://home-manager-options.extranix.com/)
- [Nix darwin](https://mynixos.com/nix-darwin)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

