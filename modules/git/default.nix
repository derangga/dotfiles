{ hostname, ... }:
let
  gitUser = {
    maclop.name = "derangga";
    worklop = {
      name = "Dimas Rangga";
      email = "dimas.armando@sociolla.com";
    };
  };
in
{
  programs.git = {
    enable = true;
    settings = {
      user = gitUser.${hostname};
      core = {
        pager = "hunk pager";
      };
    };
  };
}
