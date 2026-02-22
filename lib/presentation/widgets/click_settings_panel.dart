import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/click_config.dart';
import '../providers/click_provider.dart';
import '../../l10n/app_localizations.dart';

class ClickSettingsPanel extends ConsumerWidget {
  const ClickSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConfig = ref.watch(currentConfigProvider);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.clickSettings,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<ClickMode>(
                value: currentConfig.mode,
                decoration: InputDecoration(
                  labelText: l10n.clickMode,
                  prefixIcon: const Icon(Icons.touch_app),
                ),
                items: [
                  DropdownMenuItem(
                    value: ClickMode.single,
                    child: Text(l10n.singleClick),
                  ),
                  DropdownMenuItem(
                    value: ClickMode.continuous,
                    child: Text(l10n.continuous),
                  ),
                  DropdownMenuItem(
                    value: ClickMode.hold,
                    child: Text(l10n.hold),
                  ),
                  DropdownMenuItem(
                    value: ClickMode.doubleClick,
                    child: Text(l10n.doubleClick),
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
                value: currentConfig.button,
                decoration: InputDecoration(
                  labelText: l10n.mouseButton,
                  prefixIcon: const Icon(Icons.mouse),
                ),
                items: [
                  DropdownMenuItem(
                    value: MouseButton.left,
                    child: Text(l10n.left),
                  ),
                  DropdownMenuItem(
                    value: MouseButton.middle,
                    child: Text(l10n.middle),
                  ),
                  DropdownMenuItem(
                    value: MouseButton.right,
                    child: Text(l10n.right),
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
                l10n.clickSpeed,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cpsValue(currentConfig.cps.toStringAsFixed(1)),
                        ),
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
                value: currentConfig.intervalType,
                decoration: InputDecoration(
                  labelText: l10n.intervalType,
                  prefixIcon: const Icon(Icons.timer),
                ),
                items: [
                  DropdownMenuItem(
                    value: IntervalType.fixed,
                    child: Text(l10n.fixed),
                  ),
                  DropdownMenuItem(
                    value: IntervalType.random,
                    child: Text(l10n.random),
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
                  decoration: InputDecoration(
                    labelText: l10n.fixedIntervalMs,
                    prefixIcon: const Icon(Icons.timer),
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
                        decoration: InputDecoration(labelText: l10n.minMs),
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
                        decoration: InputDecoration(labelText: l10n.maxMs),
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
              Text(l10n.repeat, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.infiniteRepeat),
                value: currentConfig.infiniteRepeat,
                onChanged: (value) {
                  ref.read(currentConfigProvider.notifier).state = currentConfig
                      .copyWith(infiniteRepeat: value);
                },
              ),
              if (!currentConfig.infiniteRepeat) ...[
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.repeatCount,
                    prefixIcon: const Icon(Icons.repeat),
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
