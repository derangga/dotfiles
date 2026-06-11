{ hostname, ... }:
let
  gitUserName = {
    maclop = "meynisa";
    worklop = "Dimas Rangga";
  };
in
{
  programs.git = {
    enable = true;
    settings.user.name = gitUserName.${hostname};
  };
}
