import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/click_config.dart';

class ClickEngineState extends Equatable {
  final bool isRunning;
  final double currentCps;
  final ClickConfig? currentConfig;
  final int clickCount;

  const ClickEngineState({
    this.isRunning = false,
    this.currentCps = 0.0,
    this.currentConfig,
    this.clickCount = 0,
  });

  ClickEngineState copyWith({
    bool? isRunning,
    double? currentCps,
    ClickConfig? currentConfig,
    int? clickCount,
  }) {
    return ClickEngineState(
      isRunning: isRunning ?? this.isRunning,
      currentCps: currentCps ?? this.currentCps,
      currentConfig: currentConfig ?? this.currentConfig,
      clickCount: clickCount ?? this.clickCount,
    );
  }

  @override
  List<Object?> get props => [isRunning, currentCps, currentConfig, clickCount];
}

class ClickEngineNotifier extends StateNotifier<ClickEngineState> {
  ClickEngineNotifier() : super(const ClickEngineState());

  void start(ClickConfig config) {
    state = state.copyWith(
      isRunning: true,
      currentConfig: config,
      currentCps: config.cps,
      clickCount: 0,
    );
  }

  void stop() {
    state = state.copyWith(isRunning: false, currentCps: 0.0);
  }

  void updateCps(double cps) {
    if (state.isRunning) {
      state = state.copyWith(currentCps: cps);
    }
  }

  void incrementClickCount() {
    state = state.copyWith(clickCount: state.clickCount + 1);
  }

  void resetClickCount() {
    state = state.copyWith(clickCount: 0);
  }
}

final clickEngineProvider =
    StateNotifierProvider<ClickEngineNotifier, ClickEngineState>((ref) {
      return ClickEngineNotifier();
    });

final currentConfigProvider = StateProvider<ClickConfig>((ref) {
  return ClickConfig(
    id: 'default',
    name: 'Default',
    cps: 10.0,
    intervalType: IntervalType.fixed,
    fixedIntervalMs: 100,
    infiniteRepeat: true,
  );
});
