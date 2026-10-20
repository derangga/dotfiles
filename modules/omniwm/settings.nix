# OmniWM's settings.toml, schema v4. The whole file is rejected when a required
# key is missing, so every section below is complete, defaults included. The
# Settings window writes to the same file and the next switch overwrites it.
{ lib }:
let
  digits = map toString (lib.range 1 9);

  # Action ids count workspaces and columns from 0.
  perDigit = lib.mergeAttrsList (
    lib.imap0 (i: n: {
      "switchWorkspace.${toString i}" = "Option+${n}";
      "moveToWorkspace.${toString i}" = "Option+Shift+${n}";
      "focusColumn.${toString i}" = "Control+Option+${n}";
    }) digits
  );

  # Action id to binding. An action left out is unassigned.
  hotkeys = perDigit // {
    "focus.left" = "Option+H";
    "focus.down" = "Option+J";
    "focus.up" = "Option+K";
    "focus.right" = "Option+L";
    focusPrevious = "Control+Option+Tab";
    focusColumnFirst = "Option+Home";
    focusColumnLast = "Option+End";
    focusMonitorNext = "Control+Command+Tab";
    focusMonitorLast = "Control+Command+Grave";

    "move.left" = "Option+Shift+H";
    "move.down" = "Option+Shift+J";
    "move.up" = "Option+Shift+K";
    "move.right" = "Option+Shift+L";
    "moveColumn.left" = "Control+Option+Shift+Left Arrow";
    "moveColumn.right" = "Control+Option+Shift+Right Arrow";
    moveColumnToFirst = "Control+Option+Home";
    moveColumnToLast = "Control+Option+End";
    moveWindowToWorkspaceUp = "Control+Option+Shift+Up Arrow";
    moveWindowToWorkspaceDown = "Control+Option+Shift+Down Arrow";
    moveColumnToWorkspaceUp = "Control+Option+Shift+Page Up";
    moveColumnToWorkspaceDown = "Control+Option+Shift+Page Down";

    workspaceBackAndForth = "Option+Tab";
    toggleWorkspaceLayout = "Option+Slash";
    toggleOverview = "Option+Shift+O";

    toggleFullscreen = "Option+Shift+F";
    toggleFocusedWindowFloating = "Option+F";
    raiseAllFloatingWindows = "Option+Shift+R";
    toggleColumnTabbed = "Option+T";

    "setContainerPrimarySpan.decrease10Percent" = "Option+Shift+Minus";
    "setContainerPrimarySpan.increase10Percent" = "Option+Shift+Equal";
    "setWindowSecondarySpan.decrease10Percent" = "Option+Minus";
    "setWindowSecondarySpan.increase10Percent" = "Option+Equal";
    toggleContainerFullPrimarySpan = "Option+Return";
    expandContainerToAvailablePrimarySpan = "Control+Option+F";
    resetWindowSecondarySpan = "Control+Option+R";
    cycleSizeForward = "Option+Period";
    cycleSizeBackward = "Option+Comma";
    balanceSizes = "Option+Shift+B";

    openCommandPalette = "Control+Option+Space";
    openMenuAnywhere = "Control+Option+M";
  };

  # OmniWM generated these ids and its window restore state refers to them, so
  # they stay fixed. Position in the list is the workspace number.
  workspaceIds = [
    "AD36F001-C57E-41A5-AC1D-DF5249D007F0"
    "454CECD4-5E9D-4ED1-95D7-979D48817F5F"
    "BEB842B5-E894-4791-9FD1-397C3CDD3538"
    "248AA883-2261-4D45-943C-79C0E46A232B"
    "8B8C45D6-CE9E-41D9-BD50-BE4989D5E3DE"
    "5953F2BF-A378-4266-91B2-287174C4FA4D"
    "A7D5E104-6985-4516-8ED5-07F144F2A33D"
    "0E18F6B0-345A-4078-8B21-33641F07A861"
    "8D4D711C-2B2F-4FEC-86BF-FA952037738A"
  ];
  onSecondaryMonitor = [
    "6"
    "7"
  ];

  # OmniWM's stock minimum window sizes, kept as it exported them.
  minSize = id: bundleId: minWidth: minHeight: {
    inherit
      id
      bundleId
      minWidth
      minHeight
      ;
  };
in
{
  hotkeys = lib.mapAttrsToList (id: binding: { inherit id binding; }) hotkeys;

  workspaces = lib.zipListsWith (name: id: {
    inherit id name;
    layoutType = "niri";
    monitorAssignment.type = if lib.elem name onSecondaryMonitor then "secondary" else "main";
  }) digits workspaceIds;

  appRules = [
    (minSize "6A31F08A-4051-4354-B439-42F4C71894A3" "com.openai.codex" 800.0 600.0)
    (minSize "4BA546DA-2875-4BEF-B13F-1539E833B1A0" "com.eltima.cmd1.pro.mas" 950.0 550.0)
    (minSize "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B" "com.google.Chrome" 500.0 375.0)
    (minSize "979F05F4-FFA2-4EDD-B23F-08A9944C759F" "dev.zed.Zed" 360.0 240.0)
    (minSize "81426D13-C1A5-475E-AFBC-00BBA05042D0" "com.apple.Safari" 574.0 220.0)
    (minSize "1CF39647-F30D-4E76-9686-79B551F1B094" "app.zen-browser.zen" 500.0 495.0)
    (minSize "005C00D3-F665-47F8-BDAE-D80790E9E46B" "org.mozilla.firefox" 500.0 120.0)
    (minSize "C21156B1-0224-4998-97E3-8F4FA65B9F3B" "company.thebrowser.dia" 500.0 420.0)
    (minSize "2DE9390B-0DB4-4D0C-9ABA-06F76F1D4EA9" "com.spotify.client" 800.0 600.0)
    (minSize "AF752D95-8497-4844-BE20-4C93E73BAEF2" "com.hnc.Discord" 800.0 500.0)
    (minSize "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE" "com.mitchellh.ghostty" 90.0 48.0)
    (minSize "8ECAB78B-BCDD-4245-BC25-1609A49B1C86" "com.microsoft.Outlook" 930.0 650.0)
    (minSize "552FB77D-BF0E-4737-90A6-B5BC6986C579" "com.apple.MobileSMS" 660.0 320.0)
  ];

  appearance = {
    mode = "dark";
    tabRailAppIcons = false;
  };
  borders = {
    color = {
      alpha = 1.0;
      blue = 0.8941;
      green = 0.7686;
      red = 0.4902;
    };
    enabled = true;
    width = 2.0;
  };
  clipboard = {
    historyEnabled = false;
    ignoredTypes = [ ];
    maxItemBytes = 8388608;
    maxItems = 200;
    maxTotalBytes = 67108864;
  };
  dwindle = {
    defaultSplitRatio = 1.0;
    moveToRootStable = true;
    singleWindowFit = "fill";
    smartSplit = false;
    splitWidthMultiplier = 1.0;
    useGlobalGaps = true;
  };
  focus = {
    crossesMonitorAtEdge = false;
    followsMouse = false;
    followsWindowToMonitor = false;
    lockModifier = "off";
    moveCrossesMonitorAtEdge = false;
    moveMouseToFocusedWindow = false;
    raiseOnMouseFocus = false;
  };
  gaps = {
    fullscreenUsesOuterGaps = true;
    outer = {
      bottom = 6.0;
      left = 6.0;
      right = 6.0;
      top = 6.0;
    };
    size = 6.0;
  };
  general = {
    animationSpeed = 1.0;
    animationsEnabled = true;
    defaultLayoutType = "niri";
    hotkeysEnabled = true;
    hyperKeyModifiers = "Control+Option+Shift+Command";
    ipcEnabled = false;
    preventSleepEnabled = false;
    systemHyperTrigger = "None";
    updateChecksEnabled = true;
  };
  gestures = {
    fingerCount = 3;
    invertDirection = true;
    mouseMoveModifierKey = "option";
    mouseResizeModifierKey = "option";
    overviewGestureEnabled = false;
    overviewGestureFingerCount = 4;
    scrollEnabled = true;
    scrollModifierKey = "optionShift";
    scrollSensitivity = 5.0;
    trackpadScrollStyle = "snap";
    windowGestureSensitivity = 1.0;
    windowMoveEnabled = false;
    windowMoveFingerCount = 4;
    windowResizeEnabled = false;
    windowResizeFingerCount = 3;
    workspaceSwipeAxis = "vertical";
    workspaceSwipeEnabled = false;
    workspaceSwipeFingerCount = 3;
  };
  hiddenBar = {
    enabled = false;
    hiddenBundleIDs = [ ];
    rehideIntervalSeconds = 5.0;
  };
  monitorBarOverrides = [ ];
  monitorDwindleOverrides = [ ];
  monitorGapOverrides = [ ];
  monitorNiriOverrides = [ ];
  monitorOrientationOverrides = [ ];
  mouseWarp = {
    constrainToArrangement = false;
    enabled = true;
    margin = 1;
  };
  niri = {
    alwaysCenterSingleColumn = false;
    centerFocusedColumn = "never";
    containerPrimarySpanPresets = [
      0.3333333333333333
      0.5
      0.6666666666666666
    ];
    defaultContainerPrimarySpan = 1.0;
    edgeGaps = false;
    infiniteLoop = false;
    resizeStepPercent = 5;
    singleWindowFit = "fill";
    visibleContainerCount = 2;
  };
  overview = {
    backdrop = {
      alpha = 0.0;
      blue = 0.08;
      green = 0.05;
      red = 0.05;
    };
    enabled = true;
    invertScrollDirection = false;
    matchFocusBorder = true;
    mouseScrollSpeed = 1.0;
    windowBorders = {
      hovered = {
        alpha = 1.0;
        blue = 1.0;
        green = 0.6;
        red = 0.4;
      };
      normal = {
        alpha = 0.5;
        blue = 0.35;
        green = 0.3;
        red = 0.3;
      };
      selected = {
        alpha = 1.0;
        blue = 0.4;
        green = 0.8;
        red = 0.3;
      };
    };
    zoom = 1.0;
  };
  quakeTerminal = {
    animationDuration = 0.2;
    autoHide = false;
    backgroundBlurRadius = 0;
    backgroundEffect = "standardBlur";
    enabled = false;
    heightPercent = 50.0;
    monitorMode = "focusedWindow";
    opacity = 1.0;
    position = "center";
    widthPercent = 50.0;
  };
  routing = {
    arrangements = [ ];
    mode = "macOS";
  };
  schemaVersion = 4;
  scratchpads = {
    labels = { };
  };
  statusBar = {
    showAppNames = false;
    showIcon = true;
    showWorkspaceName = false;
    useWorkspaceId = false;
  };
  workspaceBar = {
    autoHide = true;
    autoHideHideDelayMilliseconds = 100.0;
    autoHideRevealDelayMilliseconds = 0.0;
    backgroundOpacity = 0.1;
    deduplicateAppIcons = false;
    enabled = true;
    excludedBundleIDs = [ ];
    height = 24.0;
    hideEmptyWorkspaces = false;
    hideInNativeFullscreen = false;
    hoverPreviewsEnabled = true;
    iconOverrides = { };
    notchActiveZoneWidth = 180.0;
    notchMode = "moveBelowMenuBar";
    notificationBadgeRefreshIntervalSeconds = 5.0;
    notificationBadges = "off";
    position = "right";
    reserveLayoutSpace = false;
    revealHoldMilliseconds = 200.0;
    revealModifier = "off";
    showAccentHighlights = true;
    showFloatingWindows = false;
    showItemBackgrounds = true;
    showLabels = true;
    solidBlackBackground = false;
    systemStatsButton = false;
    transparentBackground = false;
    windowLevel = "status";
    xOffset = 0.0;
    yOffset = 0.0;
  };

}
