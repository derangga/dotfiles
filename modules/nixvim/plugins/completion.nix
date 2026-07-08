{ ... }:

{
  programs.nixvim = {
    # friendly-snippets stays on the runtimepath; blink-cmp's native "default"
    # snippet preset loads it directly (friendly_snippets = true by default).
    plugins.friendly-snippets.enable = true;

    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "enter";
          "<C-y>" = [ "select_and_accept" ];
          "<Tab>" = [ "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "snippet_backward" "fallback" ];
        };

        snippets = {
          preset = "default";
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
            enabled = false;
          };
        };

        sources = {
          default = [ "lsp" "path" "snippets" "buffer" ];
        };

        cmdline = {
          enabled = true;
          keymap = {
            preset = "cmdline";
            "<Right>" = false;
            "<Left>" = false;
          };
          completion = {
            list = {
              selection = {
                preselect = false;
              };
            };
            menu = {
              auto_show.__raw = ''
                function(ctx)
                  return vim.fn.getcmdtype() == ":"
                end
              '';
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
