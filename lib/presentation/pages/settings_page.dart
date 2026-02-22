import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/log_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final logSettings = ref.watch(logSettingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.general,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: Text(l10n.theme),
                    subtitle: Text(_getThemeText(themeMode, l10n)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(context, ref, l10n),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.language),
                    subtitle: Text(_getLanguageText(locale, l10n)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context, ref, l10n),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.logSettings,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.save),
                    title: Text(l10n.persistLogs),
                    value: logSettings.persistEnabled,
                    onChanged: (value) {
                      ref
                          .read(logSettingsProvider.notifier)
                          .setPersistEnabled(value);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder),
                    title: Text(l10n.logSavePath),
                    subtitle: Text(
                      logSettings.savePath.isEmpty
                          ? 'Default: Documents/AutoMatePro/Logs'
                          : logSettings.savePath,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: logSettings.persistEnabled,
                    onTap: logSettings.persistEnabled
                        ? () => _showSavePathDialog(context, ref, l10n)
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: Text(l10n.autoSaveInterval),
                    subtitle: Text('${logSettings.autoSaveInterval} min'),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: logSettings.persistEnabled,
                    onTap: logSettings.persistEnabled
                        ? () => _showAutoSaveIntervalDialog(context, ref, l10n)
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.auto_delete),
                    title: Text(l10n.retentionDays),
                    subtitle: Text('${logSettings.retentionDays} days'),
                    trailing: const Icon(Icons.chevron_right),
                    enabled: logSettings.persistEnabled,
                    onTap: logSettings.persistEnabled
                        ? () => _showRetentionDaysDialog(context, ref, l10n)
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.format_list_numbered),
                    title: Text(l10n.maxLogCount),
                    subtitle: Text('${logSettings.maxLogCount}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showMaxLogCountDialog(context, ref, l10n),
                  ),
                  const Divider(),
                  // 日志窗口设置
                  SwitchListTile(
                    secondary: const Icon(Icons.window),
                    title: const Text('默认开启日志窗口'),
                    value: logSettings.windowEnabled,
                    onChanged: (value) {
                      ref
                          .read(logSettingsProvider.notifier)
                          .setWindowEnabled(value);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.opacity),
                    title: const Text('日志窗口透明度'),
                    subtitle: Slider(
                      value: logSettings.windowOpacity,
                      min: 0.3,
                      max: 1.0,
                      divisions: 7,
                      label: '${(logSettings.windowOpacity * 100).round()}%',
                      onChanged: (value) {
                        ref
                            .read(logSettingsProvider.notifier)
                            .setWindowOpacity(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.hotkeys,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: Text(l10n.startClicking),
                    subtitle: const Text('F9'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.stop),
                    title: Text(l10n.stopClicking),
                    subtitle: const Text('F10'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.about,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: Text(l10n.version),
                    subtitle: const Text('0.2.0'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeText(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemDefault;
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _getLanguageText(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'zh':
        return '简体中文';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.systemDefault),
              leading: const Icon(Icons.brightness_auto),
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.system;
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Light'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.light;
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: const Text('🇺🇸'),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('简体中文'),
              leading: const Text('🇨🇳'),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('zh');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('繁體中文'),
              leading: const Text('🇹🇼'),
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale(
                  'zh',
                  'Hant',
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSavePathDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final controller = TextEditingController(
      text: ref.read(logSettingsProvider).savePath,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logSavePath),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter save path'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(logSettingsProvider.notifier)
                  .setSavePath(controller.text);
              Navigator.pop(context);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showAutoSaveIntervalDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final intervals = [0, 1, 5, 15, 30, 60];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.autoSaveInterval),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) {
            return ListTile(
              title: Text(interval == 0 ? 'Real-time' : '$interval min'),
              onTap: () {
                ref
                    .read(logSettingsProvider.notifier)
                    .setAutoSaveInterval(interval);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRetentionDaysDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final days = [1, 7, 14, 30, 90, -1];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.retentionDays),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: days.map((d) {
            return ListTile(
              title: Text(d == -1 ? 'Forever' : '$d days'),
              onTap: () {
                ref.read(logSettingsProvider.notifier).setRetentionDays(d);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showMaxLogCountDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final counts = [1000, 5000, 10000, 50000, 100000];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.maxLogCount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: counts.map((count) {
            return ListTile(
              title: Text('$count'),
              onTap: () {
                ref.read(logSettingsProvider.notifier).setMaxLogCount(count);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
