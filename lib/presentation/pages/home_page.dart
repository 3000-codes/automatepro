import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/click_provider.dart';
import '../widgets/click_control_panel.dart';
import '../widgets/coordinate_picker.dart';
import '../widgets/click_settings_panel.dart';
import '../../l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: ClickControlPanel()),
                const SizedBox(width: 24),
                Expanded(flex: 3, child: ClickSettingsPanel()),
              ],
            ),
            const SizedBox(height: 24),
            CoordinatePicker(),
          ],
        ),
      ),
    );
  }
}
