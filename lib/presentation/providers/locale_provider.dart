import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('zh');
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// 主窗口透明度Provider
final mainWindowOpacityProvider = StateProvider<double>((ref) {
  return 1.0;
});

/// 日志窗口透明度Provider
final logWindowOpacityProvider = StateProvider<double>((ref) {
  return 1.0;
});

/// 是否显示日志窗口Provider
final showLogWindowProvider = StateProvider<bool>((ref) {
  return true;
});

/// 浮动模式Provider（仅显示日志）
final floatingModeProvider = StateProvider<bool>((ref) {
  return false;
});
