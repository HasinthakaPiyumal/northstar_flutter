import 'package:flutter/material.dart';

class GlobalOverlayManager {
  static final GlobalOverlayManager _instance = GlobalOverlayManager._internal();

  factory GlobalOverlayManager() {
    return _instance;
  }

  GlobalOverlayManager._internal();

  static OverlayState? overlayState;

  static void initOverlay(OverlayState state) {
    overlayState = state;
  }

  static void showOverlay(Widget overlayWidget) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: overlayWidget,
            ),
          ),
        );
      },
    );

    overlayState?.insert(overlayEntry);
  }

  static void removeOverlay() {
    // overlayState?.clear();
    overlayState?.dispose();
  }
}
