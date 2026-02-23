import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/log_entry.dart';
import '../../infrastructure/services/log_settings_storage.dart';

/// 日志状态
class LogState extends Equatable {
  final List<LogEntry> logs;
  final int maxLogCount;
  final bool autoScroll;

  const LogState({
    this.logs = const [],
    this.maxLogCount = 10000,
    this.autoScroll = true,
  });

  LogState copyWith({
    List<LogEntry>? logs,
    int? maxLogCount,
    bool? autoScroll,
  }) {
    return LogState(
      logs: logs ?? this.logs,
      maxLogCount: maxLogCount ?? this.maxLogCount,
      autoScroll: autoScroll ?? this.autoScroll,
    );
  }

  @override
  List<Object?> get props => [logs, maxLogCount, autoScroll];
}

/// 日志管理器
class LogNotifier extends StateNotifier<LogState> {
  final LogSettingsStorage _settingsStorage;

  LogNotifier(this._settingsStorage) : super(const LogState()) {
    _initialize();
  }

  void _initialize() {
    final maxCount = _settingsStorage.getMaxLogCount();
    state = state.copyWith(maxLogCount: maxCount);
  }

  /// 添加日志
  void addLog(LogEntry entry) {
    final newLogs = [...state.logs, entry];

    // 超过最大数量时删除旧日志
    if (newLogs.length > state.maxLogCount) {
      newLogs.removeRange(0, newLogs.length - state.maxLogCount);
    }

    state = state.copyWith(logs: newLogs);
  }

  /// 快捷添加日志方法
  void log(
    LogLevel level,
    String message, {
    String? source,
    Map<String, dynamic>? extra,
  }) {
    addLog(
      LogEntry(
        timestamp: DateTime.now(),
        level: level,
        message: message,
        source: source,
        extra: extra,
      ),
    );
  }

  /// 快捷方法 - Debug 级别
  void debug(String message, {String? source, Map<String, dynamic>? extra}) {
    log(LogLevel.debug, message, source: source, extra: extra);
  }

  /// 快捷方法 - Info 级别
  void info(String message, {String? source, Map<String, dynamic>? extra}) {
    log(LogLevel.info, message, source: source, extra: extra);
  }

  /// 快捷方法 - Warn 级别
  void warn(String message, {String? source, Map<String, dynamic>? extra}) {
    log(LogLevel.warn, message, source: source, extra: extra);
  }

  /// 快捷方法 - Error 级别
  void error(String message, {String? source, Map<String, dynamic>? extra}) {
    log(LogLevel.error, message, source: source, extra: extra);
  }

  /// 清空所有日志
  void clearLogs() {
    state = state.copyWith(logs: []);
  }

  /// 获取所有日志
  List<LogEntry> getLogs() {
    return state.logs;
  }

  /// 获取日志总数
  int getTotalCount() {
    return state.logs.length;
  }

  /// 设置自动滚动
  void setAutoScroll(bool value) {
    state = state.copyWith(autoScroll: value);
  }

  /// 设置最大日志数量
  void setMaxLogCount(int count) async {
    await _settingsStorage.setMaxLogCount(count);
    state = state.copyWith(maxLogCount: count);

    // 如果当前日志超过限制，裁剪日志
    if (state.logs.length > count) {
      final newLogs = state.logs.sublist(state.logs.length - count);
      state = state.copyWith(logs: newLogs);
    }
  }
}

/// 日志设置 Provider
final logSettingsStorageProvider = Provider<LogSettingsStorage>((ref) {
  return LogSettingsStorage();
});

/// 日志管理器 Provider
final logProvider = StateNotifierProvider<LogNotifier, LogState>((ref) {
  final settingsStorage = ref.watch(logSettingsStorageProvider);
  return LogNotifier(settingsStorage);
});

/// 便捷访问日志列表
final logsProvider = Provider<List<LogEntry>>((ref) {
  return ref.watch(logProvider).logs;
});

/// 便捷访问日志总数
final logCountProvider = Provider<int>((ref) {
  return ref.watch(logProvider).logs.length;
});

/// 自动滚动状态 Provider
final autoScrollProvider = Provider<bool>((ref) {
  return ref.watch(logProvider).autoScroll;
});
