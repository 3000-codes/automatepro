import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/log_provider.dart';
import 'presentation/widgets/detached_log_window.dart';
import 'l10n/app_localizations.dart';

/// 日志窗口控制器 - 全局单例
class LogWindowController {
  static WindowController? _controller;
  static String? _windowId;
  static bool _isOpened = false;
  static bool _isOpening = false;

  static bool get isOpened => _isOpened;

  /// 打开日志窗口
  static Future<void> open() async {
    // 防止重复打开 - 先设置为true防止竞态条件
    if (_isOpening || _isOpened) {
      // 如果已经打开，尝试显示
      if (_isOpened && _controller != null) {
        try {
          await _controller?.show();
        } catch (e) {
          // 窗口已关闭，重置状态
          _reset();
        }
      }
      return;
    }

    _isOpening = true;

    try {
      // 检查是否已有子窗口存在
      final existingWindows = await WindowController.getAll();
      for (final window in existingWindows) {
        // 检查窗口参数判断是否为日志窗口
        try {
          final args = jsonDecode(window.arguments);
          if (args['type'] == 'log') {
            // 日志窗口已存在，显示它
            _controller = window;
            _windowId = window.windowId;
            _isOpened = true;
            await _controller?.show();
            return;
          }
        } catch (_) {
          // 忽略解析错误
        }
      }

      // 获取当前透明度设置
      final settings = LogSettingsStorage.load();

      // 创建新窗口
      final windowArgs = {
        'type': 'log',
        'windowOpacity': settings.windowOpacity,
      };
      _controller = await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode(windowArgs),
          hiddenAtLaunch: false,
        ),
      );
      _windowId = _controller?.windowId;
      _isOpened = true;
      await _controller?.show();
    } catch (e) {
      _reset();
    } finally {
      _isOpening = false;
    }
  }

  /// 关闭日志窗口
  static Future<void> close() async {
    if (_windowId != null) {
      try {
        final controller = WindowController.fromWindowId(_windowId!);
        await controller.invokeMethod('window_close');
      } catch (e) {
        // 窗口可能已经关闭
      }
    }
    _reset();
  }

  /// 通知日志窗口透明度变化
  static Future<void> notifyOpacityChanged(double opacity) async {
    if (_windowId != null && _isOpened) {
      try {
        final controller = WindowController.fromWindowId(_windowId!);
        await controller.invokeMethod('opacity_changed', {'opacity': opacity});
      } catch (e) {
        // 忽略错误
      }
    }
  }

  /// 重置状态
  static void _reset() {
    _controller = null;
    _windowId = null;
    _isOpened = false;
    _isOpening = false;
  }

  /// 外部调用：标记窗口已关闭（当收到窗口关闭事件时调用）
  static void markAsClosed() {
    _reset();
  }
}

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 打开设置盒子
  await Hive.openBox('settings');

  // Check if this is a secondary window
  if (args.firstOrNull == 'multi_window') {
    final windowId = args[1]; // Keep as String
    final argument = args.length > 2 ? args[2] : '{}';
    final windowArgs = jsonDecode(argument) as Map<String, dynamic>;

    // Run as secondary window (log window)
    await _runSecondaryWindow(windowId, windowArgs);
    return;
  }

  // Initialize window manager for main window
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(900, 650),
    minimumSize: Size(800, 550),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'AutoMate Pro',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 添加窗口关闭监听器 - 关闭主窗口时同时关闭日志窗口
  windowManager.addListener(_MainWindowListener());

  runApp(const ProviderScope(child: AutoMateApp()));
}

/// 主窗口监听器 - 用于在主窗口关闭时关闭日志窗口
class _MainWindowListener extends WindowListener {
  @override
  void onWindowClose() async {
    // 关闭日志窗口
    await LogWindowController.close();
    // 允许窗口关闭
    await windowManager.destroy();
  }
}

Future<void> _runSecondaryWindow(
  String windowId,
  Map<String, dynamic> args,
) async {
  // 独立窗口不需要 window_manager，直接运行应用
  // Run the secondary window app
  runApp(
    ProviderScope(
      child: SecondaryWindowApp(
        windowId: windowId,
        windowType: args['type'] as String? ?? 'log',
        args: args,
      ),
    ),
  );
}

class SecondaryWindowApp extends ConsumerWidget {
  final String windowId;
  final String windowType;
  final Map<String, dynamic> args;

  const SecondaryWindowApp({
    super.key,
    required this.windowId,
    required this.windowType,
    required this.args,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: windowType == 'log' ? 'AutoMate Pro - Logs' : 'AutoMate Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('zh', 'Hant'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildWindowContent(),
    );
  }

  Widget _buildWindowContent() {
    switch (windowType) {
      case 'log':
        return DetachedLogWindow(windowId: windowId, args: args);
      default:
        return const Scaffold(body: Center(child: Text('Unknown window type')));
    }
  }
}

// Function to open detached log window
Future<String?> openDetachedLogWindow() async {
  final windowArgs = {'type': 'log'};

  final controller = await WindowController.create(
    WindowConfiguration(
      arguments: jsonEncode(windowArgs),
      hiddenAtLaunch: false,
    ),
  );

  await controller.show();

  // Return the window ID for registration
  return controller.windowId;
}

// Provider for detached log window state
final detachedLogWindowOpenProvider = StateProvider<bool>((ref) => false);

class AutoMateApp extends ConsumerWidget {
  const AutoMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final mainOpacity = ref.watch(mainWindowOpacityProvider);

    // Apply main window opacity
    windowManager.setOpacity(mainOpacity);

    return MaterialApp.router(
      title: 'AutoMate Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('zh', 'Hant'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
