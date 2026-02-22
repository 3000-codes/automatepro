import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/click_config.dart';
import '../../infrastructure/services/click_engine.dart';
import '../../infrastructure/hotkey/hotkey_service.dart';
import 'log_provider.dart';

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
  final ClickEngine _clickEngine = ClickEngine();
  final HotkeyService _hotkeyService = HotkeyService();
  StreamSubscription<int>? _clickCountSubscription;
  final Ref _ref;

  ClickEngineNotifier(this._ref) : super(const ClickEngineState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _clickEngine.initialize();
    await _hotkeyService.initialize();

    _ref.read(logProvider.notifier).info('Click engine initialized');

    await _hotkeyService.registerHotkeys(
      onStart: () {
        final config = state.currentConfig;
        if (config != null && !state.isRunning) {
          start(config);
        }
      },
      onStop: () {
        if (state.isRunning) {
          stop();
        }
      },
    );

    _clickCountSubscription = _clickEngine.clickCountStream.listen((count) {
      state = state.copyWith(clickCount: count);
    });
  }

  Future<void> start(ClickConfig config) async {
    _ref
        .read(logProvider.notifier)
        .info(
          'Starting click: mode=${config.mode.name}, cps=${config.cps}, x=${config.x}, y=${config.y}',
        );

    state = state.copyWith(
      isRunning: true,
      currentConfig: config,
      currentCps: config.cps,
      clickCount: 0,
    );
    await _clickEngine.start(config);

    if (!_clickEngine.isRunning && state.isRunning) {
      state = state.copyWith(isRunning: false, currentCps: 0.0);
      _ref.read(logProvider.notifier).info('Click completed');
    }
  }

  void stop() {
    _clickEngine.stop();
    _ref.read(logProvider.notifier).info('Click stopped manually');
    state = state.copyWith(isRunning: false, currentCps: 0.0);
  }

  void updateCps(double cps) {
    if (state.isRunning) {
      state = state.copyWith(currentCps: cps);
    }
  }

  void resetClickCount() {
    _clickEngine.resetClickCount();
    state = state.copyWith(clickCount: 0);
  }

  @override
  void dispose() {
    _clickCountSubscription?.cancel();
    _hotkeyService.dispose();
    _clickEngine.dispose();
    super.dispose();
  }
}

final clickEngineProvider =
    StateNotifierProvider<ClickEngineNotifier, ClickEngineState>((ref) {
      return ClickEngineNotifier(ref);
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
