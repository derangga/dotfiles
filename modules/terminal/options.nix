{ lib }:
{
  terminal.use = lib.mkOption {
    type = lib.types.enum [
      "kitty"
      "ghostty"
    ];
    default = "ghostty";
    description = "Which terminal emulator to use";
  };
}
