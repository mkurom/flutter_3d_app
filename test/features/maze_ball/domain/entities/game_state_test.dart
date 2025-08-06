import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/features/maze_ball/domain/entities/ball.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/game_state.dart';

void main() {
  group('GameState Entity', () {
    late Ball testBall;
    late Maze testMaze;
    late GameState testGameState;

    setUp(() {
      testBall = Ball(
        position: vm.Vector2(1.0, 1.0),
        velocity: vm.Vector2.zero(),
        radius: 0.15,
      );

      final grid = [
        [1, 0],
        [0, 2],
      ];
      testMaze = Maze(grid: grid, width: 2, height: 2);

      testGameState = GameState(
        ball: testBall,
        maze: testMaze,
        tiltForce: vm.Vector2.zero(),
        isGameWon: false,
        level: 1,
        startTime: DateTime(2024, 1, 1, 12, 0, 0),
        zoomLevel: 1.0,
      );
    });

    test('should create a game state with correct properties', () {
      // Assert
      expect(testGameState.ball, equals(testBall));
      expect(testGameState.maze, equals(testMaze));
      expect(testGameState.tiltForce, equals(vm.Vector2.zero()));
      expect(testGameState.isGameWon, isFalse);
      expect(testGameState.level, equals(1));
      expect(testGameState.startTime, equals(DateTime(2024, 1, 1, 12, 0, 0)));
      expect(testGameState.zoomLevel, equals(1.0));
    });

    test('should create a copy with updated properties', () {
      // Arrange
      final newBall = Ball(
        position: vm.Vector2(2.0, 2.0),
        velocity: vm.Vector2(1.0, 0.0),
        radius: 0.15,
      );
      final newTiltForce = vm.Vector2(0.5, 0.3);

      // Act
      final copiedGameState = testGameState.copyWith(
        ball: newBall,
        tiltForce: newTiltForce,
        isGameWon: true,
        level: 2,
      );

      // Assert
      expect(copiedGameState.ball, equals(newBall));
      expect(copiedGameState.tiltForce, equals(newTiltForce));
      expect(copiedGameState.isGameWon, isTrue);
      expect(copiedGameState.level, equals(2));
      expect(copiedGameState.maze, equals(testMaze)); // 変更されていない
      expect(copiedGameState.zoomLevel, equals(1.0)); // 変更されていない
    });

    test('should calculate elapsed time correctly', () {
      // Arrange
      final startTime = DateTime.now().subtract(const Duration(seconds: 30));
      final gameState = testGameState.copyWith(startTime: startTime);

      // Act
      final elapsedTime = gameState.elapsedTime;

      // Assert
      expect(elapsedTime, isNotNull);
      expect(elapsedTime!.inSeconds, greaterThanOrEqualTo(29));
      expect(elapsedTime.inSeconds, lessThanOrEqualTo(31));
    });

    test('should return null elapsed time when start time is null', () {
      // Arrange
      final gameState = GameState(
        ball: testBall,
        maze: testMaze,
        tiltForce: vm.Vector2.zero(),
        isGameWon: false,
        level: 1,
        startTime: null, // explicitly null
        zoomLevel: 1.0,
      );

      // Act
      final elapsedTime = gameState.elapsedTime;

      // Assert
      expect(elapsedTime, isNull);
    });

    test('should handle start time being null in copyWith', () {
      // Act
      final gameStateWithNullStartTime = GameState(
        ball: testBall,
        maze: testMaze,
        tiltForce: vm.Vector2.zero(),
        isGameWon: false,
        level: 1,
        startTime: null, // null startTime
        zoomLevel: 1.0,
      );

      // Assert
      expect(gameStateWithNullStartTime.startTime, isNull);
      expect(gameStateWithNullStartTime.elapsedTime, isNull);
    });

    test('should implement equality correctly', () {
      // Arrange
      final gameState1 = GameState(
        ball: testBall,
        maze: testMaze,
        tiltForce: vm.Vector2.zero(),
        isGameWon: false,
        level: 1,
        startTime: DateTime(2024, 1, 1, 12, 0, 0),
        zoomLevel: 1.0,
      );

      final gameState2 = GameState(
        ball: testBall,
        maze: testMaze,
        tiltForce: vm.Vector2.zero(),
        isGameWon: false,
        level: 1,
        startTime: DateTime(2024, 1, 1, 12, 0, 0),
        zoomLevel: 1.0,
      );

      final gameState3 = gameState1.copyWith(level: 2);

      // Assert
      expect(gameState1, equals(gameState2)); // 同じプロパティ
      expect(gameState1, isNot(equals(gameState3))); // 異なるプロパティ
    });
  });
}
