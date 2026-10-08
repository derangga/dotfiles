{
  fetchFromGitHub,
  fetchurl,
  lib,
  stdenvNoCC,
}:
let
  version = "0.4.0";

  target =
    {
      aarch64-darwin = {
        name = "aarch64-apple-darwin";
        hash = "sha256-nx8MgPoTcw0cHycNrfVXgTJfxkB6PLisqZtguNEhL04=";
      };
      x86_64-darwin = {
        name = "x86_64-apple-darwin";
        hash = "sha256-0WSP0IwsKPGBuZjRB9Z0fOPk+4Y7HiSlVN4nrLGAg6M=";
      };
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "herdr-review: unsupported system ${stdenvNoCC.hostPlatform.system}");

  binary = fetchurl {
    url = "https://github.com/derangga/herdr-review-annotate/releases/download/v${version}/herdr-review-${target.name}";
    inherit (target) hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "herdr-review";
  inherit version;

  src = fetchFromGitHub {
    owner = "derangga";
    repo = "herdr-review-annotate";
    rev = "v${version}";
    hash = "sha256-XnPROP30QO8sn9qKHTL40au8Xi4+4sFKfTrdzjMs/tc=";
  };

  dontBuild = true;

  # The manifest's build hook only runs on `herdr plugin install`; `plugin link`
  # skips it, so the binary has to already sit at bin/herdr-review.
  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    cp -R . "$out"
    chmod -R u+w "$out"
    install -Dm755 ${binary} "$out/bin/herdr-review"

    runHook postInstall
  '';

  meta = {
    description = "Review a diff in a Herdr pane and send the comments to an agent";
    homepage = "https://github.com/derangga/herdr-review-annotate";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "herdr-review";
  };
}
