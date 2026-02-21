import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/click_config.dart';

class PresetsNotifier extends AsyncNotifier<List<ClickConfig>> {
  final _uuid = const Uuid();

  @override
  Future<List<ClickConfig>> build() async {
    return [];
  }

  Future<void> createPreset() async {
    final currentList = state.valueOrNull ?? [];
    final newPreset = ClickConfig(
      id: _uuid.v4(),
      name: 'New Preset ${currentList.length + 1}',
      cps: 10.0,
    );
    state = AsyncData([...currentList, newPreset]);
  }

  Future<void> deletePreset(String id) async {
    final currentList = state.valueOrNull ?? [];
    state = AsyncData(currentList.where((p) => p.id != id).toList());
  }

  Future<void> updatePreset(ClickConfig preset) async {
    final currentList = state.valueOrNull ?? [];
    final index = currentList.indexWhere((p) => p.id == preset.id);
    if (index >= 0) {
      final newList = [...currentList];
      newList[index] = preset;
      state = AsyncData(newList);
    }
  }

  Future<void> loadPreset(ClickConfig preset) async {
    // This will be handled by the click provider
  }
}

final presetsProvider =
    AsyncNotifierProvider<PresetsNotifier, List<ClickConfig>>(() {
      return PresetsNotifier();
    });
