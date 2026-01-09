<div align="center">

# Be a cool dev with Nix ❄️

</div>

<div align="center"><img src="screenshots/my-setup-preview.png" height="500px"/></div>

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

3. Add your username and hostname inside `flake.nix`
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

4. Add a new file inside `./modules/hosts/{your_username}.nix`
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

5. Now you can build it. Since this is a first time you can't use the alias yet
```
sudo darwin-rebuild switch --flake ~/nix#foo
```

## Resources
- [Nix store](https://search.nixos.org/packages?channel=25.11&)
- [Home manager](https://home-manager-options.extranix.com/)
- [Nix darwin](https://mynixos.com/nix-darwin)

