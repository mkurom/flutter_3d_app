import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/features/maze_ball/domain/entities/ball.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/game_state.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/game_usecase.dart';
import 'package:flutter_3d_app/shared/constants/game_constants.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  group('GameUseCase', () {
    late GameUseCase gameUseCase;
    late MockMazeRepository mockMazeRepository;
    late MockGameRepository mockGameRepository;
    late MockPhysicsUseCase mockPhysicsUseCase;

    setUp(() {
      mockMazeRepository = MockMazeRepository();
      mockGameRepository = MockGameRepository();
      mockPhysicsUseCase = MockPhysicsUseCase();

      gameUseCase = GameUseCase(
        mazeRepository: mockMazeRepository,
        gameRepository: mockGameRepository,
        physicsUseCase: mockPhysicsUseCase,
      );
    });

    group('initializeGame', () {
      test('should initialize game with correct initial state', () async {
        // Arrange
        final testMaze = const Maze(
          grid: [
            [1, 0],
            [0, 2],
          ],
          width: 2,
          height: 2,
        );
        when(
          mockMazeRepository.getMazeForLevel(1),
        ).thenAnswer((_) async => testMaze);

        // Act
        final gameState = await gameUseCase.initializeGame();

        // Assert
        expect(gameState.ball.position, equals(vm.Vector2(1.0, 1.0)));
        expect(gameState.ball.velocity, equals(vm.Vector2.zero()));
        expect(gameState.ball.radius, equals(GameConstants.ballRadius));
        expect(gameState.maze, equals(testMaze));
        expect(gameState.tiltForce, equals(vm.Vector2.zero()));
        expect(gameState.isGameWon, isFalse);
        expect(gameState.level, equals(1));
        expect(gameState.startTime, isNotNull);
        expect(gameState.zoomLevel, equals(1.0));

        verify(mockMazeRepository.getMazeForLevel(1)).called(1);
      });
    });

    group('updateGameState', () {
      test('should update game state when game is not won', () {
        // Arrange
        final initialBall = Ball(
          position: vm.Vector2(1.0, 1.0),
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );
        final maze = const Maze(
          grid: [
            [0],
          ],
          width: 1,
          height: 1,
        );
        final gameState = GameState(
          ball: initialBall,
          maze: maze,
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: DateTime.now(),
          zoomLevel: 1.0,
        );

        final updatedBall = Ball(
          position: vm.Vector2(1.1, 1.1),
          velocity: vm.Vector2(0.1, 0.1),
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2(0.1, 0.1);

        when(
          mockPhysicsUseCase.updateBallPhysics(initialBall, tiltForce, maze),
        ).thenReturn(updatedBall);
        when(
          mockPhysicsUseCase.checkGoalReached(updatedBall, maze),
        ).thenReturn(false);

        // Act
        final result = gameUseCase.updateGameState(gameState, tiltForce);

        // Assert
        expect(result.ball, equals(updatedBall));
        expect(result.tiltForce, equals(tiltForce));
        expect(result.isGameWon, isFalse);

        verify(
          mockPhysicsUseCase.updateBallPhysics(initialBall, tiltForce, maze),
        ).called(1);
        verify(
          mockPhysicsUseCase.checkGoalReached(updatedBall, maze),
        ).called(1);
      });

      test('should mark game as won when goal is reached', () {
        // Arrange
        final initialBall = Ball(
          position: vm.Vector2(1.0, 1.0),
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );
        final maze = const Maze(
          grid: [
            [2],
          ],
          width: 1,
          height: 1,
        );
        final gameState = GameState(
          ball: initialBall,
          maze: maze,
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: DateTime.now(),
          zoomLevel: 1.0,
        );

        final updatedBall = Ball(
          position: vm.Vector2(1.5, 1.5),
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2.zero();

        when(
          mockPhysicsUseCase.updateBallPhysics(initialBall, tiltForce, maze),
        ).thenReturn(updatedBall);
        when(
          mockPhysicsUseCase.checkGoalReached(updatedBall, maze),
        ).thenReturn(true);

        // Act
        final result = gameUseCase.updateGameState(gameState, tiltForce);

        // Assert
        expect(result.isGameWon, isTrue);
      });

      test('should not update when game is already won', () {
        // Arrange
        final gameState = GameState(
          ball: Ball(
            position: vm.Vector2(1.0, 1.0),
            velocity: vm.Vector2.zero(),
            radius: GameConstants.ballRadius,
          ),
          maze: const Maze(
            grid: [
              [0],
            ],
            width: 1,
            height: 1,
          ),
          tiltForce: vm.Vector2.zero(),
          isGameWon: true, // すでに勝利済み
          level: 1,
          startTime: DateTime.now(),
          zoomLevel: 1.0,
        );
        final tiltForce = vm.Vector2(0.1, 0.1);

        // Act
        final result = gameUseCase.updateGameState(gameState, tiltForce);

        // Assert
        expect(result, equals(gameState)); // 変更されない
        verifyNever(mockPhysicsUseCase.updateBallPhysics(any, any, any));
        verifyNever(mockPhysicsUseCase.checkGoalReached(any, any));
      });
    });

    group('nextLevel', () {
      test('should advance to next level and save best time', () async {
        // Arrange
        final currentGameState = GameState(
          ball: Ball(
            position: vm.Vector2(1.0, 1.0),
            velocity: vm.Vector2.zero(),
            radius: GameConstants.ballRadius,
          ),
          maze: const Maze(
            grid: [
              [0],
            ],
            width: 1,
            height: 1,
          ),
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: DateTime.now().subtract(const Duration(seconds: 30)),
          zoomLevel: 1.5,
        );

        final nextLevelMaze = const Maze(
          grid: [
            [1, 0],
            [0, 2],
          ],
          width: 2,
          height: 2,
        );

        when(
          mockMazeRepository.getMazeForLevel(2),
        ).thenAnswer((_) async => nextLevelMaze);
        when(mockGameRepository.saveBestTime(any, any)).thenAnswer((_) async {
          return;
        });

        // Act
        final result = await gameUseCase.nextLevel(currentGameState);

        // Assert
        expect(result.level, equals(2));
        expect(result.maze, equals(nextLevelMaze));
        expect(result.ball.position, equals(vm.Vector2(1.0, 1.0))); // リセット
        expect(result.ball.velocity, equals(vm.Vector2.zero())); // リセット
        expect(result.isGameWon, isFalse); // リセット
        expect(result.zoomLevel, equals(1.5)); // 保持
        expect(result.startTime, isNotNull);

        verify(mockMazeRepository.getMazeForLevel(2)).called(1);
        verify(mockGameRepository.saveBestTime(1, any)).called(1);
      });

      test('should not save best time when elapsed time is null', () async {
        // Arrange
        final currentGameState = GameState(
          ball: Ball(
            position: vm.Vector2(1.0, 1.0),
            velocity: vm.Vector2.zero(),
            radius: GameConstants.ballRadius,
          ),
          maze: const Maze(
            grid: [
              [0],
            ],
            width: 1,
            height: 1,
          ),
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: null, // null startTime
          zoomLevel: 1.0,
        );

        final nextLevelMaze = const Maze(
          grid: [
            [0],
          ],
          width: 1,
          height: 1,
        );
        when(
          mockMazeRepository.getMazeForLevel(2),
        ).thenAnswer((_) async => nextLevelMaze);

        // Act
        await gameUseCase.nextLevel(currentGameState);

        // Assert
        verifyNever(mockGameRepository.saveBestTime(any, any));
      });
    });

    group('resetGame', () {
      test('should reset game state and initialize new game', () async {
        // Arrange
        final testMaze = const Maze(
          grid: [
            [0],
          ],
          width: 1,
          height: 1,
        );
        when(mockGameRepository.resetGameState()).thenAnswer((_) async {
          return;
        });
        when(
          mockMazeRepository.getMazeForLevel(1),
        ).thenAnswer((_) async => testMaze);

        // Act
        final result = await gameUseCase.resetGame();

        // Assert
        expect(result.level, equals(1));
        expect(result.isGameWon, isFalse);
        expect(result.ball.position, equals(vm.Vector2(1.0, 1.0)));

        verify(mockGameRepository.resetGameState()).called(1);
        verify(mockMazeRepository.getMazeForLevel(1)).called(1);
      });
    });

    group('updateZoomLevel', () {
      test('should update zoom level within valid range', () {
        // Arrange
        final gameState = GameState(
          ball: Ball(
            position: vm.Vector2(1.0, 1.0),
            velocity: vm.Vector2.zero(),
            radius: GameConstants.ballRadius,
          ),
          maze: const Maze(
            grid: [
              [0],
            ],
            width: 1,
            height: 1,
          ),
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: DateTime.now(),
          zoomLevel: 1.0,
        );

        // Act
        final result = gameUseCase.updateZoomLevel(gameState, 2.0);

        // Assert
        expect(result.zoomLevel, equals(2.0));
      });

      test('should clamp zoom level to minimum', () {
        // Arrange
        final gameState = GameState(
          ball: Ball(
            position: vm.Vector2(1.0, 1.0),
            velocity: vm.Vector2.zero(),
            radius: GameConstants.ballRadius,
          ),
          maze: const Maze(
            grid: [
              [0],
            ],
            width: 1,
            height: 1,
          ),
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: DateTime.now(),
          zoomLevel: 1.0,
        );

        // Act
        final result = gameUseCase.updateZoomLevel(gameState, 0.1); // 最小値以下

        // Assert
        expect(result.zoomLevel, equals(GameConstants.minZoom));
      });

      test('should clamp zoom level to maximum', () {
        // Arrange
        final gameState = GameState(
          ball: Ball(
            position: vm.Vector2(1.0, 1.0),
            velocity: vm.Vector2.zero(),
            radius: GameConstants.ballRadius,
          ),
          maze: const Maze(
            grid: [
              [0],
            ],
            width: 1,
            height: 1,
          ),
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: DateTime.now(),
          zoomLevel: 1.0,
        );

        // Act
        final result = gameUseCase.updateZoomLevel(gameState, 5.0); // 最大値以上

        // Assert
        expect(result.zoomLevel, equals(GameConstants.maxZoom));
      });
    });

    group('saveGame', () {
      test('should save game state', () async {
        // Arrange
        final gameState = GameState(
          ball: Ball(
            position: vm.Vector2(1.0, 1.0),
            velocity: vm.Vector2.zero(),
            radius: GameConstants.ballRadius,
          ),
          maze: const Maze(
            grid: [
              [0],
            ],
            width: 1,
            height: 1,
          ),
          tiltForce: vm.Vector2.zero(),
          isGameWon: false,
          level: 1,
          startTime: DateTime.now(),
          zoomLevel: 1.0,
        );

        when(mockGameRepository.saveGameState(gameState)).thenAnswer((_) async {
          return;
        });

        // Act
        await gameUseCase.saveGame(gameState);

        // Assert
        verify(mockGameRepository.saveGameState(gameState)).called(1);
      });
    });

    group('getBestTime', () {
      test('should return best time for level', () async {
        // Arrange
        const level = 1;
        final expectedTime = const Duration(seconds: 30);
        when(
          mockGameRepository.getBestTime(level),
        ).thenAnswer((_) async => expectedTime);

        // Act
        final result = await gameUseCase.getBestTime(level);

        // Assert
        expect(result, equals(expectedTime));
        verify(mockGameRepository.getBestTime(level)).called(1);
      });
    });
  });
}
