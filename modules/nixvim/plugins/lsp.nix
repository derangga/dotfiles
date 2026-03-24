{ pkgs, lib, ... }:

let
  vueLsPath = "${pkgs.vue-language-server}/lib/node_modules/@vue/language-server";
in
{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;

      servers = {
        lua_ls.enable = true;
        bashls.enable = true;
        clangd.enable = true;
        cssls.enable = true;
        eslint = {
          enable = true;
          onAttach.function = ''
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          '';
        };
        gopls.enable = true;
        html.enable = true;
        jsonls.enable = true;
        marksman.enable = true;
        sqls.enable = true;
        tailwindcss.enable = true;
        ts_ls = {
          enable = true;
          extraOptions = {
            init_options = {
              plugins = lib.mkForce [
                {
                  name = "@vue/typescript-plugin";
                  location = vueLsPath;
                  languages = [
                    "vue"
                    "javascript"
                    "typescript"
                  ];
                }
              ];
            };
          };
          filetypes = [
            "typescript"
            "javascript"
            "javascriptreact"
            "typescriptreact"
            "vue"
          ];
        };
        vue_ls = {
          enable = true;
          extraOptions = {
            init_options = {
              vue = {
                hybridMode = false;
              };
            };
          };
          filetypes = [ "vue" ];
        };
        yamlls.enable = true;
      };
    };

    plugins.lsp.onAttach = ''
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
      end

      map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
      map("n", "gr", function() Snacks.picker.lsp_references() end, "References")
      map("n", "gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
      map("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "Goto T[y]pe Definition")
      map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
      map("n", "K", vim.lsp.buf.hover, "Hover")
      map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
      map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")
      map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
      map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
      map("n", "<leader>cA", function()
        vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
      end, "Source Action")
      map("n", "<leader>co", function()
        vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" }, diagnostics = {} } })
      end, "Organize Imports")
      map("n", "<leader>cl", function() Snacks.picker.lsp_config() end, "LSP Config")
      map("n", "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
      map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
      map("n", "<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
      map("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, "LSP Symbols")
      map("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, "LSP Workspace Symbols")

      -- Enable inlay hints (exclude vue)
      if client.supports_method("textDocument/inlayHint") then
        local filetype = vim.bo[bufnr].filetype
        if filetype ~= "vue" then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end
    '';

    diagnostics = {
      underline = true;
      virtual_text = {
        spacing = 4;
        prefix = "●";
      };
      severity_sort = true;
      signs = {
        text = {
          "__rawKey__vim.diagnostic.severity.ERROR" = " ";
          "__rawKey__vim.diagnostic.severity.WARN" = " ";
          "__rawKey__vim.diagnostic.severity.HINT" = " ";
          "__rawKey__vim.diagnostic.severity.INFO" = " ";
        };
      };
    };
  };
}
