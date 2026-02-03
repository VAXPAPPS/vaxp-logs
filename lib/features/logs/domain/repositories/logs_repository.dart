import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/log_entry.dart';

/// Abstract repository for logs operations
abstract class LogsRepository {
  /// Get all logs from the system
  Future<Either<Failure, List<LogEntry>>> getLogs({int limit = 500});

  /// Search logs by query
  Future<Either<Failure, List<LogEntry>>> searchLogs(String query);

  /// Get logs filtered by category
  Future<Either<Failure, List<LogEntry>>> getLogsByCategory(LogCategory category);

  /// Stream of log updates for real-time monitoring
  Stream<LogEntry> get logStream;
}
