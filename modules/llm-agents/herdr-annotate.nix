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
        hash = "sha256-CW0MWr2oYsFzrHN5xgb4kJdo9DRYMzrHBr1u3gQkyLc=";
      };
      x86_64-darwin = {
        name = "x86_64-apple-darwin";
        hash = "sha256-ysoUurI13uJkF7+mtJ/nC3v2uYWvnqStTNa6JPVs7DE=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "herdr-annotate: unsupported system ${stdenvNoCC.hostPlatform.system}");

  plannotatorTui = fetchurl {
    url = "https://github.com/plannotator/plannotator-tui/releases/download/v0.6.0/plannotator-tui-${target.name}";
    inherit (target) hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "herdr-annotate";
  version = "0.3.0";
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
