{
  pkgs,
  config,
  username,
  self,
  ...
}:

{
  system.primaryUser = username;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    android-tools
    bun
    btop
    colima
    docker
    docker-compose
    fd
    fnm
    ffmpeg
    gcc
    gnupg
    go
    git
    javaPackages.compiler.openjdk17
    lua
    mkalias
    nixfmt
    pnpm
    ripgrep
    rbenv
  ];

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "sf-symbols"
      "font-sf-mono"
      "font-sf-pro"
      "ghostty"
    ];
  };

  nix.settings.experimental-features = "nix-command flakes";
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
