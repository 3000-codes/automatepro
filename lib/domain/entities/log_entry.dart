import 'package:equatable/equatable.dart';

/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warn,
  error;

  String get displayName {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  static LogLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'debug':
        return LogLevel.debug;
      case 'info':
        return LogLevel.info;
      case 'warn':
      case 'warning':
        return LogLevel.warn;
      case 'error':
        return LogLevel.error;
      default:
        return LogLevel.info;
    }
  }
}

/// 日志条目
class LogEntry extends Equatable {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? source;
  final Map<String, dynamic>? extra;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.source,
    this.extra,
  });

  /// 格式化时间戳为 "时:分:秒.毫秒"
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    final millisecond = timestamp.millisecond.toString().padLeft(3, '0');
    return '$hour:$minute:$second.$millisecond';
  }

  /// 转换为可序列化的 Map
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'source': source,
      'extra': extra,
    };
  }

  /// 从 Map 创建 LogEntry
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.fromString(json['level'] as String),
      message: json['message'] as String,
      source: json['source'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [timestamp, level, message, source, extra];
}

/// 日志过滤条件
class LogFilter extends Equatable {
  final Set<LogLevel> enabledLevels;
  final String? searchKeyword;
  final DateTime? startTime;
  final DateTime? endTime;

  const LogFilter({
    this.enabledLevels = const {
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warn,
      LogLevel.error,
    },
    this.searchKeyword,
    this.startTime,
    this.endTime,
  });

  LogFilter copyWith({
    Set<LogLevel>? enabledLevels,
    String? searchKeyword,
    DateTime? startTime,
    DateTime? endTime,
    bool clearKeyword = false,
    bool clearTimeRange = false,
  }) {
    return LogFilter(
      enabledLevels: enabledLevels ?? this.enabledLevels,
      searchKeyword: clearKeyword
          ? null
          : (searchKeyword ?? this.searchKeyword),
      startTime: clearTimeRange ? null : (startTime ?? this.startTime),
      endTime: clearTimeRange ? null : (endTime ?? this.endTime),
    );
  }

  /// 检查日志是否匹配过滤条件
  bool matches(LogEntry entry) {
    // 级别过滤
    if (!enabledLevels.contains(entry.level)) {
      return false;
    }

    // 关键词搜索
    if (searchKeyword != null && searchKeyword!.isNotEmpty) {
      final keyword = searchKeyword!.toLowerCase();
      final messageMatch = entry.message.toLowerCase().contains(keyword);
      final sourceMatch =
          entry.source?.toLowerCase().contains(keyword) ?? false;
      if (!messageMatch && !sourceMatch) {
        return false;
      }
    }

    // 时间范围过滤
    if (startTime != null && entry.timestamp.isBefore(startTime!)) {
      return false;
    }
    if (endTime != null && entry.timestamp.isAfter(endTime!)) {
      return false;
    }

    return true;
  }

  @override
  List<Object?> get props => [enabledLevels, searchKeyword, startTime, endTime];
}

/// 日志窗口设置
class LogSettings extends Equatable {
  final bool windowEnabled;
  final double windowOpacity;
  final double? windowX;
  final double? windowY;
  final double? windowWidth;
  final double? windowHeight;
  final int maxLogCount;
  final int autoSaveInterval;

  const LogSettings({
    this.windowEnabled = false,
    this.windowOpacity = 1.0,
    this.windowX,
    this.windowY,
    this.windowWidth,
    this.windowHeight,
    this.maxLogCount = 10000,
    this.autoSaveInterval = 60,
  });

  LogSettings copyWith({
    bool? windowEnabled,
    double? windowOpacity,
    double? windowX,
    double? windowY,
    double? windowWidth,
    double? windowHeight,
    int? maxLogCount,
    int? autoSaveInterval,
  }) {
    return LogSettings(
      windowEnabled: windowEnabled ?? this.windowEnabled,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      windowX: windowX ?? this.windowX,
      windowY: windowY ?? this.windowY,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      maxLogCount: maxLogCount ?? this.maxLogCount,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
    );
  }

  @override
  List<Object?> get props => [
    windowEnabled,
    windowOpacity,
    windowX,
    windowY,
    windowWidth,
    windowHeight,
    maxLogCount,
    autoSaveInterval,
  ];
}

/// 时间范围快速选择
enum TimeRangeOption {
  all,
  last5Minutes,
  last1Hour,
  today;

  String get displayName {
    switch (this) {
      case TimeRangeOption.all:
        return '全部';
      case TimeRangeOption.last5Minutes:
        return '最近 5 分钟';
      case TimeRangeOption.last1Hour:
        return '最近 1 小时';
      case TimeRangeOption.today:
        return '今天';
    }
  }

  (DateTime?, DateTime?) toTimeRange() {
    final now = DateTime.now();
    switch (this) {
      case TimeRangeOption.all:
        return (null, null);
      case TimeRangeOption.last5Minutes:
        return (now.subtract(const Duration(minutes: 5)), now);
      case TimeRangeOption.last1Hour:
        return (now.subtract(const Duration(hours: 1)), now);
      case TimeRangeOption.today:
        return (DateTime(now.year, now.month, now.day), now);
    }
  }
}
