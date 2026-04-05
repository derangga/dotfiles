{ lib }:
{
  terminal.use = lib.mkOption {
    type = lib.types.enum [
      "kitty"
      "ghostty"
    ];
    default = "kitty";
    description = "Which terminal emulator to use";
  };
}
