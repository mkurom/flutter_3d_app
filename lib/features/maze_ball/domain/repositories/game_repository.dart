import 'package:flutter_3d_app/features/maze_ball/domain/entities/game_state.dart';

/// ゲーム状態の抽象リポジトリ
abstract class GameRepository {
  /// ゲーム状態を保存
  Future<void> saveGameState(GameState gameState);

  /// ゲーム状態を読み込み
  Future<GameState?> loadGameState();

  /// ゲーム状態をリセット
  Future<void> resetGameState();

  /// 最高記録を保存
  Future<void> saveBestTime(int level, Duration time);

  /// 最高記録を取得
  Future<Duration?> getBestTime(int level);
}
