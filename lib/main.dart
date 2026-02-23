import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/log_window_controller_provider.dart';
import 'presentation/pages/log_page.dart';
import 'l10n/app_localizations.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 打开设置盒子
  await Hive.openBox('settings');

  // 打开日志设置盒子
  await Hive.openBox('log_settings');

  // Check if this is a secondary window (desktop_multi_window format)
  if (args.firstOrNull == 'multi_window') {
    // Handle secondary window
    final windowId = args[1];
    final argument = args.length > 2 && args[2].isNotEmpty ? args[2] : '{}';
    final windowArgs = jsonDecode(argument) as Map<String, dynamic>;

    // 初始化子窗口的 window_manager
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(700, 500),
      minimumSize: Size(400, 300),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'AutoMate Pro - 日志窗口',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // 运行子窗口应用
    runApp(
      ProviderScope(
        child: LogWindowApp(windowId: windowId, windowArgs: windowArgs),
      ),
    );
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

  runApp(const ProviderScope(child: AutoMateApp()));
}

/// 日志窗口应用 (子窗口)
class LogWindowApp extends ConsumerStatefulWidget {
  final String windowId;
  final Map<String, dynamic> windowArgs;

  const LogWindowApp({
    super.key,
    required this.windowId,
    required this.windowArgs,
  });

  @override
  ConsumerState<LogWindowApp> createState() => _LogWindowAppState();
}

class _LogWindowAppState extends ConsumerState<LogWindowApp> {
  @override
  void initState() {
    super.initState();
    _applyInitialOpacity();
  }

  Future<void> _applyInitialOpacity() async {
    // 获取保存的透明度并应用
    final controller = ref.read(logWindowControllerProvider);
    await controller.initialize();
    if (controller.opacity < 1.0) {
      await windowManager.setOpacity(controller.opacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoMate Pro - 日志窗口',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale('zh', 'Hant'),
      ],
      home: const LogPage(),
    );
  }
}

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
