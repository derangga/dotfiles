{ hostname, ... }:
let
  gitUserName = {
    maclop = "derangga";
    worklop = "Dimas Rangga";
  };
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = gitUserName.${hostname};
      core = {
        pager = "hunk pager";
      };
    };
  };
}
