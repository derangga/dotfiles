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
}
