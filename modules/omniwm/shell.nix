# OmniShell's shell.toml. The Default style ships a full-width bar over the menu
# bar with many widgets; these keys win over the style's and keep only the
# workspaces on a vertical right-edge bar. autoHide stays in settings.nix, which
# the style does not set.
{
  profile = "default";
  profiles.default = {
    leading = [ "workspaces" ];
    center = [ ];
    trailing = [ ];
    workspaceBar = {
      position = "right";
      fullWidth = false;
      height = 24;
      reserveLayoutSpace = false;
      backgroundOpacity = 0.1;
      showItemBackgrounds = true;
      systemStatsButton = false;
    };
  };
}
