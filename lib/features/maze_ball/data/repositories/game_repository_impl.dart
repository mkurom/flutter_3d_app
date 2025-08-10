import 'package:flutter_3d_app/features/maze_ball/domain/entities/game_state.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/game_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/local_storage_datasource.dart';

/// ゲームリポジトリの実装
class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl({required LocalStorageDataSource localStorageDataSource})
    : _localStorageDataSource = localStorageDataSource;
  final LocalStorageDataSource _localStorageDataSource;

  @override
  Future<void> saveGameState(GameState gameState) async {
    await _localStorageDataSource.saveGameState(gameState);
  }

  @override
  Future<GameState?> loadGameState() async {
    return _localStorageDataSource.loadGameState();
  }

  @override
  Future<void> resetGameState() async {
    await _localStorageDataSource.resetGameState();
  }

  @override
  Future<void> saveBestTime(int level, Duration time) async {
    await _localStorageDataSource.saveBestTime(level, time);
  }

  @override
  Future<Duration?> getBestTime(int level) async {
    return _localStorageDataSource.getBestTime(level);
  }
}
