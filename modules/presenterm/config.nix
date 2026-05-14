# Presenterm: terminal-based markdown slideshow tool.
# Docs: https://mfontanini.github.io/presenterm/introduction.html
{
  config,
  pkgs,
  ...
}:

let
  presentermSupportDir = "Library/Application Support/presenterm";
  puppeteerConfigPath = "${config.home.homeDirectory}/${presentermSupportDir}/puppeteer.json";

  # mmdc/puppeteer needs a Chromium-based browser binary. nixpkgs ships no
  # Darwin Chromium and puppeteer cannot install one into the read-only Nix
  # store path of mermaid-cli, so we point at a system-installed browser.
  # Any Chromium fork works — swap this line if you use a different one:
  #   Chrome  : /Applications/Google Chrome.app/Contents/MacOS/Google Chrome
  #   Arc     : /Applications/Arc.app/Contents/MacOS/Arc
  #   Brave   : /Applications/Brave Browser.app/Contents/MacOS/Brave Browser
  #   Edge    : /Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge
  #   Vivaldi : /Applications/Vivaldi.app/Contents/MacOS/Vivaldi
  chromeExecutable = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
in
{
  home.packages = with pkgs; [
    presenterm
    mermaid-cli
  ];

  home.file = {
    "${presentermSupportDir}/config.yaml".text = ''
      snippet:
        render:
          threads: 2

      mermaid:
        scale: 2
        puppeteer_config_path: '${puppeteerConfigPath}'
    '';

    "${presentermSupportDir}/puppeteer.json".text = builtins.toJSON {
      executablePath = chromeExecutable;
      args = [ "--no-sandbox" ];
    };
  };
}
