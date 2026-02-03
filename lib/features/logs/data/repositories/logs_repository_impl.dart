import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/log_entry.dart';
import '../../domain/repositories/logs_repository.dart';
import '../datasources/logs_local_datasource.dart';

/// Implementation of LogsRepository
class LogsRepositoryImpl implements LogsRepository {
  final LogsLocalDataSource localDataSource;
  
  /// Cached logs for faster access
  List<LogEntry> _cachedLogs = [];
  DateTime? _lastFetch;
  static const _cacheValidDuration = Duration(seconds: 30);

  LogsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<LogEntry>>> getLogs({int limit = 500}) async {
    try {
      // Return cached if still valid
      if (_cachedLogs.isNotEmpty && 
          _lastFetch != null && 
          DateTime.now().difference(_lastFetch!) < _cacheValidDuration) {
        return Right(_cachedLogs.take(limit).toList());
      }

      final logs = await localDataSource.getLogs(limit: limit);
      _cachedLogs = logs;
      _lastFetch = DateTime.now();
      return Right(logs);
    } catch (e) {
      return Left(FileFailure('فشل في قراءة السجلات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> searchLogs(String query) async {
    try {
      // Ensure we have logs cached
      if (_cachedLogs.isEmpty) {
        await getLogs();
      }
      
      final results = await localDataSource.searchLogs(query, _cachedLogs);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('فشل في البحث: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<LogEntry>>> getLogsByCategory(LogCategory category) async {
    try {
      // Ensure we have logs cached
      if (_cachedLogs.isEmpty) {
        await getLogs();
      }
      
      final results = localDataSource.filterByCategory(category, _cachedLogs);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('فشل في التصفية: ${e.toString()}'));
    }
  }

  @override
  Stream<LogEntry> get logStream => localDataSource.watchLogs();

  /// Force refresh cache
  Future<void> refreshCache() async {
    _cachedLogs = [];
    _lastFetch = null;
    await getLogs();
  }
}
