import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/click_provider.dart';

class CoordinatePicker extends ConsumerWidget {
  const CoordinatePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConfig = ref.watch(currentConfigProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Click Position',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'X Coordinate',
                      prefixIcon: Icon(Icons.open_with),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: currentConfig.x.toString(),
                    ),
                    onChanged: (value) {
                      final x = int.tryParse(value) ?? 0;
                      ref.read(currentConfigProvider.notifier).state =
                          currentConfig.copyWith(x: x);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Y Coordinate',
                      prefixIcon: Icon(Icons.open_with),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: currentConfig.y.toString(),
                    ),
                    onChanged: (value) {
                      final y = int.tryParse(value) ?? 0;
                      ref.read(currentConfigProvider.notifier).state =
                          currentConfig.copyWith(y: y);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Click anywhere on screen to pick coordinates',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.colorize),
                    label: const Text('Pick Position'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(currentConfigProvider.notifier).state =
                          currentConfig.copyWith(x: 0, y: 0);
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('Current Mouse'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Random Position'),
              subtitle: const Text(
                'Add slight randomization to click position',
              ),
              value: currentConfig.randomPosition,
              onChanged: (value) {
                ref.read(currentConfigProvider.notifier).state = currentConfig
                    .copyWith(randomPosition: value);
              },
            ),
            if (currentConfig.randomPosition) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Randomness: '),
                  Expanded(
                    child: Slider(
                      value: currentConfig.positionRandomness.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: currentConfig.positionRandomness.toString(),
                      onChanged: (value) {
                        ref
                            .read(currentConfigProvider.notifier)
                            .state = currentConfig.copyWith(
                          positionRandomness: value.toInt(),
                        );
                      },
                    ),
                  ),
                  Text('${currentConfig.positionRandomness}px'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
