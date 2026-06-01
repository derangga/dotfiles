{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.snacks-nvim ];

    extraConfigLuaPre = ''
      local notify = vim.notify
      _G.__nvim_start_time = _G.__nvim_start_time or vim.uv.hrtime()
      require("snacks").setup({
        bigfile = { enabled = true },
        quickfile = { enabled = true },
        terminal = { enabled = true },
        dashboard = {
          enabled = true,
          sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
            { section = "recent_files", icon = " ", title = "Recent Files", padding = 1 },
            function()
              if not _G.__nvim_load_ms then
                _G.__nvim_load_ms = (vim.uv.hrtime() - _G.__nvim_start_time) / 1e6
              end
              return {
                align = "center",
                padding = 1,
                text = {
                  { "⚡ ", hl = "SnacksDashboardSpecial" },
                  { string.format("Neovim loaded in %.2fms", _G.__nvim_load_ms), hl = "SnacksDashboardFooter" },
                },
              }
            end,
          },
          preset = {
            header = [[
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⠴⠶⠶⠒⠒⠒⠒⠒⠶⠶⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢶⣄⠀⣠⠴⠚⠛⠳⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠛⠉⠛⣶⠞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠦⣄⠀⠀⠀⠀⠀⠀⠈⠻⡅⠀⠀⠀⠀⠈⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠁⠈⣹⠞⠁⠀⢀⣴⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢦⡀⠀⠀⠀⠀⠀⠈⢶⣄⠀⠀⠀⠀⢷⡄⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⠀⢀⠞⠁⠀⠀⣠⠟⠁⠀⠀⠀⠀⠀⠀⣦⠀⠀⡀⠀⠀⠀⠀⠀⠀⡙⢄⠀⠀⠀⠀⠀⢢⢫⠳⡀⠀⠀⠈⣷⠀⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⢠⡏⠀⢠⠏⠀⠀⠀⣴⠋⠀⠀⢀⠆⠀⠀⠀⣼⠋⠳⡄⠙⣦⡀⠀⠀⠀⠀⠈⠈⢣⠀⠀⠀⠀⠀⠀⢧⡱⡀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⠀⡾⠀⢀⠏⠀⠀⠀⢠⠇⠀⠀⢀⡞⠀⡴⢁⣼⠏⠀⠀⠈⠲⣌⠻⣦⣄⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠘⣷⢡⠀⠀⠀⣷⠀⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⢸⠇⠀⡜⠀⠀⠀⠀⡼⠀⠀⣠⡟⣠⠎⣠⠞⠁⠀⠀⠀⠀⠀⠀⣙⡪⢵⡷⣤⣀⠀⠀⢘⡄⠀⠀⠀⠀⠀⠇⢇⡆⠀⠀⢹⡄⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⣼⠀⢀⠃⠀⠀⠀⠀⡇⢀⢴⣯⣞⠷⠛⢳⡄⠀⠀⠀⠀⠀⠀⠘⠤⠤⠤⠚⠋⠛⠻⠴⢆⡇⠀⠀⠀⠀⠀⢸⢸⢰⠀⠀⢸⡇⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⣿⠀⢸⠀⠀⠀⠀⠀⣯⠵⠛⠉⠉⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⢀⡇⠀⢠⢸⣿⠸⠀⠀⠸⡇⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⠀⡇⠀⢸⠀⡀⠀⡆⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⡀⠀⡀⠀⠸⡇⠀⢸⡸⠯⠐⠒⠒⠒⠓⠒⠒⠒⠲⡄
        ⠀⢀⣀⣀⣤⣤⡇⠠⢼⠀⡇⠀⣷⠀⢹⠀⢀⣤⣤⣤⣴⣶⣦⠀⠀⠀⠀⠀⠀⠀⠸⠿⠿⠿⠟⠛⠛⠃⠀⡇⢀⠇⠇⠀⡇⡧⠔⢖⢩⠉⠉⠓⠤⠋⣠⠞⠁
        ⠐⣯⡉⢠⡔⣒⣢⠤⡬⡆⣿⠀⢣⢇⠘⡄⠈⠋⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⡠⠀⢠⢃⠎⡸⠀⡸⣿⠀⠀⣸⡜⠀⠀⣀⡴⠛⠁⠀⠀
        ⠀⠀⠙⠲⣌⡀⠀⠱⣣⢣⡏⢧⠈⡎⣆⢣⠰⠡⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡮⠋⢸⠁⣰⣻⣛⡠⠤⠛⣀⠤⠚⣿⠁⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⢹⡗⢤⣉⠫⠧⠼⢧⠘⣟⡿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⣸⡔⢱⡎⣳⡠⠔⠊⠁⠀⠀⢿⠀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⢸⡇⠀⠈⢹⠒⠴⣅⣱⣽⣧⠀⠀⠀⠀⠀⠀⠀⠀⠦⠤⠔⠤⠤⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣶⠒⢉⠁⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀
        ⠀⠀⠀⠀⠀⣿⠀⠀⠀⢸⠀⢠⢄⠀⠀⠈⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠟⠁⣿⠀⡇⡇⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⡞⣾⠀⠀⠀⢸⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣟⠁⠀⠀⣿⠀⣟⡇⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀
        ⠀⠀⠀⠀⡿⢀⡆⠀⠀⠀⠀⡏⢹⠀⠀⠀⢸⠇⠈⣻⢶⠦⢄⣀⣀⠀⠀⠀⠀⠀⣀⣠⣤⡶⠿⠒⢋⣿⠀⠀⠀⣿⠀⡏⡇⠀⠀⠀⠀⢠⡆⠸⡇⠀⠀⠀⠀
        ⠀⠀⠀⣸⠇⣼⠀⠀⠀⠀⠀⠸⠜⠀⠀⠀⣿⣀⣀⣻⡤⡽⢛⡉⠛⠛⠛⠛⠉⣉⣉⣉⠤⠤⠒⠊⡡⣿⡴⠶⢚⠛⠢⡕⠁⠀⠀⢠⠀⢸⢡⠀⣿⠀⠀⠀⠀
        ⠀⠀⠀⣿⢰⣿⠀⠀⢀⢀⠀⠀⠀⠀⠀⢠⡿⠋⢉⡙⡧⡇⢸⣴⢶⣯⡉⠉⠀⠀⠀⠀⠀⢀⠤⠊⡠⠟⡦⠖⠁⠀⠀⠘⢆⡀⠀⡈⠀⡌⣸⠀⣿⠀⠀⠀⠀
        ⠀⠀⢨⡇⣾⣿⠀⠀⣿⢸⠀⠀⣠⠔⠒⠉⠀⠀⠈⢿⡳⡏⢸⣧⣋⣼⠇⠀⠀⢀⣀⠤⢊⡡⢔⡫⠔⠉⠀⠀⠀⠀⠀⠀⠀⠉⠓⢧⣠⠃⣿⡇⡇⠀⠀⠀⠀
        ⠀⠀⢸⡇⣿⣿⠀⠀⠇⡞⡤⠺⡁⠀⠀⠀⠀⠀⠀⠀⠙⠣⢌⡚⠭⠵⠦⠤⢬⣕⡲⠭⠓⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠠⠤⠽⣤⣿⡇⣷⠀⠀⠀⠀
        ⠀⠀⢸⡇⣇⢿⡄⠀⢠⣼⠾⣦⡙⢦⡀⠀⠀⠀⢀⡤⣤⠤⠌⠚⠛⠓⠊⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⢒⣩⡴⠶⠛⠙⢿⣿⢱⡏⠀⠀⠀⠀
        ⠀⠀⠘⣇⣿⠘⢧⣠⡞⠁⠀⠈⠛⢦⣉⠲⠤⣀⡜⢠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠤⠒⣩⡴⠞⠉⠀⠀⠀⠀⠀⠀⠹⣿⡀⠀⠀⠀⠀
        ⠀⠀⠀⠹⣼⣇⣾⠋⠀⠀⠀⠀⠀⠀⠙⠷⡒⠤⢇⡈⠒⠤⢄⣀⡀⠀⠀⠀⠀⠀⠀⢀⣀⡠⠤⠒⣉⣤⠶⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣷⠀⠀⠀⠀
        ⠀⠀⠀⠀⢈⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢱⡞⢼⠗⢶⣤⣤⣀⣉⣉⣉⣉⣉⣉⡥⢤⡲⣺⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣧⠀⠀⠀]],
            keys = {
              { icon = " ", key = "f", desc = "Find File", action = ":lua require('fff').find_files()" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "g", desc = "Find Text", action = ":lua require('fff').live_grep()" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
          },
        },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        scope = { enabled = true },
        scroll = {
          enabled = true,
          animate = {
            duration = { step = 5, total = 40 },
            easing = "linear",
          },
          animate_repeat = {
            delay = 50,
            duration = { step = 3, total = 20 },
            easing = "linear",
          },
        },
        words = { enabled = true },
        picker = { enabled = true },
        explorer = { enabled = true },
        zen = { enabled = true },
        statuscolumn = { enabled = false },
        toggle = {},
      })
      -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
      -- this is needed to have early notifications show up in noice history
      vim.notify = notify
    '';
  };
}
