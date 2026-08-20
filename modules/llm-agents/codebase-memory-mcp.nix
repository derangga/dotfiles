{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.10.8";
  srcs = {
    aarch64-darwin = {
      arch = "darwin-arm64";
      sha256 = "9bd840dfb3ec7eaef4f310382057adaa5b0e904df883104d03ffcf39836afd07";
    };
    x86_64-darwin = {
      arch = "darwin-amd64";
      sha256 = "2b193085410af3801634a522f4b17dcd6699695e015a068393c87817c1d260d4";
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
