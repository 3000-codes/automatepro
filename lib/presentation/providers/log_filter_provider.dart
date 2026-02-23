import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/log_entry.dart';
import 'log_provider.dart';

/// 日志过滤状态
class LogFilterState extends Equatable {
  final Set<LogLevel> enabledLevels;
  final String searchKeyword;
  final TimeRangeOption timeRangeOption;

  const LogFilterState({
    this.enabledLevels = const {
      LogLevel.debug,
      LogLevel.info,
      LogLevel.warn,
      LogLevel.error,
    },
    this.searchKeyword = '',
    this.timeRangeOption = TimeRangeOption.all,
  });

  LogFilterState copyWith({
    Set<LogLevel>? enabledLevels,
    String? searchKeyword,
    TimeRangeOption? timeRangeOption,
  }) {
    return LogFilterState(
      enabledLevels: enabledLevels ?? this.enabledLevels,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      timeRangeOption: timeRangeOption ?? this.timeRangeOption,
    );
  }

  /// 获取时间范围
  (DateTime?, DateTime?) get timeRange {
    return timeRangeOption.toTimeRange();
  }

  @override
  List<Object?> get props => [enabledLevels, searchKeyword, timeRangeOption];
}

/// 日志过滤管理器
class LogFilterNotifier extends StateNotifier<LogFilterState> {
  LogFilterNotifier() : super(const LogFilterState());

  /// 设置日志级别过滤
  void setLevelFilter(Set<LogLevel> levels) {
    state = state.copyWith(enabledLevels: levels);
  }

  /// 切换日志级别
  void toggleLevel(LogLevel level) {
    final newLevels = Set<LogLevel>.from(state.enabledLevels);
    if (newLevels.contains(level)) {
      newLevels.remove(level);
    } else {
      newLevels.add(level);
    }
    state = state.copyWith(enabledLevels: newLevels);
  }

  /// 设置搜索关键词
  void setSearchKeyword(String keyword) {
    state = state.copyWith(searchKeyword: keyword);
  }

  /// 清除搜索关键词
  void clearSearch() {
    state = state.copyWith(searchKeyword: '');
  }

  /// 设置时间范围
  void setTimeRange(TimeRangeOption option) {
    state = state.copyWith(timeRangeOption: option);
  }

  /// 重置所有过滤条件
  void resetFilters() {
    state = const LogFilterState();
  }

  /// 获取当前的 LogFilter 对象
  LogFilter toLogFilter() {
    final (startTime, endTime) = state.timeRange;
    return LogFilter(
      enabledLevels: state.enabledLevels,
      searchKeyword: state.searchKeyword.isEmpty ? null : state.searchKeyword,
      startTime: startTime,
      endTime: endTime,
    );
  }
}

/// 日志过滤 Provider
final logFilterProvider =
    StateNotifierProvider<LogFilterNotifier, LogFilterState>((ref) {
      return LogFilterNotifier();
    });

/// 过滤后的日志 Provider
final filteredLogsProvider = Provider<List<LogEntry>>((ref) {
  final logs = ref.watch(logsProvider);
  final filterState = ref.watch(logFilterProvider);
  final (startTime, endTime) = filterState.timeRange;
  final filter = LogFilter(
    enabledLevels: filterState.enabledLevels,
    searchKeyword: filterState.searchKeyword.isEmpty
        ? null
        : filterState.searchKeyword,
    startTime: startTime,
    endTime: endTime,
  );

  return logs.where((log) => filter.matches(log)).toList();
});

/// 过滤后的日志数量 Provider
final filteredLogCountProvider = Provider<int>((ref) {
  return ref.watch(filteredLogsProvider).length;
});

/// 搜索关键词 Provider
final logSearchQueryProvider = Provider<String>((ref) {
  return ref.watch(logFilterProvider).searchKeyword;
});

/// 日志级别过滤 Provider
final logLevelFilterProvider = Provider<Set<LogLevel>>((ref) {
  return ref.watch(logFilterProvider).enabledLevels;
});
