import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/log_entry.dart';

/// 导出格式
enum ExportFormat {
  txt,
  json,
  csv;

  String get extension {
    switch (this) {
      case ExportFormat.txt:
        return 'txt';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.csv:
        return 'csv';
    }
  }

  String get displayName {
    switch (this) {
      case ExportFormat.txt:
        return 'TXT';
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
    }
  }
}

/// 日志导出服务
class LogExportService {
  /// 导出为 TXT 格式
  String exportToText(List<LogEntry> logs) {
    final buffer = StringBuffer();
    for (final log in logs) {
      buffer.writeln(
        '${log.formattedTime} [${log.level.displayName}] ${log.message}',
      );
    }
    return buffer.toString();
  }

  /// 导出为 JSON 格式
  String exportToJson(List<LogEntry> logs) {
    final jsonList = logs.map((log) => log.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  /// 导出为 CSV 格式
  String exportToCsv(List<LogEntry> logs) {
    final buffer = StringBuffer();
    // CSV 头部
    buffer.writeln('Timestamp,Level,Message,Source,Extra');

    for (final log in logs) {
      // 转义 CSV 字段
      final timestamp = _escapeCsvField(log.timestamp.toIso8601String());
      final level = _escapeCsvField(log.level.displayName);
      final message = _escapeCsvField(log.message);
      final source = _escapeCsvField(log.source ?? '');
      final extra = _escapeCsvField(log.extra?.toString() ?? '');

      buffer.writeln('$timestamp,$level,$message,$source,$extra');
    }
    return buffer.toString();
  }

  /// 转义 CSV 字段
  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  /// 格式化日志内容
  String formatLog(LogEntry log) {
    final buffer = StringBuffer();
    buffer.write('${log.formattedTime} [${log.level.displayName}]');
    if (log.source != null) {
      buffer.write(' [${log.source}]');
    }
    buffer.write(' ${log.message}');
    if (log.extra != null && log.extra!.isNotEmpty) {
      buffer.write('\nExtra: ${log.extra}');
    }
    return buffer.toString();
  }

  /// 根据格式导出
  String export(List<LogEntry> logs, ExportFormat format) {
    switch (format) {
      case ExportFormat.txt:
        return exportToText(logs);
      case ExportFormat.json:
        return exportToJson(logs);
      case ExportFormat.csv:
        return exportToCsv(logs);
    }
  }

  /// 保存到文件
  Future<String> saveToFile(String content, ExportFormat format) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'automatepro_logs_$timestamp.${format.extension}';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  /// 复制到剪贴板
  Future<void> copyToClipboard(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }

  /// 复制日志到剪贴板
  Future<void> copyLogsToClipboard(List<LogEntry> logs) async {
    final content = exportToText(logs);
    await copyToClipboard(content);
  }
}
