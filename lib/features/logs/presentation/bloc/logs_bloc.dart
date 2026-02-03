import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/log_entry.dart';
import '../../domain/usecases/logs_usecases.dart';

part 'logs_event.dart';
part 'logs_state.dart';

/// BLoC for managing logs state
class LogsBloc extends Bloc<LogsEvent, LogsState> {
  final GetLogsUseCase getLogsUseCase;
  final SearchLogsUseCase searchLogsUseCase;
  final FilterByCategoryUseCase filterByCategoryUseCase;

  LogsBloc({
    required this.getLogsUseCase,
    required this.searchLogsUseCase,
    required this.filterByCategoryUseCase,
  }) : super(const LogsInitial()) {
    on<LoadLogs>(_onLoadLogs);
    on<RefreshLogs>(_onRefreshLogs);
    on<SearchLogs>(
      _onSearchLogs,
      transformer: _debounce(const Duration(milliseconds: 300)),
    );
    on<FilterByCategory>(_onFilterByCategory);
    on<SelectLog>(_onSelectLog);
    on<ClearSelection>(_onClearSelection);
  }

  /// Custom event transformer for debouncing
  EventTransformer<E> _debounce<E>(Duration duration) {
    return (events, mapper) {
      return events.debounceTime(duration).asyncExpand(mapper);
    };
  }

  Future<void> _onLoadLogs(LoadLogs event, Emitter<LogsState> emit) async {
    emit(const LogsLoading());

    final result = await getLogsUseCase(limit: 500);

    result.fold(
      (failure) => emit(LogsError(failure.message)),
      (logs) => emit(LogsLoaded(logs: logs, filteredLogs: logs)),
    );
  }

  Future<void> _onRefreshLogs(
    RefreshLogs event,
    Emitter<LogsState> emit,
  ) async {
    if (state is! LogsLoaded) {
      add(const LoadLogs());
      return;
    }

    final currentState = state as LogsLoaded;
    final result = await getLogsUseCase(limit: 500);

    result.fold((failure) => emit(LogsError(failure.message)), (logs) {
      // Re-apply current filters
      var filteredLogs = logs;

      if (currentState.selectedCategory != LogCategory.all) {
        filteredLogs = logs
            .where((log) => log.category == currentState.selectedCategory)
            .toList();
      }

      if (currentState.searchQuery.isNotEmpty) {
        filteredLogs = filteredLogs
            .where((log) => log.matchesQuery(currentState.searchQuery))
            .toList();
      }

      emit(currentState.copyWith(logs: logs, filteredLogs: filteredLogs));
    });
  }

  Future<void> _onSearchLogs(SearchLogs event, Emitter<LogsState> emit) async {
    if (state is! LogsLoaded) return;
    final currentState = state as LogsLoaded;

    final query = event.query.toLowerCase();
    var filteredLogs = currentState.logs;

    // Apply category filter first
    if (currentState.selectedCategory != LogCategory.all) {
      filteredLogs = filteredLogs
          .where((log) => log.category == currentState.selectedCategory)
          .toList();
    }

    // Apply search filter
    if (query.isNotEmpty) {
      filteredLogs = filteredLogs
          .where((log) => log.matchesQuery(query))
          .toList();
    }

    emit(
      currentState.copyWith(
        filteredLogs: filteredLogs,
        searchQuery: event.query,
      ),
    );
  }

  void _onFilterByCategory(FilterByCategory event, Emitter<LogsState> emit) {
    if (state is! LogsLoaded) return;
    final currentState = state as LogsLoaded;

    var filteredLogs = currentState.logs;

    // Apply category filter
    if (event.category != LogCategory.all) {
      filteredLogs = filteredLogs
          .where((log) => log.category == event.category)
          .toList();
    }

    // Apply existing search filter
    if (currentState.searchQuery.isNotEmpty) {
      filteredLogs = filteredLogs
          .where((log) => log.matchesQuery(currentState.searchQuery))
          .toList();
    }

    emit(
      currentState.copyWith(
        filteredLogs: filteredLogs,
        selectedCategory: event.category,
      ),
    );
  }

  void _onSelectLog(SelectLog event, Emitter<LogsState> emit) {
    if (state is! LogsLoaded) return;
    final currentState = state as LogsLoaded;

    emit(currentState.copyWith(selectedLog: event.logEntry));
  }

  void _onClearSelection(ClearSelection event, Emitter<LogsState> emit) {
    if (state is! LogsLoaded) return;
    final currentState = state as LogsLoaded;

    emit(currentState.copyWith(clearSelection: true));
  }
}

/// Extension for debouncing Stream events
extension DebounceStream<T> on Stream<T> {
  Stream<T> debounceTime(Duration duration) {
    Timer? timer;
    T? lastEvent;
    StreamController<T>? controller;

    controller = StreamController<T>(
      onListen: () {
        listen(
          (event) {
            lastEvent = event;
            timer?.cancel();
            timer = Timer(duration, () {
              if (lastEvent != null) {
                controller?.add(lastEvent as T);
              }
            });
          },
          onDone: () {
            timer?.cancel();
            controller?.close();
          },
          onError: (error) => controller?.addError(error),
        );
      },
      onCancel: () {
        timer?.cancel();
      },
    );

    return controller.stream;
  }
}
