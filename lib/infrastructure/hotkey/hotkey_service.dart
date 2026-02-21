import 'dart:async';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/services.dart';

class HotkeyService {
  static final HotkeyService _instance = HotkeyService._internal();
  factory HotkeyService() => _instance;
  HotkeyService._internal();

  final _startController = StreamController<void>.broadcast();
  final _stopController = StreamController<void>.broadcast();

  Stream<void> get onStart => _startController.stream;
  Stream<void> get onStop => _stopController.stream;

  bool _initialized = false;
  HotKey? _startHotkey;
  HotKey? _stopHotkey;

  Future<void> initialize() async {
    if (_initialized) return;
    await hotKeyManager.unregisterAll();
    _initialized = true;
  }

  Future<void> registerHotkeys({
    required Function onStart,
    required Function onStop,
  }) async {
    await unregisterHotkeys();

    _startHotkey = HotKey(
      key: PhysicalKeyboardKey.f9,
      modifiers: [],
      scope: HotKeyScope.system,
    );

    _stopHotkey = HotKey(
      key: PhysicalKeyboardKey.f10,
      modifiers: [],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      _startHotkey!,
      keyDownHandler: (hotKey) {
        onStart();
        _startController.add(null);
      },
    );

    await hotKeyManager.register(
      _stopHotkey!,
      keyDownHandler: (hotKey) {
        onStop();
        _stopController.add(null);
      },
    );
  }

  Future<void> unregisterHotkeys() async {
    if (_startHotkey != null) {
      await hotKeyManager.unregister(_startHotkey!);
      _startHotkey = null;
    }
    if (_stopHotkey != null) {
      await hotKeyManager.unregister(_stopHotkey!);
      _stopHotkey = null;
    }
  }

  void dispose() {
    unregisterHotkeys();
    _startController.close();
    _stopController.close();
  }
}
