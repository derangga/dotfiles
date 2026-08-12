{ pkgs, ... }:

let
  vueTsPluginPath = "${pkgs.vue-language-server}/lib/language-tools/packages/language-server";

  # typescript@7 is the Go compiler: no tsserver.js, so vtsls cannot use it and
  # tsserver plugins (@effect/language-service) do not apply. npm/bun install its
  # binary as `tsc`, @typescript/native-preview as `tsgo`; getExePath.js is TS7-only.
  tsgoBin = ''
    local function tsgo_bin(root)
      if not root then return nil end
      if vim.uv.fs_stat(root .. "/node_modules/.bin/tsgo") then
        return root .. "/node_modules/.bin/tsgo"
      end
      if vim.uv.fs_stat(root .. "/node_modules/typescript/lib/getExePath.js") then
        return root .. "/node_modules/.bin/tsc"
      end
    end
  '';
  tsRoot = ''
    vim.fs.root(bufnr, { "bun.lock", "package-lock.json", "pnpm-lock.yaml", "yarn.lock", "package.json", ".git" })
  '';
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
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
        sourcekit = {
          enable = true;
          package = null; # use Xcode's /usr/bin/sourcekit-lsp instead of nixpkgs'
          # Defaults also claim c/cpp/objc/objcpp, which clangd already handles.
          filetypes = [ "swift" ];
        };
        sqls.enable = true;
        tailwindcss.enable = true;
        tsgo = {
          enable = true;
          package = null; # only ever the project's own binary, which may be effect-patched
          extraOptions = {
            cmd.__raw = ''
              function(dispatchers, config)
                ${tsgoBin}
                return vim.lsp.rpc.start({ tsgo_bin(config.root_dir), "--lsp", "--stdio" }, dispatchers)
              end
            '';
            root_dir.__raw = ''
              function(bufnr, on_dir)
                ${tsgoBin}
                local root = ${tsRoot}
                if root and tsgo_bin(root) then on_dir(root) end
              end
            '';
          };
        };
        vtsls = {
          enable = true;
          extraOptions = {
            # TypeScript 7 projects are served by tsgo instead.
            root_dir.__raw = ''
              function(bufnr, on_dir)
                ${tsgoBin}
                local root = ${tsRoot}
                if root and tsgo_bin(root) then return end
                on_dir(root or vim.fn.getcwd())
              end
            '';
          };
          settings.vtsls = {
            # tsserver only resolves plugins declared in a project's tsconfig
            # (e.g. @effect/language-service) when it runs from the workspace's
            # own node_modules; neither server passes --allowLocalPluginLoads.
            autoUseWorkspaceTsdk = true;
            tsserver.globalPlugins = [
              {
                name = "@vue/typescript-plugin";
                location = vueTsPluginPath;
                languages = [ "vue" ];
                configNamespace = "typescript";
                enableForWorkspaceTypeScriptVersions = true;
              }
            ];
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
          # The plugin above is declared by hand; nixvim's integrations would
          # define the same globalPlugins list and conflict on eval.
          tslsIntegration = false;
          vtslsIntegration = false;
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
          if client.name == "sourcekit" then
            -- sourcekit-lsp times out (-32001) on the first inlayHint while SwiftPM
            -- is still evaluating the package manifest. Enable once it is warm.
            vim.defer_fn(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
              end
            end, 5000)
          else
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
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

      -- Neovim never stops a client when its last buffer closes, so a session
      -- that wanders between projects keeps a full tsserver heap per repo.
      -- Only the expensive servers are worth the restart cost.
      local idle_reap = { vtsls = true, eslint = true, tailwindcss = true, vue_ls = true }
      vim.api.nvim_create_autocmd("LspDetach", {
        desc = "Stop heavy language servers left with no open buffers",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or not idle_reap[client.name] then return end
          vim.defer_fn(function()
            if not client:is_stopped() and next(client.attached_buffers) == nil then
              client:stop()
              vim.notify("Stopped idle LSP: " .. client.name, vim.log.levels.INFO)
            end
          end, 10 * 60 * 1000)
        end,
      })
    '';
  };
}
