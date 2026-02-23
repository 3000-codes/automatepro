import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../infrastructure/services/log_settings_storage.dart';
import 'log_provider.dart';

/// 日志窗口状态
enum LogWindowState { closed, opening, open, closing }

/// 日志窗口控制器 - 使用独立窗口实现
class LogWindowController extends ChangeNotifier {
  final LogSettingsStorage _settingsStorage;

  WindowController? _windowController;
  LogWindowState _state = LogWindowState.closed;
  double _opacity = 1.0;
  bool _alwaysOnTop = false;

  LogWindowController(this._settingsStorage);

  LogWindowState get state => _state;
  double get opacity => _opacity;
  bool get alwaysOnTop => _alwaysOnTop;
  bool get isOpen => _state == LogWindowState.open;
  String? get windowId => _windowController?.windowId;

  /// 初始化
  Future<void> initialize() async {
    _opacity = _settingsStorage.getWindowOpacity();
  }

  /// 打开日志窗口
  Future<void> openWindow() async {
    if (_state == LogWindowState.open || _state == LogWindowState.opening) {
      return;
    }

    _state = LogWindowState.opening;
    notifyListeners();

    try {
      // 创建新窗口 - 使用 WindowController.create
      final window = await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode({'windowType': 'log'}),
          hiddenAtLaunch: true,
        ),
      );

      _windowController = window;

      // 显示窗口
      await window.show();

      _state = LogWindowState.open;
      notifyListeners();
    } catch (e) {
      _state = LogWindowState.closed;
      notifyListeners();
      debugPrint('Failed to open log window: $e');
    }
  }

  /// 关闭日志窗口
  Future<void> closeWindow() async {
    if (_windowController == null) return;

    _state = LogWindowState.closing;
    notifyListeners();

    try {
      await _windowController!.hide();
    } catch (e) {
      debugPrint('Failed to close log window: $e');
    }

    _windowController = null;
    _state = LogWindowState.closed;
    notifyListeners();
  }

  /// 切换窗口显示状态
  Future<void> toggleWindow() async {
    if (isOpen) {
      await closeWindow();
    } else {
      await openWindow();
    }
  }

  /// 设置窗口透明度
  Future<void> setOpacity(double opacity) async {
    _opacity = opacity.clamp(0.3, 1.0);
    await _settingsStorage.setWindowOpacity(_opacity);

    // 使用 window_manager 设置透明度
    try {
      await windowManager.setOpacity(_opacity);
    } catch (e) {
      debugPrint('Failed to set window opacity: $e');
    }

    notifyListeners();
  }

  /// 设置窗口置顶状态
  Future<void> setAlwaysOnTop(bool alwaysOnTop) async {
    _alwaysOnTop = alwaysOnTop;

    // 使用 window_manager 设置置顶
    try {
      await windowManager.setAlwaysOnTop(alwaysOnTop);
    } catch (e) {
      debugPrint('Failed to set always on top: $e');
    }

    notifyListeners();
  }

  /// 处理窗口关闭事件
  void handleWindowClosed() {
    _windowController = null;
    _state = LogWindowState.closed;
    notifyListeners();
  }
}

/// 日志窗口控制器 Provider
final logWindowControllerProvider = ChangeNotifierProvider<LogWindowController>(
  (ref) {
    final settingsStorage = ref.watch(logSettingsStorageProvider);
    return LogWindowController(settingsStorage);
  },
);

/// 日志窗口是否显示
final logWindowVisibleProvider = Provider<bool>((ref) {
  final controller = ref.watch(logWindowControllerProvider);
  return controller.isOpen;
});

/// 日志窗口透明度
final logWindowOpacityProvider = Provider<double>((ref) {
  final controller = ref.watch(logWindowControllerProvider);
  return controller.opacity;
});
