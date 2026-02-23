import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/log_provider.dart';
import '../providers/log_window_controller_provider.dart';
import '../widgets/log_window.dart';

/// 日志页面
class LogPage extends ConsumerWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final windowController = ref.watch(logWindowControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logWindow),
        actions: [
          // 透明度控制
          PopupMenuButton<double>(
            icon: const Icon(Icons.opacity),
            tooltip: '窗口透明度',
            onSelected: (value) {
              ref.read(logWindowControllerProvider.notifier).setOpacity(value);
            },
            itemBuilder: (context) => [
              for (int i = 3; i <= 10; i++)
                PopupMenuItem(
                  value: i / 10,
                  child: Row(
                    children: [
                      if (windowController.opacity == i / 10)
                        const Icon(Icons.check, size: 16),
                      if (windowController.opacity != i / 10)
                        const SizedBox(width: 16),
                      const SizedBox(width: 8),
                      Text('${i * 10}%'),
                    ],
                  ),
                ),
            ],
          ),
          // 关闭按钮
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: l10n.close,
            onPressed: () {
              ref.read(logWindowControllerProvider.notifier).closeWindow();
            },
          ),
        ],
      ),
      body: const LogWindow(),
    );
  }
}
