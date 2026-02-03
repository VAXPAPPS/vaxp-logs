import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/log_entry.dart';
import '../repositories/logs_repository.dart';

/// Use case to get all logs
class GetLogsUseCase {
  final LogsRepository repository;

  GetLogsUseCase(this.repository);

  Future<Either<Failure, List<LogEntry>>> call({int limit = 500}) {
    return repository.getLogs(limit: limit);
  }
}

/// Use case to search logs
class SearchLogsUseCase {
  final LogsRepository repository;

  SearchLogsUseCase(this.repository);

  Future<Either<Failure, List<LogEntry>>> call(String query) {
    return repository.searchLogs(query);
  }
}

/// Use case to filter logs by category
class FilterByCategoryUseCase {
  final LogsRepository repository;

  FilterByCategoryUseCase(this.repository);

  Future<Either<Failure, List<LogEntry>>> call(LogCategory category) {
    return repository.getLogsByCategory(category);
  }
}
