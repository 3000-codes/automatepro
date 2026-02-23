import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import '../../domain/entities/log_entry.dart';
import '../providers/log_provider.dart';
import '../../l10n/app_localizations.dart';

/// 独立日志窗口 - 使用共享存储
class DetachedLogWindow extends ConsumerStatefulWidget {
  final String windowId;
  final Map<String, dynamic> args;

  const DetachedLogWindow({
    super.key,
    required this.windowId,
    required this.args,
  });

  @override
  ConsumerState<DetachedLogWindow> createState() => _DetachedLogWindowState();
}

class _DetachedLogWindowState extends ConsumerState<DetachedLogWindow> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  late WindowController _windowController;

  // 透明度控制
  double _opacity = 1.0;
  bool _showOpacitySlider = false;

  // 使用共享存储的日志列表
  List<LogEntry> _logs = [];
  LogFilter _filter = const LogFilter();
  StreamSubscription? _logSubscription;

  @override
  void initState() {
    super.initState();
    _initOpacity();
    _initWindowController();
    _initLogListener();
  }

  void _initOpacity() {
    // 初始化透明度
    _opacity = SharedLogStorage.windowOpacity;
  }

  void _updateOpacity(double value) {
    setState(() {
      _opacity = value;
    });
    // 保存到设置
    final settings = LogSettingsStorage.load();
    final newSettings = settings.copyWith(windowOpacity: value);
    LogSettingsStorage.save(newSettings);
  }

  Future<void> _initWindowController() async {
    // 获取窗口控制器
    _windowController = WindowController.fromWindowId(widget.windowId);

    // 设置方法处理器，监听来自主窗口的消息
    await _windowController.setWindowMethodHandler((call) async {
      if (call.method == 'window_close') {
        // 收到关闭消息，关闭当前窗口
        await windowManager.close();
      }
      return null;
    });
  }

  void _initLogListener() {
    // 初始化时加载已有日志
    _logs = SharedLogStorage.logs;

    // 监听日志更新
    _logSubscription = SharedLogStorage.logStream.listen((logs) {
      if (mounted) {
        setState(() {
          _logs = logs;
        });
      }
    });
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用本地过滤后的日志
    final filteredLogs = _logs.where((log) => _filter.matches(log)).toList();
    final l10n = AppLocalizations.of(context)!;
    final logCount = _logs.length;
    final filteredCount = filteredLogs.length;

    // 自动滚动到最新日志
    if (_autoScroll && filteredLogs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

    // 获取透明度设置
    // 使用本地状态以支持实时调整
    final opacity = _opacity;

    return Opacity(
      opacity: 1.0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surface.withValues(alpha: opacity),
          title: Text(l10n.logWindow),
          actions: [
            // 透明度控制
            IconButton(
              icon: Icon(
                _showOpacitySlider ? Icons.opacity : Icons.opacity_outlined,
              ),
              tooltip: l10n.windowOpacity,
              onPressed: () {
                setState(() {
                  _showOpacitySlider = !_showOpacitySlider;
                });
              },
            ),
            const SizedBox(width: 8),
            // 搜索框
            SizedBox(
              width: 200,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.search,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _filter = _filter.copyWith(clearSearch: true);
                            });
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      _filter = _filter.copyWith(clearSearch: true);
                    } else {
                      _filter = _filter.copyWith(searchKeyword: value);
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            // 级别过滤
            _buildLevelFilterMenu(context, _filter, l10n),
            // 时间过滤
            _buildTimeFilterMenu(context, l10n),
            // 清空按钮
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.clearLogs,
              onPressed: () => _showClearConfirmDialog(context, l10n),
            ),
            // 导出菜单
            _buildExportMenu(context, l10n),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // 透明度调节滑块
            if (_showOpacitySlider)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.opacity, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n.windowOpacity}: ${(_opacity * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: _opacity,
                        min: 0.3,
                        max: 1.0,
                        divisions: 7,
                        onChanged: _updateOpacity,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _showOpacitySlider = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            // 日志列表
            Expanded(
              child: filteredLogs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noLogsYet,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        return _buildLogItem(
                          context,
                          filteredLogs[index],
                          _filter.searchKeyword,
                        );
                      },
                    ),
            ),
            // 状态栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withValues(alpha: opacity),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${l10n.logs}: $filteredCount / $logCount',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (!_autoScroll)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _autoScroll = true;
                        });
                      },
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      label: Text(l10n.scrollToBottom),
                    )
                  else
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _autoScroll = false;
                        });
                      },
                      icon: const Icon(Icons.pause, size: 16),
                      label: Text(l10n.pauseAutoScroll),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, LogEntry log, String? highlight) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = _getLevelColor(log.level, colorScheme);

    return InkWell(
      onTap: () => _showLogDetailsDialog(context, log, levelColor),
      onSecondaryTap: () => _showContextMenu(context, log),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getLevelIcon(log.level), size: 16, color: levelColor),
            const SizedBox(width: 8),
            SizedBox(
              width: 90,
              child: Text(
                _formatTime(log.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.level.name.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: levelColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            if (log.source != null) ...[
              Text(
                '[${log.source}]',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.primary),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: _buildHighlightedText(
                context,
                log.message,
                highlight,
                colorScheme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    BuildContext context,
    String text,
    String? highlight,
    ColorScheme colorScheme,
  ) {
    if (highlight == null || highlight.isEmpty) {
      return Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
      );
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerHighlight, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + highlight.length),
          style: TextStyle(
            backgroundColor: Colors.yellow.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + highlight.length;
    }

    return RichText(
      text: TextSpan(
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
        children: spans,
      ),
    );
  }

  Widget _buildLevelFilterMenu(
    BuildContext context,
    LogFilter filter,
    AppLocalizations l10n,
  ) {
    return PopupMenuButton<LogLevel>(
      icon: const Icon(Icons.filter_list),
      tooltip: l10n.logLevel,
      onSelected: (level) {
        setState(() {
          final newLevels = Set<LogLevel>.from(filter.enabledLevels);
          if (newLevels.contains(level)) {
            newLevels.remove(level);
          } else {
            newLevels.add(level);
          }
          _filter = filter.copyWith(enabledLevels: newLevels);
        });
      },
      itemBuilder: (context) => LogLevel.values.map((level) {
        final isSelected = filter.enabledLevels.contains(level);
        return PopupMenuItem<LogLevel>(
          value: level,
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) {
                  setState(() {
                    final newLevels = Set<LogLevel>.from(filter.enabledLevels);
                    if (newLevels.contains(level)) {
                      newLevels.remove(level);
                    } else {
                      newLevels.add(level);
                    }
                    _filter = filter.copyWith(enabledLevels: newLevels);
                  });
                },
              ),
              Icon(
                _getLevelIcon(level),
                size: 18,
                color: _getLevelColor(level, Theme.of(context).colorScheme),
              ),
              const SizedBox(width: 8),
              Text(level.name.toUpperCase()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeFilterMenu(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.schedule),
      tooltip: l10n.timeFilter,
      onSelected: (value) {
        final now = DateTime.now();
        setState(() {
          switch (value) {
            case 'all':
              _filter = _filter.copyWith(clearTimeRange: true);
              break;
            case '5min':
              _filter = _filter.copyWith(
                startTime: now.subtract(const Duration(minutes: 5)),
                endTime: now,
              );
              break;
            case '1hour':
              _filter = _filter.copyWith(
                startTime: now.subtract(const Duration(hours: 1)),
                endTime: now,
              );
              break;
            case 'today':
              final startOfDay = DateTime(now.year, now.month, now.day);
              _filter = _filter.copyWith(startTime: startOfDay, endTime: now);
              break;
          }
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'all', child: Text(l10n.allTime)),
        PopupMenuItem(value: '5min', child: Text(l10n.last5Minutes)),
        PopupMenuItem(value: '1hour', child: Text(l10n.last1Hour)),
        PopupMenuItem(value: 'today', child: Text(l10n.today)),
      ],
    );
  }

  Widget _buildExportMenu(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.save_alt),
      tooltip: l10n.export,
      onSelected: (value) => _handleExport(context, value, l10n),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'txt',
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('TXT'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'json',
          child: Row(
            children: [
              const Icon(Icons.data_object, size: 20),
              const SizedBox(width: 8),
              const Text('JSON'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              const Icon(Icons.table_chart_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('CSV'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'clipboard',
          child: Row(
            children: [
              const Icon(Icons.content_copy, size: 20),
              const SizedBox(width: 8),
              Text(l10n.copyToClipboard),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    String format,
    AppLocalizations l10n,
  ) async {
    if (format == 'clipboard') {
      final text = _logs.map((log) => log.toReadableString()).join('\n');
      await Clipboard.setData(ClipboardData(text: text));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.logsCopied)));
      }
      return;
    }

    final directory = await _getSaveDirectory();
    if (directory == null) return;

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '$directory/logs_$timestamp.$format';

    String content;

    switch (format) {
      case 'json':
        content = const JsonEncoder.withIndent('  ').convert({
          'exportTime': DateTime.now().toIso8601String(),
          'count': _logs.length,
          'logs': _logs.map((log) => log.toJson()).toList(),
        });
        break;
      case 'csv':
        final buffer = StringBuffer();
        buffer.writeln('Timestamp,Level,Source,Message');
        for (final log in _logs) {
          final timestamp = log.timestamp.toIso8601String();
          final level = log.level.name;
          final source = log.source ?? '';
          final message = log.message.replaceAll('"', '""');
          buffer.writeln('"$timestamp","$level","$source","$message"');
        }
        content = buffer.toString();
        break;
      default:
        content = _logs.map((log) => log.toReadableString()).join('\n');
    }

    try {
      final file = File(path);
      await file.writeAsString(content);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.logsSaved(file.path))));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<String?> _getSaveDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = '${directory.path}/AutoMatePro/Logs';
      await Directory(logDir).create(recursive: true);
      return logDir;
    } catch (e) {
      return null;
    }
  }

  void _showClearConfirmDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearLogs),
        content: Text(l10n.clearLogsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              SharedLogStorage.clear();
              setState(() {
                _logs = [];
              });
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showLogDetailsDialog(
    BuildContext context,
    LogEntry log,
    Color levelColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getLevelIcon(log.level), color: levelColor),
            const SizedBox(width: 8),
            Text(log.level.name.toUpperCase()),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(l10n.timestamp, _formatFullTime(log.timestamp)),
              _buildDetailRow(l10n.level, log.level.name.toUpperCase()),
              if (log.source != null) _buildDetailRow(l10n.source, log.source!),
              _buildDetailRow(l10n.message, log.message),
              if (log.extra != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.details,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.extra.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, LogEntry log) {
    final l10n = AppLocalizations.of(context)!;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(100, 100, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Text(l10n.copyMessage),
          onTap: () => _copyToClipboard(log.message),
        ),
        PopupMenuItem(
          child: Text(l10n.copyAll),
          onTap: () => _copyToClipboard(log.toReadableString()),
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Color _getLevelColor(LogLevel level, ColorScheme colorScheme) {
    switch (level) {
      case LogLevel.debug:
        return colorScheme.outline;
      case LogLevel.info:
        return colorScheme.primary;
      case LogLevel.warn:
        return Colors.orange;
      case LogLevel.error:
        return colorScheme.error;
    }
  }

  IconData _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report;
      case LogLevel.info:
        return Icons.info;
      case LogLevel.warn:
        return Icons.warning;
      case LogLevel.error:
        return Icons.error;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}.'
        '${dt.millisecond.toString().padLeft(3, '0')}';
  }

  String _formatFullTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}.'
        '${dt.millisecond.toString().padLeft(3, '0')}';
  }
}
