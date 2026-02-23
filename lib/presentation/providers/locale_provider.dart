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
