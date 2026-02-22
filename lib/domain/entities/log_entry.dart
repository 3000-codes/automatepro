import 'package:equatable/equatable.dart';

/// 日志级别枚举
enum LogLevel { debug, info, warn, error }

/// 日志条目模型
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

  @override
  List<Object?> get props => [timestamp, level, message, source, extra];

  /// 转换为可读文本
  String toReadableString() {
    final timeStr = _formatTimestamp(timestamp);
    final levelStr = level.name.toUpperCase().padRight(5);
    final sourceStr = source != null ? '[$source] ' : '';
    return '$timeStr [$levelStr] $sourceStr$message';
  }

  /// 转换为JSON对象
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'source': source,
      'extra': extra,
    };
  }

  /// 从JSON创建
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'] as String,
      source: json['source'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

/// 日志过滤条件
class LogFilter extends Equatable {
  final Set<LogLevel> enabledLevels;
  final String? searchKeyword;
  final DateTime? startTime;
  final DateTime? endTime;

  const LogFilter({
    this.enabledLevels = const {LogLevel.info, LogLevel.warn, LogLevel.error},
    this.searchKeyword,
    this.startTime,
    this.endTime,
  });

  LogFilter copyWith({
    Set<LogLevel>? enabledLevels,
    String? searchKeyword,
    DateTime? startTime,
    DateTime? endTime,
    bool clearSearch = false,
    bool clearTimeRange = false,
  }) {
    return LogFilter(
      enabledLevels: enabledLevels ?? this.enabledLevels,
      searchKeyword: clearSearch ? null : (searchKeyword ?? this.searchKeyword),
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

/// 日志设置
class LogSettings extends Equatable {
  final bool persistEnabled;
  final String savePath;
  final String fileNaming; // 'date', 'session', 'fixed'
  final int autoSaveInterval; // minutes, 0 = realtime
  final int retentionDays;
  final int maxLogCount;

  // 日志窗口设置
  final bool windowEnabled; // 是否默认开启日志窗口
  final double windowOpacity; // 窗口透明度
  final double? windowX; // 窗口位置X
  final double? windowY; // 窗口位置Y
  final double? windowWidth; // 窗口宽度
  final double? windowHeight; // 窗口高度

  const LogSettings({
    this.persistEnabled = false,
    this.savePath = '',
    this.fileNaming = 'date',
    this.autoSaveInterval = 1,
    this.retentionDays = 7,
    this.maxLogCount = 10000,
    this.windowEnabled = true, // 默认开启日志窗口
    this.windowOpacity = 1.0,
    this.windowX,
    this.windowY,
    this.windowWidth,
    this.windowHeight,
  });

  LogSettings copyWith({
    bool? persistEnabled,
    String? savePath,
    String? fileNaming,
    int? autoSaveInterval,
    int? retentionDays,
    int? maxLogCount,
    bool? windowEnabled,
    double? windowOpacity,
    double? windowX,
    double? windowY,
    double? windowWidth,
    double? windowHeight,
  }) {
    return LogSettings(
      persistEnabled: persistEnabled ?? this.persistEnabled,
      savePath: savePath ?? this.savePath,
      fileNaming: fileNaming ?? this.fileNaming,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      retentionDays: retentionDays ?? this.retentionDays,
      maxLogCount: maxLogCount ?? this.maxLogCount,
      windowEnabled: windowEnabled ?? this.windowEnabled,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      windowX: windowX ?? this.windowX,
      windowY: windowY ?? this.windowY,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'persistEnabled': persistEnabled,
      'savePath': savePath,
      'fileNaming': fileNaming,
      'autoSaveInterval': autoSaveInterval,
      'retentionDays': retentionDays,
      'maxLogCount': maxLogCount,
      'windowEnabled': windowEnabled,
      'windowOpacity': windowOpacity,
      'windowX': windowX,
      'windowY': windowY,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
    };
  }

  /// 从JSON创建
  factory LogSettings.fromJson(Map<String, dynamic> json) {
    return LogSettings(
      persistEnabled: json['persistEnabled'] as bool? ?? false,
      savePath: json['savePath'] as String? ?? '',
      fileNaming: json['fileNaming'] as String? ?? 'date',
      autoSaveInterval: json['autoSaveInterval'] as int? ?? 1,
      retentionDays: json['retentionDays'] as int? ?? 7,
      maxLogCount: json['maxLogCount'] as int? ?? 10000,
      windowEnabled: json['windowEnabled'] as bool? ?? true,
      windowOpacity: (json['windowOpacity'] as num?)?.toDouble() ?? 1.0,
      windowX: (json['windowX'] as num?)?.toDouble(),
      windowY: (json['windowY'] as num?)?.toDouble(),
      windowWidth: (json['windowWidth'] as num?)?.toDouble(),
      windowHeight: (json['windowHeight'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    persistEnabled,
    savePath,
    fileNaming,
    autoSaveInterval,
    retentionDays,
    maxLogCount,
    windowEnabled,
    windowOpacity,
    windowX,
    windowY,
    windowWidth,
    windowHeight,
  ];
}
