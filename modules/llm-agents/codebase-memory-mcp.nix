{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.10.3";
  srcs = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      sha256 = "0ebf02328207d4c3d862c837b5e973de5bac808df92b0941737721d467287f7f";
    };
    x86_64-darwin = {
      arch = "darwin-amd64";
      sha256 = "1107fea28285823e1436e4f38a4e00a0b472d8a43c379da7dfd200c914a4b9dd";
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
