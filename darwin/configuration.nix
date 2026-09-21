{
  pkgs,
  config,
  username,
  self,
  ...
}:

{
  imports = [
    ./homebrew/default.nix
    ./terminal.nix
  ];

  # Installs vendor completions and keeps macOS path_helper from reordering
  # nix paths behind /usr/bin. Registering fish as a permissible login shell
  # is separate: environment.shells is what writes /etc/shells, and chsh
  # rejects anything missing from it.
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  # Stands in for a manual chsh so a new machine needs no extra step. This runs
  # before /run/current-system is relinked, so on a first activation that path
  # still points at the previous generation; dscl stores the string without
  # checking it, and the symlink is correct by the time a terminal opens.
  system.activationScripts.postActivation.text = pkgs.lib.mkIf config.programs.fish.enable ''
    loginShell=/run/current-system/sw/bin/fish
    currentShell=$(dscl . -read /Users/${username} UserShell 2>/dev/null || true)
    if [[ "''${currentShell#UserShell: }" != "$loginShell" ]]; then
      echo "setting login shell for ${username} to fish..." >&2
      dscl . -create /Users/${username} UserShell "$loginShell"
    fi
  '';
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    ffmpeg
    gnupg
    mkalias
    tree
  ];

  fonts.packages = with pkgs; [
    kode-mono
    nerd-fonts.jetbrains-mono
    sketchybar-app-font
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 1;
      Hour = 11;
      Minute = 0;
    };
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
