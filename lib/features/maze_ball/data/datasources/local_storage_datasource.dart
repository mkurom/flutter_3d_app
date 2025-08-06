import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/game_state.dart';

/// ローカルストレージデータソース
class LocalStorageDataSource {
  static const String _gameStateKey = 'maze_ball_game_state';
  static const String _bestTimePrefix = 'maze_ball_best_time_level_';

  /// ゲーム状態を保存
  Future<void> saveGameState(GameState gameState) async {
    final prefs = await SharedPreferences.getInstance();
    final gameStateJson = _gameStateToJson(gameState);
    await prefs.setString(_gameStateKey, jsonEncode(gameStateJson));
  }

  /// ゲーム状態を読み込み
  Future<GameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final gameStateString = prefs.getString(_gameStateKey);

    if (gameStateString == null) return null;

    try {
      final gameStateJson = jsonDecode(gameStateString);
      return _gameStateFromJson(gameStateJson);
    } catch (e) {
      // JSONの解析に失敗した場合はnullを返す
      return null;
    }
  }

  /// ゲーム状態をリセット
  Future<void> resetGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
  }

  /// 最高記録を保存
  Future<void> saveBestTime(int level, Duration time) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_bestTimePrefix$level';
    await prefs.setInt(key, time.inMilliseconds);
  }

  /// 最高記録を取得
  Future<Duration?> getBestTime(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_bestTimePrefix$level';
    final milliseconds = prefs.getInt(key);

    if (milliseconds == null) return null;
    return Duration(milliseconds: milliseconds);
  }

  /// GameStateをJSONに変換
  Map<String, dynamic> _gameStateToJson(GameState gameState) {
    return {
      'ballPositionX': gameState.ball.position.x,
      'ballPositionY': gameState.ball.position.y,
      'ballVelocityX': gameState.ball.velocity.x,
      'ballVelocityY': gameState.ball.velocity.y,
      'ballRadius': gameState.ball.radius,
      'mazeGrid': gameState.maze.grid,
      'mazeWidth': gameState.maze.width,
      'mazeHeight': gameState.maze.height,
      'tiltForceX': gameState.tiltForce.x,
      'tiltForceY': gameState.tiltForce.y,
      'isGameWon': gameState.isGameWon,
      'level': gameState.level,
      'startTime': gameState.startTime?.millisecondsSinceEpoch,
      'zoomLevel': gameState.zoomLevel,
    };
  }

  /// JSONからGameStateに変換
  GameState _gameStateFromJson(Map<String, dynamic> json) {
    // 現在は簡略化のため、実装をスキップ
    // 実際のプロダクションでは適切なシリアライゼーションが必要
    throw UnimplementedError('JSON からの GameState 復元は実装が必要');
  }
}
