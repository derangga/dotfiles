{ pkgs, lib, ... }:

let
  vueTsPluginPath = "${pkgs.vue-language-server}/lib/language-tools/packages/language-server";
in
{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;

      servers = {
        lua_ls = {
          enable = true;
          settings = {
            Lua = {
              workspace.checkThirdParty = false;
              codeLens.enable = true;
              completion.callSnippet = "Replace";
              doc.privateName = [ "^_" ];
              hint = {
                enable = true;
                setType = false;
                paramType = true;
                paramName = "Disable";
                semicolon = "Disable";
                arrayIndex = "Disable";
              };
            };
          };
        };
        bashls.enable = true;
        clangd.enable = true;
        cssls.enable = true;
        eslint.enable = true;
        gopls.enable = true;
        html.enable = true;
        jsonls.enable = true;
        marksman.enable = true;
        nixd.enable = true;
        sqls.enable = true;
        tailwindcss.enable = true;
        ts_ls = {
          enable = true;
          extraOptions = {
            init_options = {
              plugins = lib.mkForce [
                {
                  name = "@vue/typescript-plugin";
                  location = vueTsPluginPath;
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
              typescript = {
                tsdk = "${pkgs.typescript}/lib/node_modules/typescript/lib";
              };
            };
          };
          filetypes = [ "vue" ];
        };
        yamlls.enable = true;
      };
    };

    plugins.lsp.onAttach = ''
      local map = function(mode, lhs, rhs, desc, extra)
        local opts = { buffer = bufnr, desc = desc, silent = true }
        if extra then opts = vim.tbl_extend("force", opts, extra) end
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      map("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
      map("n", "gr", function() Snacks.picker.lsp_references() end, "References", { nowait = true })
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

      -- Enable inlay hints (exclude vue and non-file buffers like diffview://)
      if client:supports_method("textDocument/inlayHint") then
        local filetype = vim.bo[bufnr].filetype
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local is_file = bufname == "" or bufname:match("^/") or bufname:match("^file://")
        if filetype ~= "vue" and is_file then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
      end

      -- LSP-driven folding when supported. Skip on very large files, where the
      -- foldexpr recomputation gets expensive; those fall back to foldmethod=indent.
      if client:supports_method("textDocument/foldingRange") then
        if vim.api.nvim_buf_line_count(bufnr) <= 5000 then
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
        end
      end
    '';

    extraConfigLua = ''
      vim.lsp.config("*", {
        capabilities = {
          workspace = {
            fileOperations = {
              didRename = true,
              willRename = true,
            },
          },
        },
      })

      vim.diagnostic.config({
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
          },
        },
      })
    '';
  };
}
