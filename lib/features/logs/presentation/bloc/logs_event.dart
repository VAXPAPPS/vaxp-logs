part of 'logs_bloc.dart';

/// Base class for all log events
abstract class LogsEvent extends Equatable {
  const LogsEvent();

  @override
  List<Object?> get props => [];
}

/// Load logs event
class LoadLogs extends LogsEvent {
  const LoadLogs();
}

/// Refresh logs event
class RefreshLogs extends LogsEvent {
  const RefreshLogs();
}

/// Search logs event
class SearchLogs extends LogsEvent {
  final String query;

  const SearchLogs(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by category event
class FilterByCategory extends LogsEvent {
  final LogCategory category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Select a log entry event
class SelectLog extends LogsEvent {
  final LogEntry logEntry;

  const SelectLog(this.logEntry);

  @override
  List<Object?> get props => [logEntry];
}

/// Clear selection event
class ClearSelection extends LogsEvent {
  const ClearSelection();
}
