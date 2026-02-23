import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/log_entry.dart';
import '../providers/log_filter_provider.dart';
import '../providers/log_provider.dart';

/// 日志列表组件
class LogListView extends ConsumerStatefulWidget {
  final List<LogEntry> logs;
  final String searchKeyword;

  const LogListView({super.key, required this.logs, this.searchKeyword = ''});

  @override
  ConsumerState<LogListView> createState() => _LogListViewState();
}

class _LogListViewState extends ConsumerState<LogListView> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void didUpdateWidget(LogListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 自动滚动到最新日志
    if (_autoScroll && widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      // 如果用户手动向上滚动，暂停自动滚动
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // 允许一定的误差范围
      if (maxScroll - currentScroll > 50) {
        if (_autoScroll) {
          setState(() {
            _autoScroll = false;
          });
        }
      } else {
        if (!_autoScroll) {
          setState(() {
            _autoScroll = true;
          });
        }
      }
    }
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      setState(() {
        _autoScroll = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll();
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.logs.length,
        itemBuilder: (context, index) {
          final log = widget.logs[index];
          return _LogListTile(
            log: log,
            searchKeyword: widget.searchKeyword,
            onTap: () => _showLogDetails(context, log),
          );
        },
      ),
    );
  }

  void _showLogDetails(BuildContext context, LogEntry log) {
    showDialog(
      context: context,
      builder: (context) => _LogDetailDialog(log: log),
    );
  }
}

/// 日志列表项
class _LogListTile extends StatelessWidget {
  final LogEntry log;
  final String searchKeyword;
  final VoidCallback? onTap;

  const _LogListTile({required this.log, this.searchKeyword = '', this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColors = _getLevelColors(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间戳
            SizedBox(
              width: 100,
              child: Text(
                log.formattedTime,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            // 日志级别图标
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                _getLevelIcon(log.level),
                size: 14,
                color: levelColors[log.level],
              ),
            ),
            // 日志级别标签
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: levelColors[log.level]?.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                log.level.displayName,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: levelColors[log.level],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            // 来源模块
            if (log.source != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  log.source!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // 消息内容
            Expanded(
              child: _HighlightedText(
                text: log.message,
                highlight: searchKeyword,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: levelColors[log.level],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report_outlined;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warn:
        return Icons.warning_amber_outlined;
      case LogLevel.error:
        return Icons.error_outline;
    }
  }

  Map<LogLevel, Color?> _getLevelColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return {
      LogLevel.debug: isDark ? Colors.grey : Colors.grey.shade600,
      LogLevel.info: Theme.of(context).colorScheme.primary,
      LogLevel.warn: Colors.orange.shade700,
      LogLevel.error: Colors.red.shade700,
    };
  }
}

/// 高亮文本组件
class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;

  const _HighlightedText({
    required this.text,
    required this.highlight,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final spans = <TextSpan>[];
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
            backgroundColor: Colors.yellow.withOpacity(0.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + highlight.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}

/// 日志详情对话框
class _LogDetailDialog extends StatelessWidget {
  final LogEntry log;

  const _LogDetailDialog({required this.log});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getLevelIcon(log.level),
            color: _getLevelColor(context, log.level),
          ),
          const SizedBox(width: 8),
          Text('日志详情'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: '时间戳', value: log.timestamp.toString()),
              _DetailRow(label: '级别', value: log.level.displayName),
              _DetailRow(label: '来源', value: log.source ?? '-'),
              _DetailRow(label: '消息', value: log.message),
              if (log.extra != null && log.extra!.isNotEmpty)
                _DetailRow(label: '附加数据', value: log.extra.toString()),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  IconData _getLevelIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Icons.bug_report_outlined;
      case LogLevel.info:
        return Icons.info_outline;
      case LogLevel.warn:
        return Icons.warning_amber_outlined;
      case LogLevel.error:
        return Icons.error_outline;
    }
  }

  Color _getLevelColor(BuildContext context, LogLevel level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (level) {
      case LogLevel.debug:
        return isDark ? Colors.grey : Colors.grey.shade600;
      case LogLevel.info:
        return Theme.of(context).colorScheme.primary;
      case LogLevel.warn:
        return Colors.orange.shade700;
      case LogLevel.error:
        return Colors.red.shade700;
    }
  }
}

/// 详情行组件
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
