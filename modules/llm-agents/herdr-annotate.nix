{
  fetchurl,
  lib,
  src,
  stdenvNoCC,
}:
let
  target =
    {
      aarch64-darwin = {
        name = "aarch64-apple-darwin";
        hash = "sha256-eciAG6usXNJXA0A2U2u89Rp7TNjQa0N/HoVxNxRSHrA=";
      };
      x86_64-darwin = {
        name = "x86_64-apple-darwin";
        hash = "sha256-Nu8FZmwGbbfDJ1nI1u6+YiNxF7iHSIGEY/oqz5TvWDQ=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "herdr-annotate: unsupported system ${stdenvNoCC.hostPlatform.system}");

  plannotatorTui = fetchurl {
    url = "https://github.com/plannotator/plannotator-tui/releases/download/v0.9.2/plannotator-tui-${target.name}";
    inherit (target) hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "herdr-annotate";
  version = "0.5.0";
  inherit src;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R . "$out"
    chmod -R u+w "$out"
    install -Dm755 ${plannotatorTui} "$out/bin/plannotator-tui.exe"
    ln -s plannotator-tui.exe "$out/bin/plannotator-tui"

    runHook postInstall
  '';

  meta = {
    description = "Annotate terminal text and review documents inside Herdr";
    homepage = "https://github.com/plannotator/herdr-annotate";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
