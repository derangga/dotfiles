{ pkgs, ... }:

let
  jsDebugAdapter = "${pkgs.vscode-js-debug}/bin/js-debug";
in
{
  programs.nixvim = {
    # nvim-dap loads on first debug keypress. Its luaConfig.post (below) registers
    # adapters/configs/listeners and then pulls in dap-ui + dap-virtual-text, so the
    # session listeners have dapui available regardless of which key was pressed first.
    plugins.dap = {
      enable = true;
      lazyLoad.settings.keys = [
        { __unkeyed-1 = "<leader>dB"; __unkeyed-2.__raw = ''function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end''; desc = "Breakpoint Condition"; }
        { __unkeyed-1 = "<leader>db"; __unkeyed-2.__raw = ''function() require("dap").toggle_breakpoint() end''; desc = "Toggle Breakpoint"; }
        { __unkeyed-1 = "<leader>dc"; __unkeyed-2.__raw = ''function() require("dap").continue() end''; desc = "Run/Continue"; }
        { __unkeyed-1 = "<leader>da"; __unkeyed-2.__raw = ''
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
          ''; desc = "Run with Args"; }
        { __unkeyed-1 = "<leader>dC"; __unkeyed-2.__raw = ''function() require("dap").run_to_cursor() end''; desc = "Run to Cursor"; }
        { __unkeyed-1 = "<leader>dg"; __unkeyed-2.__raw = ''function() require("dap").goto_() end''; desc = "Go to Line (No Execute)"; }
        { __unkeyed-1 = "<leader>di"; __unkeyed-2.__raw = ''function() require("dap").step_into() end''; desc = "Step Into"; }
        { __unkeyed-1 = "<leader>dj"; __unkeyed-2.__raw = ''function() require("dap").down() end''; desc = "Down"; }
        { __unkeyed-1 = "<leader>dk"; __unkeyed-2.__raw = ''function() require("dap").up() end''; desc = "Up"; }
        { __unkeyed-1 = "<leader>dl"; __unkeyed-2.__raw = ''function() require("dap").run_last() end''; desc = "Run Last"; }
        { __unkeyed-1 = "<leader>do"; __unkeyed-2.__raw = ''function() require("dap").step_out() end''; desc = "Step Out"; }
        { __unkeyed-1 = "<leader>dO"; __unkeyed-2.__raw = ''function() require("dap").step_over() end''; desc = "Step Over"; }
        { __unkeyed-1 = "<leader>dP"; __unkeyed-2.__raw = ''function() require("dap").pause() end''; desc = "Pause"; }
        { __unkeyed-1 = "<leader>dr"; __unkeyed-2.__raw = ''function() require("dap").repl.toggle() end''; desc = "Toggle REPL"; }
        { __unkeyed-1 = "<leader>ds"; __unkeyed-2.__raw = ''function() require("dap").session() end''; desc = "Session"; }
        { __unkeyed-1 = "<leader>dt"; __unkeyed-2.__raw = ''function() require("dap").terminate() end''; desc = "Terminate"; }
        { __unkeyed-1 = "<leader>dw"; __unkeyed-2.__raw = ''function() require("dap.ui.widgets").hover() end''; desc = "Widgets"; }
        { __unkeyed-1 = "<leader>du"; __unkeyed-2.__raw = ''function() require("dapui").toggle({}) end''; desc = "Dap UI"; }
        { __unkeyed-1 = "<leader>de"; mode = [ "n" "x" ]; __unkeyed-2.__raw = ''function() require("dapui").eval() end''; desc = "Eval"; }
      ];
    };

    # dap-ui and dap-virtual-text are pulled in by nvim-dap's luaConfig.post.
    plugins.dap-ui = {
      enable = true;
      lazyLoad.settings.lazy = true;
    };

    plugins.dap-virtual-text = {
      enable = true;
      lazyLoad.settings.lazy = true;
    };

    plugins.dap.luaConfig.post = ''
      require("lz.n").trigger_load("nvim-dap-ui")
      require("lz.n").trigger_load("nvim-dap-virtual-text")

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
