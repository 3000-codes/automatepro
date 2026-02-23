import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/log_entry.dart';
import '../providers/log_filter_provider.dart';
import '../providers/log_window_controller_provider.dart';

/// 日志过滤工具栏
class LogFilterBar extends ConsumerStatefulWidget {
  const LogFilterBar({super.key});

  @override
  ConsumerState<LogFilterBar> createState() => _LogFilterBarState();
}

class _LogFilterBarState extends ConsumerState<LogFilterBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _showOpacitySlider = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filterState = ref.watch(logFilterProvider);
    final windowController = ref.watch(logWindowControllerProvider);
    final opacity = windowController.opacity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 搜索框
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索日志...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(logFilterProvider.notifier)
                                  .clearSearch();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(logFilterProvider.notifier)
                        .setSearchKeyword(value);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // 日志级别过滤
              _LevelFilterChips(
                enabledLevels: filterState.enabledLevels,
                onToggle: (level) {
                  ref.read(logFilterProvider.notifier).toggleLevel(level);
                },
              ),
              const SizedBox(width: 12),

              // 时间范围选择
              _TimeRangeDropdown(
                selectedOption: filterState.timeRangeOption,
                onChanged: (option) {
                  ref.read(logFilterProvider.notifier).setTimeRange(option);
                },
              ),
              const SizedBox(width: 12),

              // 透明度控制
              IconButton(
                icon: Icon(
                  _showOpacitySlider ? Icons.layers_clear : Icons.layers,
                  size: 20,
                ),
                tooltip: '透明度',
                onPressed: () {
                  setState(() {
                    _showOpacitySlider = !_showOpacitySlider;
                  });
                },
              ),
            ],
          ),

          // 透明度滑块
          if (_showOpacitySlider) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.opacity, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: opacity,
                    min: 0.3,
                    max: 1.0,
                    divisions: 7,
                    label: '${(opacity * 100).round()}%',
                    onChanged: (value) {
                      ref
                          .read(logWindowControllerProvider.notifier)
                          .setOpacity(value);
                    },
                  ),
                ),
                Text(
                  '${(opacity * 100).round()}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 日志级别过滤复选框
class _LevelFilterChips extends StatelessWidget {
  final Set<LogLevel> enabledLevels;
  final Function(LogLevel) onToggle;

  const _LevelFilterChips({
    required this.enabledLevels,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: LogLevel.values.map((level) {
        final isEnabled = enabledLevels.contains(level);
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: FilterChip(
            label: Text(
              level.displayName,
              style: TextStyle(
                fontSize: 11,
                color: isEnabled ? _getLevelColor(context, level) : null,
              ),
            ),
            selected: isEnabled,
            onSelected: (_) => onToggle(level),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            selectedColor: _getLevelColor(context, level)?.withOpacity(0.2),
            checkmarkColor: _getLevelColor(context, level),
          ),
        );
      }).toList(),
    );
  }

  Color? _getLevelColor(BuildContext context, LogLevel level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (level) {
      case LogLevel.debug:
        return isDark ? Colors.grey : Colors.grey.shade600;
      case LogLevel.info:
        return Theme.of(context).colorScheme.primary;
      case LogLevel.warn:
        return Colors.orange.shade700;
      case LogLevel.error:
        return Colors.red.shade700;
    }
  }
}

/// 时间范围选择下拉菜单
class _TimeRangeDropdown extends StatelessWidget {
  final TimeRangeOption selectedOption;
  final Function(TimeRangeOption) onChanged;

  const _TimeRangeDropdown({
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TimeRangeOption>(
      value: selectedOption,
      underline: const SizedBox(),
      isDense: true,
      items: TimeRangeOption.values.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option.displayName, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
