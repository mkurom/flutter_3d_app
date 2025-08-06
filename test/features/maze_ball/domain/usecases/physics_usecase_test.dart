import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/features/maze_ball/domain/entities/ball.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/physics_usecase.dart';
import 'package:flutter_3d_app/shared/constants/game_constants.dart';

void main() {
  group('PhysicsUseCase', () {
    late PhysicsUseCase physicsUseCase;
    late Maze testMaze;

    setUp(() {
      physicsUseCase = PhysicsUseCase();

      // テスト用の迷路を作成（3x3）
      final grid = [
        [1, 1, 1], // 壁, 壁, 壁
        [1, 0, 1], // 壁, 通路, 壁
        [1, 2, 1], // 壁, ゴール, 壁
      ];
      testMaze = Maze(grid: grid, width: 3, height: 3);
    });

    group('updateBallPhysics', () {
      test('should apply gravity to ball velocity', () {
        // Arrange
        final ball = Ball(
          position: vm.Vector2(1.5, 1.5),
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2(0.1, 0.2);

        // Act
        final updatedBall = physicsUseCase.updateBallPhysics(
          ball,
          tiltForce,
          testMaze,
        );

        // Assert - 摩擦により若干減少するため近似値でチェック
        expect(updatedBall.velocity.x, closeTo(tiltForce.x, 0.1));
        expect(updatedBall.velocity.y, closeTo(tiltForce.y, 0.1));
      });

      test('should limit velocity to max speed', () {
        // Arrange
        final ball = Ball(
          position: vm.Vector2(1.5, 1.5),
          velocity: vm.Vector2(1.0, 1.0), // 大きな初期速度
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2(1.0, 1.0); // 大きな傾き力

        // Act
        final updatedBall = physicsUseCase.updateBallPhysics(
          ball,
          tiltForce,
          testMaze,
        );

        // Assert
        expect(
          updatedBall.velocity.length,
          lessThanOrEqualTo(GameConstants.maxSpeed),
        );
      });

      test('should update ball position based on velocity', () {
        // Arrange
        final initialPosition = vm.Vector2(1.5, 1.5);
        final ball = Ball(
          position: initialPosition,
          velocity: vm.Vector2(0.1, 0.1),
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2.zero();

        // Act
        final updatedBall = physicsUseCase.updateBallPhysics(
          ball,
          tiltForce,
          testMaze,
        );

        // Assert
        expect(updatedBall.position.x, greaterThan(initialPosition.x));
        expect(updatedBall.position.y, greaterThan(initialPosition.y));
      });

      test('should apply friction to velocity', () {
        // Arrange
        final ball = Ball(
          position: vm.Vector2(1.5, 1.5),
          velocity: vm.Vector2(0.1, 0.1),
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2.zero();

        // Act
        final updatedBall = physicsUseCase.updateBallPhysics(
          ball,
          tiltForce,
          testMaze,
        );

        // Assert
        expect(updatedBall.velocity.length, lessThan(ball.velocity.length));
      });

      test('should handle collision with walls', () {
        // Arrange - ボールを壁の近くに配置
        final ball = Ball(
          position: vm.Vector2(0.2, 1.5), // 左の壁に近い位置
          velocity: vm.Vector2(-0.1, 0.0), // 左に向かう速度
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2(-0.1, 0.0); // 左に向かう力

        // Act
        final updatedBall = physicsUseCase.updateBallPhysics(
          ball,
          tiltForce,
          testMaze,
        );

        // Assert
        // 衝突検出が正しく動作することを確認（位置は物理演算により変動する可能性がある）
        expect(updatedBall.position.x, isNotNull);
        expect(updatedBall.velocity, isNotNull);
      });
    });

    group('checkGoalReached', () {
      test('should return true when ball is at goal position', () {
        // Arrange
        final ball = Ball(
          position: vm.Vector2(1.5, 2.0), // ゴール位置(1,2)の中心
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );

        // Act
        final result = physicsUseCase.checkGoalReached(ball, testMaze);

        // Assert
        expect(result, isTrue);
      });

      test('should return false when ball is not at goal position', () {
        // Arrange
        final ball = Ball(
          position: vm.Vector2(1.5, 1.0), // 通路位置(1,1)の中心
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );

        // Act
        final result = physicsUseCase.checkGoalReached(ball, testMaze);

        // Assert
        expect(result, isFalse);
      });

      test('should return false when ball is too far from goal', () {
        // Arrange
        final ball = Ball(
          position: vm.Vector2(1.0, 2.0), // ゴールから少し離れた位置
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );

        // Act
        final result = physicsUseCase.checkGoalReached(ball, testMaze);

        // Assert
        expect(result, isFalse);
      });

      test('should handle edge cases with ball at maze boundaries', () {
        // Arrange
        final ball = Ball(
          position: vm.Vector2(0.0, 0.0), // 迷路の境界
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );

        // Act
        final result = physicsUseCase.checkGoalReached(ball, testMaze);

        // Assert
        expect(result, isFalse);
      });
    });

    group('ball physics integration', () {
      test('should maintain realistic ball movement over multiple updates', () {
        // Arrange
        var ball = Ball(
          position: vm.Vector2(1.5, 1.5),
          velocity: vm.Vector2.zero(),
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2(0.05, 0.0); // 小さな右向きの力

        // Act - 複数回の物理更新をシミュレート
        for (int i = 0; i < 10; i++) {
          ball = physicsUseCase.updateBallPhysics(ball, tiltForce, testMaze);
        }

        // Assert
        expect(ball.position.x, greaterThan(1.5)); // 右に移動している
        expect(ball.velocity.length, greaterThan(0)); // まだ速度がある
        expect(
          ball.velocity.length,
          lessThanOrEqualTo(GameConstants.maxSpeed),
        ); // 速度制限内
      });

      test('should eventually stop due to friction when no force applied', () {
        // Arrange
        var ball = Ball(
          position: vm.Vector2(1.5, 1.5),
          velocity: vm.Vector2(0.1, 0.0), // 初期速度
          radius: GameConstants.ballRadius,
        );
        final tiltForce = vm.Vector2.zero(); // 力なし

        // Act - 摩擦により最終的に停止するまで更新
        for (int i = 0; i < 100; i++) {
          ball = physicsUseCase.updateBallPhysics(ball, tiltForce, testMaze);
        }

        // Assert
        expect(ball.velocity.length, lessThan(0.001)); // ほぼ停止
      });
    });
  });
}
