{ pkgs, ... }:

{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        c
        css
        diff
        go
        html
        javascript
        json
        lua
        markdown
        markdown_inline
        nix
        python
        query
        regex
        tsx
        typescript
        vim
        vimdoc
        vue
        xml
        yaml
      ];
    };

    plugins.treesitter-textobjects = {
      enable = true;
      settings.move = {
        enable = true;
        set_jumps = true;
        goto_next_start = {
          "]f" = "@function.outer";
          "]c" = "@class.outer";
          "]a" = "@parameter.inner";
        };
        goto_previous_start = {
          "[f" = "@function.outer";
          "[c" = "@class.outer";
          "[a" = "@parameter.inner";
        };
      };
    };

    plugins.ts-autotag = {
      enable = true;
      settings = {
        opts = {
          enable_close = true;
          enable_rename = true;
          enable_close_on_slash = false;
        };
        per_filetype = {
          html = {
            enable_close = false;
          };
        };
      };
    };
  };
}
