import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import '../../domain/entities/log_entry.dart';

class LogNotifier extends StateNotifier<List<LogEntry>> {
  final _uuid = const Uuid();
  final _maxEntries = 1000;
  bool _autoScroll = true;
  bool _isRunning = false;

  LogNotifier() : super([]);

  bool get autoScroll => _autoScroll;
  bool get isRunning => _isRunning;

  void setAutoScroll(bool value) {
    _autoScroll = value;
  }

  void setRunning(bool running) {
    _isRunning = running;
  }

  void debug(String message, {String? details}) {
    _addLog(LogLevel.debug, message, details);
  }

  void info(String message, {String? details}) {
    _addLog(LogLevel.info, message, details);
  }

  void warn(String message, {String? details}) {
    _addLog(LogLevel.warn, message, details);
  }

  void error(String message, {String? details}) {
    _addLog(LogLevel.error, message, details);
  }

  void _addLog(LogLevel level, String message, String? details) {
    final entry = LogEntry(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      level: level,
      message: message,
      details: details,
    );

    state = [...state, entry];

    // Trim old entries if exceeds max
    if (state.length > _maxEntries) {
      state = state.sublist(state.length - _maxEntries);
    }
  }

  void clear() {
    state = [];
  }

  String getAllLogsAsText() {
    return state
        .map((entry) {
          final buffer = StringBuffer();
          buffer.write(
            '[${entry.formattedTime}] [${entry.levelString}] ${entry.message}',
          );
          if (entry.details != null) {
            buffer.write(' - ${entry.details}');
          }
          return buffer.toString();
        })
        .join('\n');
  }

  void copyToClipboard(BuildContext context) {
    final text = getAllLogsAsText();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

final logProvider = StateNotifierProvider<LogNotifier, List<LogEntry>>((ref) {
  return LogNotifier();
});

final showLogWindowProvider = StateProvider<bool>((ref) => false);

final logWindowOpacityProvider = StateProvider<double>((ref) => 0.85);

// Floating mode provider - when enabled, app becomes a small floating window
final floatingModeProvider = StateProvider<bool>((ref) => false);

// Window manager service for controlling window behavior
class WindowService {
  static final WindowService _instance = WindowService._internal();
  factory WindowService() => _instance;
  WindowService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await windowManager.ensureInitialized();
    _isInitialized = true;
  }

  Future<void> setAlwaysOnTop(bool onTop) async {
    await windowManager.setAlwaysOnTop(onTop);
  }

  Future<void> setOpacity(double opacity) async {
    await windowManager.setOpacity(opacity);
  }

  Future<void> setSize(Size size) async {
    await windowManager.setSize(size);
  }

  Future<void> setPosition(Offset position) async {
    await windowManager.setPosition(position);
  }

  Future<void> setMinimumSize(Size size) async {
    await windowManager.setMinimumSize(size);
  }

  Future<void> setResizable(bool resizable) async {
    await windowManager.setResizable(resizable);
  }

  Future<void> startDragging() async {
    await windowManager.startDragging();
  }

  Future<void> show() async {
    await windowManager.show();
  }

  Future<void> hide() async {
    await windowManager.hide();
  }

  Future<void> close() async {
    await windowManager.close();
  }

  Future<void> setTitle(String title) async {
    await windowManager.setTitle(title);
  }

  // Enter floating mode - small transparent window
  Future<void> enterFloatingMode(double opacity) async {
    await windowManager.setMinimumSize(const Size(350, 250));
    await windowManager.setSize(const Size(400, 300));
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setOpacity(opacity);
    await windowManager.setResizable(true);
    await windowManager.setTitle('AutoMate Pro - Logs');
  }

  // Exit floating mode - normal window
  Future<void> exitFloatingMode(double opacity) async {
    await windowManager.setMinimumSize(const Size(800, 550));
    await windowManager.setSize(const Size(900, 650));
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setOpacity(1.0);
    await windowManager.setResizable(true);
    await windowManager.setTitle('AutoMate Pro');
  }
}

final windowServiceProvider = Provider<WindowService>((ref) {
  return WindowService();
});
