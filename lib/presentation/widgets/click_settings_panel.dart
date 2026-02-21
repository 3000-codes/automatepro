import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/click_config.dart';
import '../providers/click_provider.dart';

class ClickSettingsPanel extends ConsumerWidget {
  const ClickSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConfig = ref.watch(currentConfigProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Click Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<ClickMode>(
                initialValue: currentConfig.mode,
                decoration: const InputDecoration(
                  labelText: 'Click Mode',
                  prefixIcon: Icon(Icons.touch_app),
                ),
                items: const [
                  DropdownMenuItem(
                    value: ClickMode.single,
                    child: Text('Single Click'),
                  ),
                  DropdownMenuItem(
                    value: ClickMode.continuous,
                    child: Text('Continuous'),
                  ),
                  DropdownMenuItem(value: ClickMode.hold, child: Text('Hold')),
                  DropdownMenuItem(
                    value: ClickMode.doubleClick,
                    child: Text('Double Click'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(currentConfigProvider.notifier).state =
                        currentConfig.copyWith(mode: value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MouseButton>(
                initialValue: currentConfig.button,
                decoration: const InputDecoration(
                  labelText: 'Mouse Button',
                  prefixIcon: Icon(Icons.mouse),
                ),
                items: const [
                  DropdownMenuItem(
                    value: MouseButton.left,
                    child: Text('Left'),
                  ),
                  DropdownMenuItem(
                    value: MouseButton.middle,
                    child: Text('Middle'),
                  ),
                  DropdownMenuItem(
                    value: MouseButton.right,
                    child: Text('Right'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(currentConfigProvider.notifier).state =
                        currentConfig.copyWith(button: value);
                  }
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Click Speed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${currentConfig.cps.toStringAsFixed(1)} CPS'),
                        Slider(
                          value: currentConfig.cps,
                          min: AppConstants.minCps,
                          max: AppConstants.maxCps,
                          divisions: 999,
                          onChanged: (value) {
                            ref.read(currentConfigProvider.notifier).state =
                                currentConfig.copyWith(cps: value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IntervalType>(
                initialValue: currentConfig.intervalType,
                decoration: const InputDecoration(
                  labelText: 'Interval Type',
                  prefixIcon: Icon(Icons.timer),
                ),
                items: const [
                  DropdownMenuItem(
                    value: IntervalType.fixed,
                    child: Text('Fixed'),
                  ),
                  DropdownMenuItem(
                    value: IntervalType.random,
                    child: Text('Random'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(currentConfigProvider.notifier).state =
                        currentConfig.copyWith(intervalType: value);
                  }
                },
              ),
              if (currentConfig.intervalType == IntervalType.fixed) ...[
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Fixed Interval (ms)',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: currentConfig.fixedIntervalMs.toString(),
                  ),
                  onChanged: (value) {
                    final interval = int.tryParse(value) ?? 100;
                    ref
                        .read(currentConfigProvider.notifier)
                        .state = currentConfig.copyWith(
                      fixedIntervalMs: interval,
                      cps: 1000 / interval,
                    );
                  },
                ),
              ],
              if (currentConfig.intervalType == IntervalType.random) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Min (ms)',
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: currentConfig.minIntervalMs.toString(),
                        ),
                        onChanged: (value) {
                          final min = int.tryParse(value) ?? 50;
                          ref.read(currentConfigProvider.notifier).state =
                              currentConfig.copyWith(minIntervalMs: min);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Max (ms)',
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: currentConfig.maxIntervalMs.toString(),
                        ),
                        onChanged: (value) {
                          final max = int.tryParse(value) ?? 150;
                          ref.read(currentConfigProvider.notifier).state =
                              currentConfig.copyWith(maxIntervalMs: max);
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Text('Repeat', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Infinite Repeat'),
                value: currentConfig.infiniteRepeat,
                onChanged: (value) {
                  ref.read(currentConfigProvider.notifier).state = currentConfig
                      .copyWith(infiniteRepeat: value);
                },
              ),
              if (!currentConfig.infiniteRepeat) ...[
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Repeat Count',
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(
                    text: currentConfig.repeatCount.toString(),
                  ),
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 1;
                    ref.read(currentConfigProvider.notifier).state =
                        currentConfig.copyWith(repeatCount: count);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
