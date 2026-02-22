import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../providers/log_provider.dart';
import '../providers/click_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/entities/log_entry.dart';

class LogWindow extends ConsumerStatefulWidget {
  final bool isStandalone;

  const LogWindow({super.key, this.isStandalone = false});

  @override
  ConsumerState<LogWindow> createState() => _LogWindowState();
}

class _LogWindowState extends ConsumerState<LogWindow> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  bool _alwaysOnTop = true;
  AppLocalizations? _l10n;

  @override
  void initState() {
    super.initState();
    // Initialize window service
    _initWindow();
  }

  Future<void> _initWindow() async {
    final service = ref.read(windowServiceProvider);
    await service.initialize();
    await service.setAlwaysOnTop(_alwaysOnTop);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(logProvider);
    final opacity = ref.watch(logWindowOpacityProvider);
    final clickState = ref.watch(clickEngineProvider);
    final isRunning = clickState.isRunning;
    _l10n = AppLocalizations.of(context)!;
    final l10n = _l10n!;

    // Auto scroll: always scroll to bottom when running, otherwise respect toggle
    final shouldAutoScroll = isRunning || _autoScroll;

    // Auto scroll when new logs arrive
    ref.listen(logProvider, (previous, next) {
      if (shouldAutoScroll &&
          previous != null &&
          next.length > previous.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    final bgColor = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: opacity);
    final headerColor = Theme.of(
      context,
    ).colorScheme.primaryContainer.withValues(alpha: opacity);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.terminal, size: 18, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    l10n.logs,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isRunning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'RUNNING',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${logs.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Always on top toggle
                  IconButton(
                    icon: Icon(
                      _alwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 16,
                    ),
                    tooltip: 'Always on top',
                    onPressed: () async {
                      setState(() {
                        _alwaysOnTop = !_alwaysOnTop;
                      });
                      final service = ref.read(windowServiceProvider);
                      await service.setAlwaysOnTop(_alwaysOnTop);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: _alwaysOnTop
                        ? Colors.orange
                        : textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  // Opacity slider (compact)
                  SizedBox(
                    width: 60,
                    child: Slider(
                      value: opacity,
                      min: 0.3,
                      max: 1.0,
                      onChanged: (value) {
                        ref.read(logWindowOpacityProvider.notifier).state =
                            value;
                        ref.read(windowServiceProvider).setOpacity(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Auto scroll toggle
                  IconButton(
                    icon: Icon(
                      shouldAutoScroll
                          ? Icons.vertical_align_bottom
                          : Icons.vertical_align_center,
                      size: 16,
                    ),
                    tooltip: shouldAutoScroll
                        ? 'Auto scroll ON'
                        : 'Auto scroll OFF',
                    onPressed: () {
                      setState(() {
                        _autoScroll = !_autoScroll;
                      });
                      ref.read(logProvider.notifier).setAutoScroll(_autoScroll);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: shouldAutoScroll
                        ? Colors.green
                        : textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  // Copy
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: l10n.copy,
                    onPressed: () => _copyLogs(logs),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  // Save
                  IconButton(
                    icon: const Icon(Icons.save, size: 16),
                    tooltip: l10n.save,
                    onPressed: () => _saveLogs(logs),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                  // Clear
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    tooltip: l10n.clear,
                    onPressed: () {
                      ref.read(logProvider.notifier).clear();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: textColor,
                  ),
                  if (!widget.isStandalone) ...[
                    const SizedBox(width: 4),
                    // Close
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      tooltip: l10n.close,
                      onPressed: () {
                        ref.read(showLogWindowProvider.notifier).state = false;
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: textColor,
                    ),
                  ],
                ],
              ),
            ),
            // Log list
            Expanded(
              child: logs.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noLogsYet,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        // Show only last 500 entries for performance
                        if (index < logs.length - 500)
                          return const SizedBox.shrink();
                        return _LogEntryWidget(entry: logs[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyLogs(List<LogEntry> logs) {
    final text = logs
        .map((entry) {
          final buffer = StringBuffer();
          buffer.write(
            '[${entry.formattedTime}] [${entry.levelString}] ${entry.message}',
          );
          if (entry.details != null) {
            buffer.write(' - ${entry.details}');
          }
          return buffer.toString();
        })
        .join('\n');

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_l10n!.logsCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveLogs(List<LogEntry> logs) async {
    try {
      final text = logs
          .map((entry) {
            final buffer = StringBuffer();
            buffer.write(
              '[${entry.formattedTime}] [${entry.levelString}] ${entry.message}',
            );
            if (entry.details != null) {
              buffer.write(' - ${entry.details}');
            }
            return buffer.toString();
          })
          .join('\n');

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/automatepro_logs_$timestamp.txt');
      await file.writeAsString(text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n!.logsSaved(file.path)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _LogEntryWidget extends StatelessWidget {
  final LogEntry entry;

  const _LogEntryWidget({required this.entry});

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    switch (entry.level) {
      case LogLevel.debug:
        levelColor = Colors.grey;
        break;
      case LogLevel.info:
        levelColor = Colors.blue;
        break;
      case LogLevel.warn:
        levelColor = Colors.orange;
        break;
      case LogLevel.error:
        levelColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 65,
            child: Text(
              entry.formattedTime,
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              entry.levelString,
              style: TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: levelColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.message,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
