{
  pkgs,
  config,
  username,
  hostname,
  self,
  ...
}:

{
  imports = [
    ./homebrew/default.nix
    ./homebrew/hosts/${hostname}.nix
    ./terminal.nix
  ];

  system.primaryUser = username;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    bun
    cargo
    fnm
    ffmpeg
    gnupg
    go
    mkalias
    nixd
    pnpm
    rustc
    rust-analyzer
    tree
    uv
  ];

  fonts.packages = with pkgs; [
    kode-mono
    nerd-fonts.jetbrains-mono
    sketchybar-app-font
  ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  nix.settings.experimental-features = "nix-command flakes";
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; };
    options = "--delete-older-than 7d";
  };
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.activationScripts.applications.text =
    let
      env = pkgs.buildEnv {
        name = "system-applications";
        paths = config.environment.systemPackages;
        pathsToLink = [ "/Applications" ];
      };
    in
    pkgs.lib.mkForce ''
      rm -rf /Applications/Nix\ Apps/
      mkdir -p /Applications/Nix\ Apps/
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix\ Apps/$app_name"
      done
    '';

  system.defaults = {
    dock.autohide = true;
    controlcenter.Bluetooth = false;
    NSGlobalDomain._HIHideMenuBar = true;
  };
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;
}
