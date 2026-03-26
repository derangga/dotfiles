{ pkgs, ... }:

{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.snacks-nvim ];

    extraConfigLuaPre = ''
      local notify = vim.notify
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
              { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
              { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
              { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
              { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
              { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
          },
        },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
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
