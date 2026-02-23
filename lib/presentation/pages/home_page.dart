import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/click_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/click_control_panel.dart';
import '../widgets/coordinate_picker.dart';
import '../widgets/click_settings_panel.dart';
import '../widgets/embedded_log_window.dart';
import '../../l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _showLogWindow = false;

  @override
  void initState() {
    super.initState();
    // 根据设置决定是否显示日志窗口
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(logSettingsProvider);
      if (settings.windowEnabled) {
        setState(() {
          _showLogWindow = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final clickState = ref.watch(clickEngineProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (clickState.isRunning)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(
                  l10n.runningCps(clickState.currentCps.toStringAsFixed(1)),
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          // 日志窗口按钮
          IconButton(
            icon: Icon(_showLogWindow ? Icons.article : Icons.article_outlined),
            tooltip: l10n.logWindow,
            onPressed: () {
              setState(() {
                _showLogWindow = !_showLogWindow;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const ClickControlPanel(),
                          const SizedBox(height: 24),
                          const CoordinatePicker(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Expanded(flex: 1, child: ClickSettingsPanel()),
                  ],
                ),
              ],
            ),
          ),
          // 嵌入式日志窗口
          if (_showLogWindow)
            EmbeddedLogWindow(
              initialOpacity: SharedLogStorage.windowOpacity,
              onClose: () {
                setState(() {
                  _showLogWindow = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
