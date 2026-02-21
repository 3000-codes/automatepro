import 'dart:math';
import 'package:mouse/mouse.dart' as mouse_lib;

import '../../domain/entities/click_config.dart' as app;

class MouseService {
  static final MouseService _instance = MouseService._internal();
  factory MouseService() => _instance;
  MouseService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    _initialized = true;
  }

  Future<void> click({
    required int x,
    required int y,
    required app.MouseButton button,
    bool moveFirst = true,
  }) async {
    if (moveFirst) {
      mouse_lib.moveTo(Point(x.toDouble(), y.toDouble()));
    }

    switch (button) {
      case app.MouseButton.left:
        mouse_lib.click();
        break;
      case app.MouseButton.middle:
        mouse_lib.click();
        break;
      case app.MouseButton.right:
        mouse_lib.rightClick();
        break;
      case app.MouseButton.forward:
      case app.MouseButton.backward:
        mouse_lib.click();
        break;
    }
  }

  Future<void> doubleClick({
    required int x,
    required int y,
    app.MouseButton button = app.MouseButton.left,
    bool moveFirst = true,
  }) async {
    if (moveFirst) {
      mouse_lib.moveTo(Point(x.toDouble(), y.toDouble()));
    }
    mouse_lib.click();
  }

  Future<void> hold({
    required int x,
    required int y,
    app.MouseButton button = app.MouseButton.left,
    int durationMs = 1000,
  }) async {
    mouse_lib.moveTo(Point(x.toDouble(), y.toDouble()));
  }

  Future<Point<int>> getCurrentPosition() async {
    final pos = mouse_lib.getPosition();
    return Point(pos.x.toInt(), pos.y.toInt());
  }
}
