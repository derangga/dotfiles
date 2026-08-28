{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    openscreen
    dbeaver-bin

    # flutter installation
    cocoapods
    flutter
    jdk17
  ];

  # The Android SDK is the official one under ~/Library/Android/sdk, managed by
  # Android Studio. Nix only points Flutter and Gradle at it.
  home.sessionVariables = {
    ANDROID_HOME = "$HOME/Library/Android/sdk";
    JAVA_HOME = "${pkgs.jdk17.home}";
    CHROME_EXECUTABLE = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome";
  };

  home.sessionPath = [
    "$HOME/Library/Android/sdk/platform-tools" # adb
    "$HOME/Library/Android/sdk/emulator"
    "$HOME/Library/Android/sdk/cmdline-tools/latest/bin" # sdkmanager, avdmanager
    "$HOME/.pub-cache/bin" # `dart pub global activate` binaries
  ];

  catppuccin.obs.enable = true;
}
