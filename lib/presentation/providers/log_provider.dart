import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/log_entry.dart';

/// 日志设置持久化
class LogSettingsStorage {
  static const String _boxName = 'settings';
  static const String _logSettingsKey = 'log_settings';

  /// 加载设置
  static LogSettings load() {
    try {
      final box = Hive.box(_boxName);
      final json = box.get(_logSettingsKey);
      if (json != null) {
        final map = Map<String, dynamic>.from(jsonDecode(json as String));
        return LogSettings.fromJson(map);
      }
    } catch (e) {
      // 加载失败，使用默认设置
    }
    return const LogSettings();
  }

  /// 保存设置
  static void save(LogSettings settings) {
    try {
      final box = Hive.box(_boxName);
      box.put(_logSettingsKey, jsonEncode(settings.toJson()));
    } catch (e) {
      // 保存失败
    }
  }
}

/// 全局共享日志存储 - 用于多窗口间共享日志数据
class SharedLogStorage {
  static final List<LogEntry> _logs = [];
  static final _controller = StreamController<List<LogEntry>>.broadcast();

  /// 获取所有日志
  static List<LogEntry> get logs => List.unmodifiable(_logs);

  /// 日志变更流
  static Stream<List<LogEntry>> get logStream => _controller.stream;

  /// 添加日志
  static void addLog(LogEntry entry) {
    _logs.add(entry);
    _controller.add(List.unmodifiable(_logs));
  }

  /// 清空日志
  static void clear() {
    _logs.clear();
    _controller.add([]);
  }

  /// 获取过滤后的日志
  static List<LogEntry> getFilteredLogs(LogFilter filter) {
    return _logs.where((log) => filter.matches(log)).toList();
  }

  /// 获取窗口透明度
  static double get windowOpacity => LogSettingsStorage.load().windowOpacity;
}

/// 日志状态管理
class LogNotifier extends StateNotifier<List<LogEntry>> {
  final LogFilter _filter = const LogFilter();
  final int _maxLogs = 10000;

  LogNotifier() : super([]);

  /// 获取过滤后的日志
  List<LogEntry> get filteredLogs {
    return state.where((log) => _filter.matches(log)).toList();
  }

  /// 添加DEBUG级别日志
  void debug(String message, {String? source, Map<String, dynamic>? extra}) {
    _addLog(LogLevel.debug, message, source: source, extra: extra);
  }

  /// 添加INFO级别日志
  void info(String message, {String? source, Map<String, dynamic>? extra}) {
    _addLog(LogLevel.info, message, source: source, extra: extra);
  }

  /// 添加WARN级别日志
  void warn(String message, {String? source, Map<String, dynamic>? extra}) {
    _addLog(LogLevel.warn, message, source: source, extra: extra);
  }

  /// 添加ERROR级别日志
  void error(
    String message, {
    String? source,
    Map<String, dynamic>? extra,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final fullExtra = Map<String, dynamic>.from(extra ?? {});
    if (error != null) {
      fullExtra['error'] = error.toString();
    }
    if (stackTrace != null) {
      fullExtra['stackTrace'] = stackTrace.toString();
    }
    _addLog(
      LogLevel.error,
      message,
      source: source,
      extra: fullExtra.isEmpty ? null : fullExtra,
    );
  }

  void _addLog(
    LogLevel level,
    String message, {
    String? source,
    Map<String, dynamic>? extra,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      source: source,
      extra: extra,
    );

    // 同时更新本地状态和全局共享存储
    state = [...state, entry];
    SharedLogStorage.addLog(entry);

    // 超过最大数量时删除最早的日志
    if (state.length > _maxLogs) {
      state = state.sublist(state.length - _maxLogs);
    }
  }

  /// 清空所有日志
  void clear() {
    state = [];
  }

  /// 获取日志数量
  int get count => state.length;

  /// 导出为TXT格式
  String exportToTxt({bool filtered = true}) {
    final logs = filtered ? filteredLogs : state;
    return logs.map((log) => log.toReadableString()).join('\n');
  }

  /// 导出为JSON格式
  String exportToJson({bool filtered = true}) {
    final logs = filtered ? filteredLogs : state;
    return const JsonEncoder.withIndent('  ').convert({
      'exportTime': DateTime.now().toIso8601String(),
      'count': logs.length,
      'logs': logs.map((log) => log.toJson()).toList(),
    });
  }

  /// 导出为CSV格式
  String exportToCsv({bool filtered = true}) {
    final logs = filtered ? filteredLogs : state;
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Level,Source,Message');
    for (final log in logs) {
      final timestamp = log.timestamp.toIso8601String();
      final level = log.level.name;
      final source = log.source ?? '';
      final message = log.message.replaceAll('"', '""');
      buffer.writeln('"$timestamp","$level","$source","$message"');
    }
    return buffer.toString();
  }

  /// 导出到文件
  Future<String?> exportToFile(String path, String format) async {
    try {
      String content;
      String extension;

      switch (format) {
        case 'json':
          content = exportToJson();
          extension = 'json';
          break;
        case 'csv':
          content = exportToCsv();
          extension = 'csv';
          break;
        case 'txt':
        default:
          content = exportToTxt();
          extension = 'txt';
      }

      final file = File('$path.$extension');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      debug('Failed to export logs: $e', source: 'LogService');
      return null;
    }
  }
}

/// 日志过滤状态管理
class LogFilterNotifier extends StateNotifier<LogFilter> {
  LogFilterNotifier() : super(const LogFilter());

  /// 设置启用的日志级别
  void setLevels(Set<LogLevel> levels) {
    state = state.copyWith(enabledLevels: levels);
  }

  /// 切换日志级别
  void toggleLevel(LogLevel level) {
    final newLevels = Set<LogLevel>.from(state.enabledLevels);
    if (newLevels.contains(level)) {
      newLevels.remove(level);
    } else {
      newLevels.add(level);
    }
    state = state.copyWith(enabledLevels: newLevels);
  }

  /// 设置搜索关键词
  void setSearchKeyword(String? keyword) {
    if (keyword == null || keyword.isEmpty) {
      state = state.copyWith(clearSearch: true);
    } else {
      state = state.copyWith(searchKeyword: keyword);
    }
  }

  /// 清除搜索
  void clearSearch() {
    state = state.copyWith(clearSearch: true);
  }

  /// 设置时间范围
  void setTimeRange(DateTime? start, DateTime? end) {
    if (start == null && end == null) {
      state = state.copyWith(clearTimeRange: true);
    } else {
      state = state.copyWith(startTime: start, endTime: end);
    }
  }

  /// 清除时间范围
  void clearTimeRange() {
    state = state.copyWith(clearTimeRange: true);
  }

  /// 全部显示
  void showAll() {
    state = LogFilter(enabledLevels: LogLevel.values.toSet());
  }

  /// 仅显示错误
  void showErrorsOnly() {
    state = const LogFilter(enabledLevels: {LogLevel.error});
  }

  /// 显示警告和错误
  void showWarningsAndErrors() {
    state = const LogFilter(enabledLevels: {LogLevel.warn, LogLevel.error});
  }
}

/// 日志设置状态管理
class LogSettingsNotifier extends StateNotifier<LogSettings> {
  Timer? _autoSaveTimer;

  LogSettingsNotifier() : super(const LogSettings()) {
    // 加载保存的设置
    _loadSettings();
  }

  void _loadSettings() {
    state = LogSettingsStorage.load();
  }

  void _saveSettings() {
    LogSettingsStorage.save(state);
  }

  /// 设置是否启用持久化
  void setPersistEnabled(bool enabled) {
    state = state.copyWith(persistEnabled: enabled);
    _saveSettings();
    if (enabled) {
      _startAutoSave();
    } else {
      _stopAutoSave();
    }
  }

  /// 设置保存路径
  void setSavePath(String path) {
    state = state.copyWith(savePath: path);
    _saveSettings();
  }

  /// 设置文件命名方式
  void setFileNaming(String naming) {
    state = state.copyWith(fileNaming: naming);
    _saveSettings();
  }

  /// 设置自动保存间隔（分钟）
  void setAutoSaveInterval(int minutes) {
    state = state.copyWith(autoSaveInterval: minutes);
    _saveSettings();
    if (state.persistEnabled) {
      _startAutoSave();
    }
  }

  /// 设置保留天数
  void setRetentionDays(int days) {
    state = state.copyWith(retentionDays: days);
    _saveSettings();
  }

  /// 设置最大日志数量
  void setMaxLogCount(int count) {
    state = state.copyWith(maxLogCount: count);
    _saveSettings();
  }

  /// 设置是否默认开启日志窗口
  void setWindowEnabled(bool enabled) {
    state = state.copyWith(windowEnabled: enabled);
    _saveSettings();
  }

  /// 设置日志窗口透明度
  void setWindowOpacity(double opacity) {
    state = state.copyWith(windowOpacity: opacity.clamp(0.1, 1.0));
    _saveSettings();
  }

  /// 设置日志窗口位置和大小
  void setWindowBounds({double? x, double? y, double? width, double? height}) {
    state = state.copyWith(
      windowX: x,
      windowY: y,
      windowWidth: width,
      windowHeight: height,
    );
    _saveSettings();
  }

  void _startAutoSave() {
    _stopAutoSave();
    if (state.autoSaveInterval > 0) {
      _autoSaveTimer = Timer.periodic(
        Duration(minutes: state.autoSaveInterval),
        (_) => _performAutoSave(),
      );
    }
  }

  void _stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  Future<void> _performAutoSave() async {
    // 自动保存逻辑会在LogService中实现
    // 这里可以触发事件通知
  }

  @override
  void dispose() {
    _stopAutoSave();
    super.dispose();
  }
}

// ============== Providers ==============

/// 日志列表Provider
final logProvider = StateNotifierProvider<LogNotifier, List<LogEntry>>((ref) {
  return LogNotifier();
});

/// 日志过滤Provider
final logFilterProvider = StateNotifierProvider<LogFilterNotifier, LogFilter>((
  ref,
) {
  return LogFilterNotifier();
});

/// 日志设置Provider
final logSettingsProvider =
    StateNotifierProvider<LogSettingsNotifier, LogSettings>((ref) {
      return LogSettingsNotifier();
    });

/// 过滤后的日志列表Provider
final filteredLogsProvider = Provider<List<LogEntry>>((ref) {
  final logs = ref.watch(logProvider);
  final filter = ref.watch(logFilterProvider);
  return logs.where((log) => filter.matches(log)).toList();
});

/// 日志数量Provider
final logCountProvider = Provider<int>((ref) {
  return ref.watch(logProvider).length;
});

/// 过滤后日志数量Provider
final filteredLogCountProvider = Provider<int>((ref) {
  return ref.watch(filteredLogsProvider).length;
});

/// 获取默认日志保存目录
Future<String> getDefaultLogPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return '${directory.path}/AutoMatePro/Logs';
}
