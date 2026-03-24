{ pkgs, ... }:

{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./autocmds.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      fd
      gcc
      lua
      nixfmt
      ripgrep
      lazygit
      nodePackages.prettier
      stylua
      shfmt
    ];

    extraConfigLuaPre = ''
      -- ClearRegisters utility command
      vim.api.nvim_create_user_command("ClearRegisters", function()
        local regs = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"'
        for i = 1, #regs do
          vim.fn.setreg(regs:sub(i, i), {})
        end
      end, {})
    '';
  };
}
