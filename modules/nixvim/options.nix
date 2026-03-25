{ ... }:

{
  programs.nixvim = {
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
      markdown_recommended_style = 0;
      autoformat = true;
      snacks_animate = true;
    };

    opts = {
      autowrite = true;
      clipboard = "unnamedplus";
      completeopt = "menu,menuone,noselect";
      conceallevel = 2;
      confirm = true;
      cursorline = true;
      expandtab = true;
      foldlevel = 99;
      foldmethod = "indent";
      foldtext = "";
      formatoptions = "jcroqlnt";
      grepformat = "%f:%l:%c:%m";
      grepprg = "rg --vimgrep";
      ignorecase = true;
      inccommand = "nosplit";
      jumpoptions = "view";
      laststatus = 3;
      linebreak = true;
      list = true;
      mouse = "a";
      number = true;
      pumblend = 10;
      pumheight = 10;
      relativenumber = true;
      ruler = false;
      scrolloff = 4;
      sessionoptions = "buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds";
      shiftround = true;
      shiftwidth = 2;
      shortmess = "WIcC";
      showmode = false;
      sidescrolloff = 8;
      signcolumn = "yes";
      smartcase = true;
      smartindent = true;
      smoothscroll = true;
      spelllang = "en";
      splitbelow = true;
      splitkeep = "screen";
      splitright = true;
      tabstop = 2;
      termguicolors = true;
      timeoutlen = 300;
      undofile = true;
      undolevels = 10000;
      updatetime = 200;
      virtualedit = "block";
      wildmode = "longest:full,full";
      winminwidth = 5;
      wrap = false;
    };
  };
}
