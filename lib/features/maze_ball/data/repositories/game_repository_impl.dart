import '../../domain/entities/game_state.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local_storage_datasource.dart';

/// ゲームリポジトリの実装
class GameRepositoryImpl implements GameRepository {
  final LocalStorageDataSource _localStorageDataSource;

  GameRepositoryImpl({required LocalStorageDataSource localStorageDataSource})
    : _localStorageDataSource = localStorageDataSource;

  @override
  Future<void> saveGameState(GameState gameState) async {
    await _localStorageDataSource.saveGameState(gameState);
  }

  @override
  Future<GameState?> loadGameState() async {
    return await _localStorageDataSource.loadGameState();
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
    return await _localStorageDataSource.getBestTime(level);
  }
}
