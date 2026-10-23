{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "1.0.1";
  srcs = {
    aarch64-darwin = {
      arch = "aarch64-macos";
      hash = "sha256-1LZqyEhPSdekngW2+TQnFsdHEpUn/L6P/jZnn/oY3WA=";
    };
    x86_64-darwin = {
      arch = "x86_64-macos";
      hash = "sha256-H8ygrnaE9HB4DeYRpW6ajqYS1f8h4327SJBeusW5GKc=";
    };
  };
  release =
    srcs.${stdenvNoCC.hostPlatform.system}
      or (throw "lightpanda: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "lightpanda";
  inherit version;

  src = fetchurl {
    url = "https://github.com/lightpanda-io/browser/releases/download/${version}/lightpanda-${release.arch}";
    inherit (release) hash;
  };

  dontUnpack = true;
  # Stripping would invalidate the binary's signature.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/lightpanda
    runHook postInstall
  '';

  meta = {
    description = "Headless browser for AI agents and automation, driven over CDP";
    homepage = "https://github.com/lightpanda-io/browser";
    license = lib.licenses.agpl3Only;
    mainProgram = "lightpanda";
    platforms = builtins.attrNames srcs;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
