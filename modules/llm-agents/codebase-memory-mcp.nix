{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.12.1";
  srcs = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      sha256 = "9bfcbe38414b47969a3e1d1c1999f5357409387c86fa3d24221b5458267660d2";
    };
    x86_64-darwin = {
      arch = "darwin-amd64";
      sha256 = "ca6e64397a8ae80cec898a8205a6aa16750ac798acc05a0c3ed983837944a581";
    };
  };
  release =
    srcs.${stdenvNoCC.hostPlatform.system}
      or (throw "codebase-memory-mcp: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "codebase-memory-mcp";
  inherit version;

  src = fetchurl {
    url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${version}/codebase-memory-mcp-${release.arch}.tar.gz";
    inherit (release) sha256;
  };

  sourceRoot = ".";

  # Upstream ships an ad-hoc signed binary; stripping invalidates the signature.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 codebase-memory-mcp $out/bin/codebase-memory-mcp
    runHook postInstall
  '';

  meta = {
    description = "Code intelligence MCP server indexing codebases into a knowledge graph";
    homepage = "https://github.com/DeusData/codebase-memory-mcp";
    license = lib.licenses.mit;
    mainProgram = "codebase-memory-mcp";
    platforms = builtins.attrNames srcs;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
