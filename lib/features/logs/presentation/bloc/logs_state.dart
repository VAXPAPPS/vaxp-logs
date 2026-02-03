part of 'logs_bloc.dart';

/// Base class for all log states
abstract class LogsState extends Equatable {
  const LogsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class LogsInitial extends LogsState {
  const LogsInitial();
}

/// Loading state
class LogsLoading extends LogsState {
  const LogsLoading();
}

/// Loaded state with logs data
class LogsLoaded extends LogsState {
  final List<LogEntry> logs;
  final List<LogEntry> filteredLogs;
  final LogCategory selectedCategory;
  final String searchQuery;
  final LogEntry? selectedLog;

  const LogsLoaded({
    required this.logs,
    required this.filteredLogs,
    this.selectedCategory = LogCategory.all,
    this.searchQuery = '',
    this.selectedLog,
  });

  LogsLoaded copyWith({
    List<LogEntry>? logs,
    List<LogEntry>? filteredLogs,
    LogCategory? selectedCategory,
    String? searchQuery,
    LogEntry? selectedLog,
    bool clearSelection = false,
  }) {
    return LogsLoaded(
      logs: logs ?? this.logs,
      filteredLogs: filteredLogs ?? this.filteredLogs,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLog: clearSelection ? null : (selectedLog ?? this.selectedLog),
    );
  }

  /// Get log count by category
  int getCountByCategory(LogCategory category) {
    if (category == LogCategory.all) return logs.length;
    return logs.where((log) => log.category == category).length;
  }

  @override
  List<Object?> get props => [logs, filteredLogs, selectedCategory, searchQuery, selectedLog];
}

/// Error state
class LogsError extends LogsState {
  final String message;

  const LogsError(this.message);

  @override
  List<Object?> get props => [message];
}
