import 'package:riverpod/riverpod.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/maze_generator.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/local_storage_datasource.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/sensor_datasource.dart';
import 'package:flutter_3d_app/features/maze_ball/data/repositories/game_repository_impl.dart';
import 'package:flutter_3d_app/features/maze_ball/data/repositories/maze_repository_impl.dart';
import 'package:flutter_3d_app/features/maze_ball/data/repositories/sensor_repository_impl.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/game_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/maze_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/sensor_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/game_usecase.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/physics_usecase.dart';

// === Data Sources ===

final mazeGeneratorProvider = Provider<MazeGenerator>((ref) {
  return MazeGenerator();
});

final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
  return LocalStorageDataSource();
});

final sensorDataSourceProvider = Provider<SensorDataSource>((ref) {
  return SensorDataSource();
});

// === Repositories ===

final mazeRepositoryProvider = Provider<MazeRepository>((ref) {
  return MazeRepositoryImpl(mazeGenerator: ref.watch(mazeGeneratorProvider));
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    localStorageDataSource: ref.watch(localStorageDataSourceProvider),
  );
});

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepositoryImpl(
    sensorDataSource: ref.watch(sensorDataSourceProvider),
  );
});

// === Use Cases ===

final physicsUseCaseProvider = Provider<PhysicsUseCase>((ref) {
  return PhysicsUseCase();
});

final gameUseCaseProvider = Provider<GameUseCase>((ref) {
  return GameUseCase(
    mazeRepository: ref.watch(mazeRepositoryProvider),
    gameRepository: ref.watch(gameRepositoryProvider),
    physicsUseCase: ref.watch(physicsUseCaseProvider),
  );
});
