import 'package:equatable/equatable.dart';

enum ClickMode { single, continuous, hold, doubleClick }

enum MouseButton { left, middle, right, forward, backward }

enum IntervalType { fixed, random }

class ClickConfig extends Equatable {
  final String id;
  final String name;
  final ClickMode mode;
  final MouseButton button;
  final int x;
  final int y;
  final double cps;
  final IntervalType intervalType;
  final int fixedIntervalMs;
  final int minIntervalMs;
  final int maxIntervalMs;
  final int repeatCount;
  final bool infiniteRepeat;
  final bool randomPosition;
  final int positionRandomness;

  const ClickConfig({
    required this.id,
    required this.name,
    this.mode = ClickMode.continuous,
    this.button = MouseButton.left,
    this.x = 0,
    this.y = 0,
    this.cps = 10.0,
    this.intervalType = IntervalType.fixed,
    this.fixedIntervalMs = 100,
    this.minIntervalMs = 50,
    this.maxIntervalMs = 150,
    this.repeatCount = 1,
    this.infiniteRepeat = true,
    this.randomPosition = false,
    this.positionRandomness = 5,
  });

  ClickConfig copyWith({
    String? id,
    String? name,
    ClickMode? mode,
    MouseButton? button,
    int? x,
    int? y,
    double? cps,
    IntervalType? intervalType,
    int? fixedIntervalMs,
    int? minIntervalMs,
    int? maxIntervalMs,
    int? repeatCount,
    bool? infiniteRepeat,
    bool? randomPosition,
    int? positionRandomness,
  }) {
    return ClickConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      button: button ?? this.button,
      x: x ?? this.x,
      y: y ?? this.y,
      cps: cps ?? this.cps,
      intervalType: intervalType ?? this.intervalType,
      fixedIntervalMs: fixedIntervalMs ?? this.fixedIntervalMs,
      minIntervalMs: minIntervalMs ?? this.minIntervalMs,
      maxIntervalMs: maxIntervalMs ?? this.maxIntervalMs,
      repeatCount: repeatCount ?? this.repeatCount,
      infiniteRepeat: infiniteRepeat ?? this.infiniteRepeat,
      randomPosition: randomPosition ?? this.randomPosition,
      positionRandomness: positionRandomness ?? this.positionRandomness,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mode': mode.index,
      'button': button.index,
      'x': x,
      'y': y,
      'cps': cps,
      'intervalType': intervalType.index,
      'fixedIntervalMs': fixedIntervalMs,
      'minIntervalMs': minIntervalMs,
      'maxIntervalMs': maxIntervalMs,
      'repeatCount': repeatCount,
      'infiniteRepeat': infiniteRepeat,
      'randomPosition': randomPosition,
      'positionRandomness': positionRandomness,
    };
  }

  factory ClickConfig.fromJson(Map<String, dynamic> json) {
    return ClickConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      mode: ClickMode.values[json['mode'] as int],
      button: MouseButton.values[json['button'] as int],
      x: json['x'] as int,
      y: json['y'] as int,
      cps: (json['cps'] as num).toDouble(),
      intervalType: IntervalType.values[json['intervalType'] as int],
      fixedIntervalMs: json['fixedIntervalMs'] as int,
      minIntervalMs: json['minIntervalMs'] as int,
      maxIntervalMs: json['maxIntervalMs'] as int,
      repeatCount: json['repeatCount'] as int,
      infiniteRepeat: json['infiniteRepeat'] as bool,
      randomPosition: json['randomPosition'] as bool,
      positionRandomness: json['positionRandomness'] as int,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    mode,
    button,
    x,
    y,
    cps,
    intervalType,
    fixedIntervalMs,
    minIntervalMs,
    maxIntervalMs,
    repeatCount,
    infiniteRepeat,
    randomPosition,
    positionRandomness,
  ];
}
