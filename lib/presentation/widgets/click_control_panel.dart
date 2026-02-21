import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/click_provider.dart';

class ClickControlPanel extends ConsumerWidget {
  const ClickControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clickState = ref.watch(clickEngineProvider);
    final currentConfig = ref.watch(currentConfigProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Click Control',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!clickState.isRunning)
                  FilledButton.icon(
                    onPressed: () {
                      ref
                          .read(clickEngineProvider.notifier)
                          .start(currentConfig);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ),
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(clickEngineProvider.notifier).stop();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (clickState.isRunning) ...[
              Text(
                '${clickState.currentCps.toStringAsFixed(1)} CPS',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${clickState.clickCount} clicks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ] else ...[
              Text(
                '${currentConfig.cps.toStringAsFixed(1)} CPS',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click Start to begin',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.keyboard, size: 18),
                  label: const Text('F9 - Start'),
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.keyboard, size: 18),
                  label: const Text('F10 - Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
