import 'package:get_it/get_it.dart';

import '../../features/logs/data/datasources/logs_local_datasource.dart';
import '../../features/logs/data/repositories/logs_repository_impl.dart';
import '../../features/logs/domain/repositories/logs_repository.dart';
import '../../features/logs/domain/usecases/logs_usecases.dart';
import '../../features/logs/presentation/bloc/logs_bloc.dart';

final sl = GetIt.instance;

/// Initialize dependency injection
Future<void> initDependencies() async {
  // Data Sources
  sl.registerLazySingleton<LogsLocalDataSource>(
    () => LogsLocalDataSource(),
  );

  // Repositories
  sl.registerLazySingleton<LogsRepository>(
    () => LogsRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetLogsUseCase(sl()));
  sl.registerLazySingleton(() => SearchLogsUseCase(sl()));
  sl.registerLazySingleton(() => FilterByCategoryUseCase(sl()));

  // BLoC
  sl.registerFactory(() => LogsBloc(
    getLogsUseCase: sl(),
    searchLogsUseCase: sl(),
    filterByCategoryUseCase: sl(),
  ));
}
