{ ... }:

{
  programs.nixvim = {
    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<CR>" = [ "accept" "fallback" ];
          "<Tab>" = [ "select_next" "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
          "<C-space>" = [ "show" "show_documentation" "hide_documentation" ];
        };

        appearance = {
          nerd_font_variant = "mono";
        };

        completion = {
          accept = {
            auto_brackets = {
              enabled = true;
            };
          };
          menu = {
            draw = {
              treesitter = [ "lsp" ];
            };
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
          };
          ghost_text = {
            enabled = true;
          };
        };

        sources = {
          default = [ "lsp" "path" "snippets" "buffer" ];
        };

        signature = {
          enabled = true;
        };

        cmdline = {
          enabled = true;
          keymap = {
            preset = "cmdline";
            "<Tab>" = [ "show" "accept" ];
            "<CR>" = [ "accept_and_enter" "fallback" ];
          };
          completion = {
            menu = {
              auto_show = true;
            };
            ghost_text = {
              enabled = true;
            };
          };
        };
      };
    };
  };
}
