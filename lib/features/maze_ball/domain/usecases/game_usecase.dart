import 'package:vector_math/vector_math.dart' as vm;
import '../../../../shared/constants/game_constants.dart';
import '../entities/ball.dart';
import '../entities/game_state.dart';
import '../repositories/game_repository.dart';
import '../repositories/maze_repository.dart';
import 'physics_usecase.dart';

/// ゲームロジックユースケース
class GameUseCase {
  final MazeRepository _mazeRepository;
  final GameRepository _gameRepository;
  final PhysicsUseCase _physicsUseCase;

  GameUseCase({
    required MazeRepository mazeRepository,
    required GameRepository gameRepository,
    required PhysicsUseCase physicsUseCase,
  }) : _mazeRepository = mazeRepository,
       _gameRepository = gameRepository,
       _physicsUseCase = physicsUseCase;

  /// ゲームを初期化
  Future<GameState> initializeGame() async {
    final maze = await _mazeRepository.getMazeForLevel(1);
    final ball = Ball(
      position: vm.Vector2(1.0, 1.0),
      velocity: vm.Vector2.zero(),
      radius: GameConstants.ballRadius,
    );

    return GameState(
      ball: ball,
      maze: maze,
      tiltForce: vm.Vector2.zero(),
      isGameWon: false,
      level: 1,
      startTime: DateTime.now(),
      zoomLevel: 1.0,
    );
  }

  /// ゲーム状態を更新
  GameState updateGameState(GameState gameState, vm.Vector2 tiltForce) {
    if (gameState.isGameWon) return gameState;

    // 物理演算でボールを更新
    final updatedBall = _physicsUseCase.updateBallPhysics(
      gameState.ball,
      tiltForce,
      gameState.maze,
    );

    // ゴール判定
    final isGoalReached = _physicsUseCase.checkGoalReached(
      updatedBall,
      gameState.maze,
    );

    return gameState.copyWith(
      ball: updatedBall,
      tiltForce: tiltForce,
      isGameWon: isGoalReached,
    );
  }

  /// 次のレベルに進む
  Future<GameState> nextLevel(GameState gameState) async {
    final nextLevel = gameState.level + 1;
    final maze = await _mazeRepository.getMazeForLevel(nextLevel);
    final ball = Ball(
      position: vm.Vector2(1.0, 1.0),
      velocity: vm.Vector2.zero(),
      radius: GameConstants.ballRadius,
    );

    // 前のレベルの記録を保存
    if (gameState.elapsedTime != null) {
      await _gameRepository.saveBestTime(
        gameState.level,
        gameState.elapsedTime!,
      );
    }

    return GameState(
      ball: ball,
      maze: maze,
      tiltForce: vm.Vector2.zero(),
      isGameWon: false,
      level: nextLevel,
      startTime: DateTime.now(),
      zoomLevel: gameState.zoomLevel,
    );
  }

  /// ゲームをリセット
  Future<GameState> resetGame() async {
    await _gameRepository.resetGameState();
    return initializeGame();
  }

  /// ズームレベルを更新
  GameState updateZoomLevel(GameState gameState, double zoomLevel) {
    final clampedZoom = zoomLevel.clamp(
      GameConstants.minZoom,
      GameConstants.maxZoom,
    );
    return gameState.copyWith(zoomLevel: clampedZoom);
  }

  /// ゲーム状態を保存
  Future<void> saveGame(GameState gameState) async {
    await _gameRepository.saveGameState(gameState);
  }

  /// 最高記録を取得
  Future<Duration?> getBestTime(int level) async {
    return await _gameRepository.getBestTime(level);
  }
}
