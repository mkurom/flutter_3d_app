import 'package:get_it/get_it.dart';
import '../../features/maze_ball/data/datasources/local_storage_datasource.dart';
import '../../features/maze_ball/data/datasources/maze_generator.dart';
import '../../features/maze_ball/data/datasources/sensor_datasource.dart';
import '../../features/maze_ball/data/repositories/game_repository_impl.dart';
import '../../features/maze_ball/data/repositories/maze_repository_impl.dart';
import '../../features/maze_ball/data/repositories/sensor_repository_impl.dart';
import '../../features/maze_ball/domain/repositories/game_repository.dart';
import '../../features/maze_ball/domain/repositories/maze_repository.dart';
import '../../features/maze_ball/domain/repositories/sensor_repository.dart';
import '../../features/maze_ball/domain/usecases/game_usecase.dart';
import '../../features/maze_ball/domain/usecases/physics_usecase.dart';
import '../../features/maze_ball/presentation/viewmodels/maze_ball_viewmodel.dart';

/// 依存性注入コンテナ
final sl = GetIt.instance;

/// 依存性を初期化
Future<void> init() async {
  // ViewModels
  sl.registerFactory<MazeBallViewModel>(
    () => MazeBallViewModel(gameUseCase: sl(), sensorRepository: sl()),
  );

  // UseCases
  sl.registerLazySingleton<GameUseCase>(
    () => GameUseCase(
      mazeRepository: sl(),
      gameRepository: sl(),
      physicsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton<PhysicsUseCase>(() => PhysicsUseCase());

  // Repositories
  sl.registerLazySingleton<MazeRepository>(
    () => MazeRepositoryImpl(mazeGenerator: sl()),
  );

  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(localStorageDataSource: sl()),
  );

  sl.registerLazySingleton<SensorRepository>(
    () => SensorRepositoryImpl(sensorDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<MazeGenerator>(() => MazeGenerator());
  sl.registerLazySingleton<LocalStorageDataSource>(
    () => LocalStorageDataSource(),
  );
  sl.registerLazySingleton<SensorDataSource>(() => SensorDataSource());
}
