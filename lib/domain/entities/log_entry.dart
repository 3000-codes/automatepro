import 'package:equatable/equatable.dart';

enum LogLevel { debug, info, warn, error }

class LogEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? details;

  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.details,
  });

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  String get levelString {
    switch (level) {
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

  @override
  List<Object?> get props => [id, timestamp, level, message, details];
}
