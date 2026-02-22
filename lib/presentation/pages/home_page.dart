import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/click_provider.dart';
import '../providers/log_provider.dart';
import '../widgets/click_control_panel.dart';
import '../widgets/coordinate_picker.dart';
import '../widgets/click_settings_panel.dart';
import '../widgets/log_window.dart';
import '../../l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize window service
    _initWindow();
  }

  Future<void> _initWindow() async {
    final service = ref.read(windowServiceProvider);
    await service.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final clickState = ref.watch(clickEngineProvider);
    final showLog = ref.watch(showLogWindowProvider);
    final isFloating = ref.watch(floatingModeProvider);
    final opacity = ref.watch(logWindowOpacityProvider);
    final l10n = AppLocalizations.of(context)!;

    // If in floating mode, only show log window
    if (isFloating) {
      return Scaffold(
        body: Stack(
          children: [
            // Draggable area for floating window
            GestureDetector(
              onPanStart: (_) {
                ref.read(windowServiceProvider).startDragging();
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            // Log window in floating mode
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: LogWindow(isStandalone: true),
              ),
            ),
            // Exit floating mode button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.open_in_full, size: 18),
                tooltip: 'Exit floating mode',
                onPressed: () async {
                  final service = ref.read(windowServiceProvider);
                  await service.exitFloatingMode(opacity);
                  ref.read(floatingModeProvider.notifier).state = false;
                },
              ),
            ),
          ],
        ),
      );
    }

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
          // Floating mode button
          IconButton(
            icon: Icon(
              Icons.picture_in_picture_alt,
              color: isFloating ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Floating mode (logs only)',
            onPressed: () async {
              final service = ref.read(windowServiceProvider);
              await service.enterFloatingMode(opacity);
              ref.read(floatingModeProvider.notifier).state = true;
            },
          ),
          IconButton(
            icon: Icon(
              showLog ? Icons.article : Icons.article_outlined,
              color: showLog ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: l10n.logWindow,
            onPressed: () {
              ref.read(showLogWindowProvider.notifier).state = !showLog;
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
          // Log window overlay
          if (showLog)
            Positioned(
              right: 16,
              bottom: 16,
              width: 400,
              height: 300,
              child: const LogWindow(),
            ),
        ],
      ),
    );
  }
}
