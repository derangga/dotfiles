{ pkgs, ... }:

let
  jsDebugAdapter = "${pkgs.vscode-js-debug}/bin/js-debug";
in
{
  programs.nixvim = {
    plugins.dap = {
      enable = true;
    };

    plugins.dap-ui = {
      enable = true;
    };

    plugins.dap-virtual-text = {
      enable = true;
    };

    keymaps = [
      { mode = "n"; key = "<leader>dB"; action.__raw = ''function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end''; options.desc = "Breakpoint Condition"; }
      { mode = "n"; key = "<leader>db"; action.__raw = ''function() require("dap").toggle_breakpoint() end''; options.desc = "Toggle Breakpoint"; }
      { mode = "n"; key = "<leader>dc"; action.__raw = ''function() require("dap").continue() end''; options.desc = "Run/Continue"; }
      { mode = "n"; key = "<leader>da"; action.__raw = ''
          function()
            require("dap").continue({
              before = function(config)
                local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
                local args_str = type(args) == "table" and table.concat(args, " ") or args
                config = vim.deepcopy(config)
                config.args = function()
                  local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str))
                  if config.type and config.type == "java" then
                    return new_args
                  end
                  return require("dap.utils").splitstr(new_args)
                end
                return config
              end,
            })
          end
        ''; options.desc = "Run with Args"; }
      { mode = "n"; key = "<leader>dC"; action.__raw = ''function() require("dap").run_to_cursor() end''; options.desc = "Run to Cursor"; }
      { mode = "n"; key = "<leader>dg"; action.__raw = ''function() require("dap").goto_() end''; options.desc = "Go to Line (No Execute)"; }
      { mode = "n"; key = "<leader>di"; action.__raw = ''function() require("dap").step_into() end''; options.desc = "Step Into"; }
      { mode = "n"; key = "<leader>dj"; action.__raw = ''function() require("dap").down() end''; options.desc = "Down"; }
      { mode = "n"; key = "<leader>dk"; action.__raw = ''function() require("dap").up() end''; options.desc = "Up"; }
      { mode = "n"; key = "<leader>dl"; action.__raw = ''function() require("dap").run_last() end''; options.desc = "Run Last"; }
      { mode = "n"; key = "<leader>do"; action.__raw = ''function() require("dap").step_out() end''; options.desc = "Step Out"; }
      { mode = "n"; key = "<leader>dO"; action.__raw = ''function() require("dap").step_over() end''; options.desc = "Step Over"; }
      { mode = "n"; key = "<leader>dP"; action.__raw = ''function() require("dap").pause() end''; options.desc = "Pause"; }
      { mode = "n"; key = "<leader>dr"; action.__raw = ''function() require("dap").repl.toggle() end''; options.desc = "Toggle REPL"; }
      { mode = "n"; key = "<leader>ds"; action.__raw = ''function() require("dap").session() end''; options.desc = "Session"; }
      { mode = "n"; key = "<leader>dt"; action.__raw = ''function() require("dap").terminate() end''; options.desc = "Terminate"; }
      { mode = "n"; key = "<leader>dw"; action.__raw = ''function() require("dap.ui.widgets").hover() end''; options.desc = "Widgets"; }
      { mode = "n"; key = "<leader>du"; action.__raw = ''function() require("dapui").toggle({}) end''; options.desc = "Dap UI"; }
      { mode = [ "n" "x" ]; key = "<leader>de"; action.__raw = ''function() require("dapui").eval() end''; options.desc = "Eval"; }
    ];

    extraConfigLua = ''
      local dap = require("dap")
      local dapui = require("dapui")

      -- Highlight & signs (parity with LazyVim icons)
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      local dap_icons = {
        Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
        Breakpoint          = { " ", "DiagnosticInfo" },
        BreakpointCondition = { " ", "DiagnosticInfo" },
        BreakpointRejected  = { " ", "DiagnosticError" },
        LogPoint            = { ".>", "DiagnosticInfo" },
      }
      for name, sign in pairs(dap_icons) do
        vim.fn.sign_define(
          "Dap" .. name,
          { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
        )
      end

      -- dapui: auto open/close with sessions
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({}) end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close({}) end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close({}) end

      -- VSCode launch.json with comment stripping (requires plenary)
      do
        local ok_vscode, vscode = pcall(require, "dap.ext.vscode")
        local ok_json, json = pcall(require, "plenary.json")
        if ok_vscode and ok_json then
          vscode.json_decode = function(str)
            return vim.json.decode(json.json_strip_comments(str))
          end
        end
      end


      for _, adapterType in ipairs({ "node", "chrome", "msedge" }) do
        local pwaType = "pwa-" .. adapterType

        if not dap.adapters[pwaType] then
          dap.adapters[pwaType] = {
            type = "server",
            host = "localhost",
            port = "''${port}",
            executable = {
              command = "${jsDebugAdapter}",
              args = { "''${port}" },
            },
          }
        end

        if not dap.adapters[adapterType] then
          dap.adapters[adapterType] = function(cb, config)
            local nativeAdapter = dap.adapters[pwaType]
            config.type = pwaType
            if type(nativeAdapter) == "function" then
              nativeAdapter(cb, config)
            else
              cb(nativeAdapter)
            end
          end
        end
      end

      local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

      local vscode = require("dap.ext.vscode")
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          local runtimeExecutable = nil
          if language:find("typescript") then
            runtimeExecutable = vim.fn.executable("tsx") == 1 and "tsx" or "ts-node"
          end
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "''${file}",
              cwd = "''${workspaceFolder}",
              sourceMaps = true,
              runtimeExecutable = runtimeExecutable,
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              resolveSourceMapLocations = {
                "''${workspaceFolder}/**",
                "!**/node_modules/**",
              },
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "''${workspaceFolder}",
              sourceMaps = true,
              runtimeExecutable = runtimeExecutable,
              skipFiles = { "<node_internals>/**", "node_modules/**" },
              resolveSourceMapLocations = {
                "''${workspaceFolder}/**",
                "!**/node_modules/**",
              },
            },
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch via pnpm dev",
              runtimeExecutable = "pnpm",
              runtimeArgs = { "run", "dev" },
              cwd = "''${workspaceFolder}",
              console = "integratedTerminal",
              sourceMaps = true,
            },
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch via npm dev",
              runtimeExecutable = "npm",
              runtimeArgs = { "run", "dev" },
              cwd = "''${workspaceFolder}",
              console = "integratedTerminal",
              sourceMaps = true,
            },
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch via bun dev",
              runtimeExecutable = "bun",
              runtimeArgs = { "run", "dev" },
              cwd = "''${workspaceFolder}",
              console = "integratedTerminal",
              sourceMaps = true,
            },
          }
        end
      end
    '';
  };
}
