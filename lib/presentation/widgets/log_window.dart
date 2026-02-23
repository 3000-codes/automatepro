import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/services/log_export_service.dart';
import '../providers/log_filter_provider.dart';
import '../providers/log_provider.dart';
import '../providers/log_window_controller_provider.dart';
import 'log_filter_bar.dart';
import 'log_list_view.dart';

/// 日志窗口组件
class LogWindow extends ConsumerStatefulWidget {
  const LogWindow({super.key});

  @override
  ConsumerState<LogWindow> createState() => _LogWindowState();
}

class _LogWindowState extends ConsumerState<LogWindow> {
  final LogExportService _exportService = LogExportService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logs = ref.watch(filteredLogsProvider);
    final searchKeyword = ref.watch(logSearchQueryProvider);
    final logState = ref.watch(logProvider);
    final windowController = ref.watch(logWindowControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(windowController.opacity),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // 标题栏
          _buildTitleBar(context, windowController),

          // 过滤工具栏
          const LogFilterBar(),

          // 日志列表
          Expanded(
            child: logs.isEmpty
                ? _buildEmptyState(context)
                : LogListView(
                    key: ValueKey(logs.length),
                    logs: logs,
                    searchKeyword: searchKeyword,
                  ),
          ),

          // 状态栏
          _buildStatusBar(context, logs.length, logState.maxLogCount),
        ],
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context, LogWindowController controller) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.article_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '日志窗口',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // 清空按钮
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: '清空日志',
            onPressed: () => _confirmClearLogs(context),
            visualDensity: VisualDensity.compact,
          ),

          // 导出菜单
          PopupMenuButton<ExportFormat>(
            icon: const Icon(Icons.download, size: 18),
            tooltip: '导出日志',
            onSelected: (format) => _exportLogs(context, format),
            itemBuilder: (context) => ExportFormat.values.map((format) {
              return PopupMenuItem(
                value: format,
                child: Row(
                  children: [
                    Icon(_getFormatIcon(format), size: 16),
                    const SizedBox(width: 8),
                    Text('导出为 ${format.displayName}'),
                  ],
                ),
              );
            }).toList(),
          ),

          // 复制按钮
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: '复制到剪贴板',
            onPressed: () => _copyToClipboard(context),
            visualDensity: VisualDensity.compact,
          ),

          // 关闭按钮
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: '关闭日志窗口',
            onPressed: () {
              ref.read(logWindowControllerProvider.notifier).closeWindow();
            },
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无日志',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(
    BuildContext context,
    int filteredCount,
    int maxCount,
  ) {
    final theme = Theme.of(context);
    final totalCount = ref.watch(logCountProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Text(
            '日志: $filteredCount / $totalCount (最大 $maxCount)',
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.vertical_align_bottom, size: 14),
            label: const Text('滚动到底部'),
            onPressed: () {
              // 滚动到底部功能由 LogListView 处理
            },
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.txt:
        return Icons.text_snippet;
      case ExportFormat.json:
        return Icons.data_object;
      case ExportFormat.csv:
        return Icons.table_chart;
    }
  }

  Future<void> _confirmClearLogs(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确定要清空所有日志吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(logProvider.notifier).clearLogs();
    }
  }

  Future<void> _exportLogs(BuildContext context, ExportFormat format) async {
    try {
      final logs = ref.read(filteredLogsProvider);
      final content = _exportService.export(logs, format);
      final filePath = await _exportService.saveToFile(content, format);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('日志已导出到: $filePath'),
            action: SnackBarAction(label: '确定', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      final logs = ref.read(filteredLogsProvider);
      await _exportService.copyLogsToClipboard(logs);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('日志已复制到剪贴板')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('复制失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
