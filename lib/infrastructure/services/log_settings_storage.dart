import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/log_entry.dart';

/// 日志设置存储键
class LogStorageKeys {
  static const String windowEnabled = 'log_window_enabled';
  static const String windowOpacity = 'log_window_opacity';
  static const String windowX = 'log_window_x';
  static const String windowY = 'log_window_y';
  static const String windowWidth = 'log_window_width';
  static const String windowHeight = 'log_window_height';
  static const String maxLogCount = 'log_max_count';
  static const String autoSaveInterval = 'log_auto_save_interval';
  static const String levelDebug = 'log_level_debug';
  static const String levelInfo = 'log_level_info';
  static const String levelWarn = 'log_level_warn';
  static const String levelError = 'log_level_error';
}

/// 日志设置存储服务
class LogSettingsStorage {
  static const String _boxName = 'log_settings';

  Box get _box => Hive.box(_boxName);

  /// 检查是否已初始化
  bool get isInitialized => Hive.isBoxOpen(_boxName);

  /// 确保已初始化
  void _ensureInitialized() {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError(
        'LogSettingsStorage not initialized. Hive box "log_settings" is not open.',
      );
    }
  }

  /// 获取窗口是否默认开启
  bool getWindowEnabled() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.windowEnabled, defaultValue: false);
  }

  /// 设置窗口是否默认开启
  Future<void> setWindowEnabled(bool value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.windowEnabled, value);
  }

  /// 获取窗口透明度
  double getWindowOpacity() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.windowOpacity, defaultValue: 1.0);
  }

  /// 设置窗口透明度
  Future<void> setWindowOpacity(double value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.windowOpacity, value);
  }

  /// 获取窗口位置 X
  double? getWindowX() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.windowX);
  }

  /// 设置窗口位置 X
  Future<void> setWindowX(double value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.windowX, value);
  }

  /// 获取窗口位置 Y
  double? getWindowY() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.windowY);
  }

  /// 设置窗口位置 Y
  Future<void> setWindowY(double value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.windowY, value);
  }

  /// 获取窗口宽度
  double? getWindowWidth() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.windowWidth);
  }

  /// 设置窗口宽度
  Future<void> setWindowWidth(double value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.windowWidth, value);
  }

  /// 获取窗口高度
  double? getWindowHeight() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.windowHeight);
  }

  /// 设置窗口高度
  Future<void> setWindowHeight(double value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.windowHeight, value);
  }

  /// 获取最大日志数量
  int getMaxLogCount() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.maxLogCount, defaultValue: 10000);
  }

  /// 设置最大日志数量
  Future<void> setMaxLogCount(int value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.maxLogCount, value);
  }

  /// 获取自动保存间隔
  int getAutoSaveInterval() {
    _ensureInitialized();
    return _box.get(LogStorageKeys.autoSaveInterval, defaultValue: 60);
  }

  /// 设置自动保存间隔
  Future<void> setAutoSaveInterval(int value) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.autoSaveInterval, value);
  }

  /// 获取日志级别过滤设置
  Set<LogLevel> getEnabledLevels() {
    _ensureInitialized();
    final levels = <LogLevel>{};
    if (_box.get(LogStorageKeys.levelDebug, defaultValue: true)) {
      levels.add(LogLevel.debug);
    }
    if (_box.get(LogStorageKeys.levelInfo, defaultValue: true)) {
      levels.add(LogLevel.info);
    }
    if (_box.get(LogStorageKeys.levelWarn, defaultValue: true)) {
      levels.add(LogLevel.warn);
    }
    if (_box.get(LogStorageKeys.levelError, defaultValue: true)) {
      levels.add(LogLevel.error);
    }
    return levels;
  }

  /// 设置日志级别过滤
  Future<void> setEnabledLevels(Set<LogLevel> levels) async {
    _ensureInitialized();
    await _box.put(LogStorageKeys.levelDebug, levels.contains(LogLevel.debug));
    await _box.put(LogStorageKeys.levelInfo, levels.contains(LogLevel.info));
    await _box.put(LogStorageKeys.levelWarn, levels.contains(LogLevel.warn));
    await _box.put(LogStorageKeys.levelError, levels.contains(LogLevel.error));
  }

  /// 获取完整的日志设置
  LogSettings getSettings() {
    _ensureInitialized();
    return LogSettings(
      windowEnabled: getWindowEnabled(),
      windowOpacity: getWindowOpacity(),
      windowX: getWindowX(),
      windowY: getWindowY(),
      windowWidth: getWindowWidth(),
      windowHeight: getWindowHeight(),
      maxLogCount: getMaxLogCount(),
      autoSaveInterval: getAutoSaveInterval(),
    );
  }

  /// 保存完整的日志设置
  Future<void> saveSettings(LogSettings settings) async {
    _ensureInitialized();
    await setWindowEnabled(settings.windowEnabled);
    await setWindowOpacity(settings.windowOpacity);
    if (settings.windowX != null) await setWindowX(settings.windowX!);
    if (settings.windowY != null) await setWindowY(settings.windowY!);
    if (settings.windowWidth != null)
      await setWindowWidth(settings.windowWidth!);
    if (settings.windowHeight != null)
      await setWindowHeight(settings.windowHeight!);
    await setMaxLogCount(settings.maxLogCount);
    await setAutoSaveInterval(settings.autoSaveInterval);
  }

  /// 保存窗口位置和大小
  Future<void> saveWindowPosition(
    double x,
    double y,
    double width,
    double height,
  ) async {
    _ensureInitialized();
    await setWindowX(x);
    await setWindowY(y);
    await setWindowWidth(width);
    await setWindowHeight(height);
  }

  /// 清除所有设置
  Future<void> clearAll() async {
    _ensureInitialized();
    await _box.clear();
  }
}
