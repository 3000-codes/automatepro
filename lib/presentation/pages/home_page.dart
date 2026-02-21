import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/click_provider.dart';
import '../widgets/click_control_panel.dart';
import '../widgets/coordinate_picker.dart';
import '../widgets/click_settings_panel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final clickState = ref.watch(clickEngineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoMate Pro'),
        actions: [
          if (clickState.isRunning)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(
                  'Running - ${clickState.currentCps.toStringAsFixed(1)} CPS',
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
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
    );
  }
}
