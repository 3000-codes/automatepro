import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/click_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../infrastructure/services/click_engine.dart';

class CoordinatePicker extends ConsumerStatefulWidget {
  const CoordinatePicker({super.key});

  @override
  ConsumerState<CoordinatePicker> createState() => _CoordinatePickerState();
}

class _CoordinatePickerState extends ConsumerState<CoordinatePicker> {
  final _xController = TextEditingController();
  final _yController = TextEditingController();
  bool _isLoadingPosition = false;

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentConfig = ref.watch(currentConfigProvider);
    final l10n = AppLocalizations.of(context)!;

    // Sync controllers with config
    if (_xController.text != currentConfig.x.toString()) {
      _xController.text = currentConfig.x.toString();
    }
    if (_yController.text != currentConfig.y.toString()) {
      _yController.text = currentConfig.y.toString();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.clickPosition,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: l10n.xCoordinate,
                      prefixIcon: const Icon(Icons.open_with),
                    ),
                    keyboardType: TextInputType.number,
                    controller: _xController,
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
                    decoration: InputDecoration(
                      labelText: l10n.yCoordinate,
                      prefixIcon: const Icon(Icons.open_with),
                    ),
                    keyboardType: TextInputType.number,
                    controller: _yController,
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
                        SnackBar(
                          content: Text(l10n.clickAnywhere),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.colorize),
                    label: Text(l10n.pickPosition),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingPosition
                        ? null
                        : () async {
                            setState(() => _isLoadingPosition = true);
                            try {
                              final position = await ClickEngine()
                                  .getMousePosition();
                              ref
                                  .read(currentConfigProvider.notifier)
                                  .state = currentConfig.copyWith(
                                x: position.x,
                                y: position.y,
                              );
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoadingPosition = false);
                              }
                            }
                          },
                    icon: _isLoadingPosition
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.center_focus_strong),
                    label: Text(l10n.currentMouse),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(l10n.randomPosition),
              subtitle: Text(l10n.randomPositionDesc),
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
                  Text(l10n.randomnessValue),
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
                  Text('${currentConfig.positionRandomness}${l10n.px}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
