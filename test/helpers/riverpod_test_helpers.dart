import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_3d_app/core/providers/dependency_providers.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/game_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/maze_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/sensor_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/physics_usecase.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/game_usecase.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/maze_generator.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/local_storage_datasource.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/sensor_datasource.dart';

/// テスト用のプロバイダーオーバーライドを作成するヘルパー
class RiverpodTestHelpers {
  /// モックされたプロバイダーでProviderContainerを作成
  static ProviderContainer createContainer({
    GameRepository? mockGameRepository,
    MazeRepository? mockMazeRepository,
    SensorRepository? mockSensorRepository,
    PhysicsUseCase? mockPhysicsUseCase,
    GameUseCase? mockGameUseCase,
    MazeGenerator? mockMazeGenerator,
    LocalStorageDataSource? mockLocalStorageDataSource,
    SensorDataSource? mockSensorDataSource,
  }) {
    final overrides = <Override>[];

    // Data Sources
    if (mockMazeGenerator != null) {
      overrides.add(mazeGeneratorProvider.overrideWithValue(mockMazeGenerator));
    }
    if (mockLocalStorageDataSource != null) {
      overrides.add(
        localStorageDataSourceProvider.overrideWithValue(
          mockLocalStorageDataSource,
        ),
      );
    }
    if (mockSensorDataSource != null) {
      overrides.add(
        sensorDataSourceProvider.overrideWithValue(mockSensorDataSource),
      );
    }

    // Repositories
    if (mockGameRepository != null) {
      overrides.add(
        gameRepositoryProvider.overrideWithValue(mockGameRepository),
      );
    }
    if (mockMazeRepository != null) {
      overrides.add(
        mazeRepositoryProvider.overrideWithValue(mockMazeRepository),
      );
    }
    if (mockSensorRepository != null) {
      overrides.add(
        sensorRepositoryProvider.overrideWithValue(mockSensorRepository),
      );
    }

    // Use Cases
    if (mockPhysicsUseCase != null) {
      overrides.add(
        physicsUseCaseProvider.overrideWithValue(mockPhysicsUseCase),
      );
    }
    if (mockGameUseCase != null) {
      overrides.add(gameUseCaseProvider.overrideWithValue(mockGameUseCase));
    }

    return ProviderContainer(overrides: overrides);
  }

  /// テスト用のProviderScopeでウィジェットをラップ
  static ProviderScope wrapWithProviderScope(
    Widget child, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(overrides: overrides, child: child);
  }
}
