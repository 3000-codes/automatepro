import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/log_entry.dart';
import '../providers/log_provider.dart';
import '../../l10n/app_localizations.dart';

/// 嵌入式日志窗口 - 作为浮动面板显示在主界面
class EmbeddedLogWindow extends ConsumerStatefulWidget {
  final double initialOpacity;
  final VoidCallback? onClose;

  const EmbeddedLogWindow({super.key, this.initialOpacity = 0.9, this.onClose});

  @override
  ConsumerState<EmbeddedLogWindow> createState() => _EmbeddedLogWindowState();
}

class _EmbeddedLogWindowState extends ConsumerState<EmbeddedLogWindow> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  // 透明度控制
  double _opacity = 0.9;
  bool _showOpacitySlider = false;
  bool _isExpanded = true;

  // 使用共享存储的日志列表
  List<LogEntry> _logs = [];
  LogFilter _filter = const LogFilter();
  StreamSubscription? _logSubscription;

  @override
  void initState() {
    super.initState();
    _opacity = widget.initialOpacity;
    _initLogListener();
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

  void _updateOpacity(double value) {
    setState(() {
      _opacity = value;
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

    return Positioned(
      right: 16,
      bottom: 16,
      width: 400,
      height: _isExpanded ? 300 : 40,
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: _opacity),
        borderRadius: BorderRadius.circular(8),
        elevation: 4,
        child: Column(
          children: [
            // 标题栏
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: _opacity),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(8),
                    bottom: _isExpanded
                        ? Radius.zero
                        : const Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded ? Icons.article : Icons.article_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.logWindow,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    // 透明度控制
                    IconButton(
                      icon: Icon(
                        _showOpacitySlider
                            ? Icons.opacity
                            : Icons.opacity_outlined,
                        size: 18,
                      ),
                      tooltip: l10n.windowOpacity,
                      onPressed: () {
                        setState(() {
                          _showOpacitySlider = !_showOpacitySlider;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: l10n.close,
                      onPressed: widget.onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            // 透明度调节滑块
            if (_showOpacitySlider)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.opacity, size: 16),
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
                    Text(
                      '${(_opacity * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            // 日志内容
            if (_isExpanded) ...[
              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
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
              // 日志列表
              Expanded(
                child: filteredLogs.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noLogsYet,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          return _buildLogItem(context, filteredLogs[index]);
                        },
                      ),
              ),
              // 状态栏
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withValues(alpha: _opacity),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '${l10n.logs}: $filteredCount / $logCount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    if (_autoScroll)
                      InkWell(
                        onTap: () {
                          setState(() {
                            _autoScroll = false;
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.pause, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              l10n.pauseAutoScroll,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: () {
                          setState(() {
                            _autoScroll = true;
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_downward, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              l10n.scrollToBottom,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(BuildContext context, LogEntry log) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = _getLevelColor(log.level, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getLevelIcon(log.level), size: 12, color: levelColor),
          const SizedBox(width: 4),
          Text(
            _formatTime(log.timestamp),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              log.message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
        '${dt.second.toString().padLeft(2, '0')}';
  }
}
