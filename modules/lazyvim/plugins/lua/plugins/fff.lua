return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  lazy = false,
  opts = {
    prompt = "🦉 ",
    layout = {
      prompt_position = "top",
    },
  },
  keys = {
    -- file finding (override snacks picker)
    {
      "<leader>ff",
      function()
        require("fff").find_files()
      end,
      desc = "Find files (fff)",
    },
    {
      "<leader><space>",
      function()
        require("fff").find_files()
      end,
      desc = "Find files (fff)",
    },
    -- grep (override snacks picker)
    {
      "<leader>sg",
      function()
        require("fff").live_grep()
      end,
      desc = "Live grep (fff)",
    },
  },
}
