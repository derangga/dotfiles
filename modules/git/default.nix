{ hostname, ... }:
let
  gitUser = {
    maclop.name = "derangga";
    worklop.name = "Dimas Rangga";
  };
in
{
  programs.git = {
    enable = true;
    settings = {
      user = gitUser.${hostname};
    };
  };
}
