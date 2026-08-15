{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.10.4";
  srcs = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      sha256 = "c8814e2e48c72a4dcafc183d436664393d2b22460eb0b826c7982a36800701a2";
    };
    x86_64-darwin = {
      arch = "darwin-amd64";
      sha256 = "378428ac82253a1532ff89a62874342c618c7c758686f153c98eeddb0e6cd612";
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
