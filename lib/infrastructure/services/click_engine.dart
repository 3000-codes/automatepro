import 'dart:async';
import 'dart:math';
import '../mouse/mouse_service.dart';
import '../../domain/entities/click_config.dart';

class ClickEngine {
  static final ClickEngine _instance = ClickEngine._internal();
  factory ClickEngine() => _instance;
  ClickEngine._internal();

  final MouseService _mouseService = MouseService();
  Timer? _clickTimer;
  bool _isRunning = false;
  int _clickCount = 0;

  final _clickCountController = StreamController<int>.broadcast();
  Stream<int> get clickCountStream => _clickCountController.stream;

  bool get isRunning => _isRunning;
  int get clickCount => _clickCount;

  Future<void> initialize() async {
    await _mouseService.initialize();
  }

  Future<void> start(ClickConfig config) async {
    if (_isRunning) return;
    _isRunning = true;
    _clickCount = 0;

    switch (config.mode) {
      case ClickMode.single:
        await _runSingleClicks(config);
        break;
      case ClickMode.continuous:
        await _runContinuousClicks(config);
        break;
      case ClickMode.hold:
        await _runHold(config);
        break;
      case ClickMode.doubleClick:
        await _runDoubleClicks(config);
        break;
    }
  }

  Future<void> _runSingleClicks(ClickConfig config) async {
    final repeatCount = config.infiniteRepeat ? 1000000 : config.repeatCount;

    for (int i = 0; i < repeatCount && _isRunning; i++) {
      final x = _getRandomX(config);
      final y = _getRandomY(config);

      await _mouseService.click(x: x, y: y, button: config.button);
      _incrementClickCount();

      final delay = _getIntervalMs(config);
      await Future.delayed(Duration(milliseconds: delay));
    }

    _isRunning = false;
  }

  Future<void> _runContinuousClicks(ClickConfig config) async {
    while (_isRunning) {
      final x = _getRandomX(config);
      final y = _getRandomY(config);

      await _mouseService.click(x: x, y: y, button: config.button);
      _incrementClickCount();

      final delay = _getIntervalMs(config);
      await Future.delayed(Duration(milliseconds: delay));
    }
  }

  Future<void> _runHold(ClickConfig config) async {
    final x = _getRandomX(config);
    final y = _getRandomY(config);

    await _mouseService.hold(
      x: x,
      y: y,
      button: config.button,
      durationMs: config.fixedIntervalMs,
    );
    _incrementClickCount();
    _isRunning = false;
  }

  Future<void> _runDoubleClicks(ClickConfig config) async {
    final repeatCount = config.infiniteRepeat ? 1000000 : config.repeatCount;

    for (int i = 0; i < repeatCount && _isRunning; i++) {
      final x = _getRandomX(config);
      final y = _getRandomY(config);

      await _mouseService.doubleClick(x: x, y: y, button: config.button);
      _incrementClickCount();

      final delay = _getIntervalMs(config);
      await Future.delayed(Duration(milliseconds: delay));
    }

    _isRunning = false;
  }

  void stop() {
    _isRunning = false;
    _clickTimer?.cancel();
    _clickTimer = null;
  }

  void resetClickCount() {
    _clickCount = 0;
    _clickCountController.add(_clickCount);
  }

  void _incrementClickCount() {
    _clickCount++;
    _clickCountController.add(_clickCount);
  }

  int _getIntervalMs(ClickConfig config) {
    if (config.intervalType == IntervalType.fixed) {
      return config.fixedIntervalMs;
    } else {
      final random = Random();
      return config.minIntervalMs +
          random.nextInt(config.maxIntervalMs - config.minIntervalMs + 1);
    }
  }

  int _getRandomX(ClickConfig config) {
    if (!config.randomPosition) return config.x;
    final random = Random();
    return config.x +
        random.nextInt(config.positionRandomness * 2 + 1) -
        config.positionRandomness;
  }

  int _getRandomY(ClickConfig config) {
    if (!config.randomPosition) return config.y;
    final random = Random();
    return config.y +
        random.nextInt(config.positionRandomness * 2 + 1) -
        config.positionRandomness;
  }

  void dispose() {
    stop();
    _clickCountController.close();
  }
}
