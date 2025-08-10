import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/shared/constants/game_constants.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/ball.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';

/// 物理演算ユースケース
class PhysicsUseCase {
  /// ボールの物理演算を更新
  Ball updateBallPhysics(Ball ball, vm.Vector2 tiltForce, Maze maze) {
    // 重力（傾き）による加速
    final gravity = vm.Vector2(tiltForce.x, tiltForce.y);
    var newVelocity = ball.velocity + gravity;

    // 速度制限
    if (newVelocity.length > GameConstants.maxSpeed) {
      newVelocity = newVelocity.normalized() * GameConstants.maxSpeed;
    }

    // 新しい位置を計算
    final newPosition = ball.position + newVelocity;

    // 壁との衝突判定
    final resolvedPosition = _resolveCollisions(
      newPosition,
      ball.radius,
      maze,
      newVelocity,
    );

    // 摩擦力を適用
    newVelocity *= GameConstants.friction;

    return ball.copyWith(position: resolvedPosition, velocity: newVelocity);
  }

  /// ボールがゴールに到達しているかチェック
  bool checkGoalReached(Ball ball, Maze maze) {
    final mazeX = ball.position.x.floor();
    final mazeY = ball.position.y.floor();

    // ボールがゴールエリアに重なっているかチェック
    for (int checkY = mazeY; checkY <= mazeY + 1; checkY++) {
      for (int checkX = mazeX; checkX <= mazeX + 1; checkX++) {
        if (checkX >= 0 &&
            checkX < maze.width &&
            checkY >= 0 &&
            checkY < maze.height &&
            maze.isGoal(checkX, checkY)) {
          // ボールの中心とゴールの距離をチェック
          final goalCenterX = checkX + 0.5;
          final goalCenterY = checkY + 0.5;
          final distance = math.sqrt(
            math.pow(ball.position.x - goalCenterX, 2) +
                math.pow(ball.position.y - goalCenterY, 2),
          );

          // ボールがゴールに十分近い場合
          if (distance < 0.7) {
            // ボールの半径 + マージン
            return true;
          }
        }
      }
    }
    return false;
  }

  vm.Vector2 _resolveCollisions(
    vm.Vector2 newPosition,
    double ballRadius,
    Maze maze,
    vm.Vector2 velocity,
  ) {
    final result = vm.Vector2.copy(newPosition);

    // X方向の衝突判定
    final leftEdge = (result.x - ballRadius).floor();
    final rightEdge = (result.x + ballRadius).ceil();
    final topEdge = (result.y - ballRadius).floor();
    final bottomEdge = (result.y + ballRadius).ceil();

    // 壁との衝突をチェック
    for (
      int checkY = math.max(0, topEdge);
      checkY <= math.min(maze.height - 1, bottomEdge);
      checkY++
    ) {
      for (
        int checkX = math.max(0, leftEdge);
        checkX <= math.min(maze.width - 1, rightEdge);
        checkX++
      ) {
        if (maze.isWall(checkX, checkY)) {
          // 壁との距離を計算
          final wallCenterX = checkX + 0.5;
          final wallCenterY = checkY + 0.5;

          final dx = result.x - wallCenterX;
          final dy = result.y - wallCenterY;

          final distance = math.sqrt(dx * dx + dy * dy);
          final minDistance = ballRadius + 0.5; // 壁の半径 + ボールの半径

          if (distance < minDistance) {
            // 衝突を解決
            final pushDirection = vm.Vector2(dx, dy).normalized();
            final pushAmount = minDistance - distance;
            result.add(pushDirection * pushAmount);

            // 速度の反射（簡略化）
            final normal = pushDirection;
            final dot = velocity.dot(normal);
            velocity.sub(normal * (dot * 1.5));
          }
        }
      }
    }

    return result;
  }
}
