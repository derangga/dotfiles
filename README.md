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

## What's Inside (Home Manager)

All the following applications are managed via home-manager and will be configured automatically on rebuild.

### Shell & Terminal
| Application | Description |
|---|---|
| Zsh + Oh My Zsh | Shell with git and fzf plugins |
| Starship | Cross-shell prompt |
| Kitty | GPU-accelerated terminal |
| Ghostty | Fast terminal emulator |

### Development Tools
| Application | Description |
|---|---|
| Neovim (LazyVim) | Text editor with LazyVim config |
| Git | Version control |
| Lazygit | Terminal UI for Git |
| Claude Code | Agentic coding tool |
| OpenCode | AI coding assistant |
| tmux | Terminal multiplexer |
| Zed | Modern, high-performance code editor |

### CLI Utilities
| Application | Description |
|---|---|
| bat | `cat` clone with syntax highlighting |
| btop | Resource monitor |
| eza | Modern `ls` replacement |
| fzf | Fuzzy finder |
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

1. Add your username and hostname inside `flake.nix`
```
{
  darwinConfigurations."maclop" = mkDarwinConfig {
        hostname = "maclop";
        username = "derangga";
      };

  # Add your hostname here, you can check by run whoami
  darwinConfigurations."foo" = mkDarwinConfig {
        hostname = "foo";
        username = "foobar";
      };
}
```

2. Add a new file inside `./modules/hosts/{your_username}.nix`
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

## Agentic Tools (Optional)

If you plan to use agentic coding tools like Claude Code, OpenCode, or similar, you can add [Serena](https://github.com/oraios/serena) as an MCP server for semantic code navigation across this repo.

```
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
```

## Resources
- [Nix store](https://search.nixos.org/packages?channel=25.11&)
- [Home manager](https://home-manager-options.extranix.com/)
- [Nix darwin](https://mynixos.com/nix-darwin)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

