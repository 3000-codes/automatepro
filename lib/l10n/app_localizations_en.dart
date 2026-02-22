// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AutoMate Pro';

  @override
  String get home => 'Home';

  @override
  String get presets => 'Presets';

  @override
  String get settings => 'Settings';

  @override
  String get clickControl => 'Click Control';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get clickPosition => 'Click Position';

  @override
  String get xCoordinate => 'X Coordinate';

  @override
  String get yCoordinate => 'Y Coordinate';

  @override
  String get pickPosition => 'Pick Position';

  @override
  String get currentMouse => 'Current Mouse';

  @override
  String get currentMousePos => 'Current Mouse Position';

  @override
  String get randomPosition => 'Random Position';

  @override
  String get randomPositionDesc => 'Add slight randomization to click position';

  @override
  String get randomness => 'Randomness';

  @override
  String get randomnessValue => 'Randomness: ';

  @override
  String get px => 'px';

  @override
  String get clickSettings => 'Click Settings';

  @override
  String get clickMode => 'Click Mode';

  @override
  String get singleClick => 'Single Click';

  @override
  String get continuous => 'Continuous';

  @override
  String get hold => 'Hold';

  @override
  String get doubleClick => 'Double Click';

  @override
  String get mouseButton => 'Mouse Button';

  @override
  String get left => 'Left';

  @override
  String get middle => 'Middle';

  @override
  String get right => 'Right';

  @override
  String get clickSpeed => 'Click Speed';

  @override
  String get cps => 'CPS';

  @override
  String cpsValue(String cps) {
    return '$cps CPS';
  }

  @override
  String get intervalType => 'Interval Type';

  @override
  String get fixed => 'Fixed';

  @override
  String get random => 'Random';

  @override
  String get fixedIntervalMs => 'Fixed Interval (ms)';

  @override
  String get minMs => 'Min (ms)';

  @override
  String get maxMs => 'Max (ms)';

  @override
  String get repeat => 'Repeat';

  @override
  String get infiniteRepeat => 'Infinite Repeat';

  @override
  String get repeatCount => 'Repeat Count';

  @override
  String get general => 'General';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get hotkeys => 'Hotkeys';

  @override
  String get startClicking => 'Start Clicking';

  @override
  String get stopClicking => 'Stop Clicking';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get systemDefault => 'System default';

  @override
  String get noPresets => 'No presets yet';

  @override
  String get createPresetTip =>
      'Create a preset to save your click configurations';

  @override
  String get load => 'Load';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get newPreset => 'New Preset';

  @override
  String get clickAnywhere => 'Click anywhere on screen to pick coordinates';

  @override
  String get clickStartToBegin => 'Click Start to begin';

  @override
  String get clicks => 'clicks';

  @override
  String clicksValue(int count) {
    return '$count clicks';
  }

  @override
  String get running => 'Running';

  @override
  String runningCps(String cps) {
    return 'Running - $cps CPS';
  }

  @override
  String get error => 'Error';

  @override
  String get logs => 'Logs';

  @override
  String get copy => 'Copy';

  @override
  String get save => 'Save';

  @override
  String get clear => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get logsCopied => 'Logs copied to clipboard';

  @override
  String logsSaved(String path) {
    return 'Logs saved to: $path';
  }

  @override
  String get noLogsYet => 'No logs yet';

  @override
  String get autoScroll => 'Auto scroll';

  @override
  String get logWindow => 'Log Window';
}
