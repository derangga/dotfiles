{ ... }:

{
  programs.nixvim = {
    # The plugin declares `dependencies = [ "flutter" ]`, which would pull pkgs.flutter
    # into nvim's closure on every host. flutter is a worklop-only package, so let the
    # plugin find it on PATH instead of adding ~1GB to maclop's neovim.
    dependencies.flutter.enable = false;

    # flutter-tools starts and owns dartls, so plugins.lsp.servers.dartls stays off;
    # enabling both would attach two clients to every Dart buffer. The shared
    # plugins.lsp.onAttach keymaps still apply: nixvim implements them as a global
    # LspAttach autocmd, not a per-server on_attach.
    plugins.flutter-tools = {
      enable = true;
      settings = {
        widget_guides.enabled = true;
        closing_tags.enabled = true;
        dev_log = {
          enabled = true;
          open_cmd = "15split";
        };
        lsp = {
          color.enabled = true;
          settings = {
            showTodos = true;
            completeFunctionCalls = true;
            renameFilesWithClasses = "prompt";
            updateImportsOnRename = true;
          };
        };
        # The Dart SDK's own DAP server; plugins.dap is already enabled in ./dap.nix.
        debugger.enabled = true;
      };
    };
  };
}
