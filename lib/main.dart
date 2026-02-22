import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';

import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/log_provider.dart';
import 'presentation/widgets/detached_log_window.dart';
import 'l10n/app_localizations.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const ProviderScope(child: AutoMateApp()));
}

Future<void> _runSecondaryWindow(
  String windowId,
  Map<String, dynamic> args,
) async {
  // Initialize window manager for secondary window
  await windowManager.ensureInitialized();

  final windowType = args['type'] as String? ?? 'log';

  WindowOptions windowOptions;

  if (windowType == 'log') {
    windowOptions = const WindowOptions(
      size: Size(600, 500),
      minimumSize: Size(400, 300),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'AutoMate Pro - Logs',
    );
  } else {
    windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      title: 'AutoMate Pro',
    );
  }

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Run the secondary window app
  runApp(
    ProviderScope(
      child: SecondaryWindowApp(
        windowId: windowId,
        windowType: windowType,
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
