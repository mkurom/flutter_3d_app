import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/features/maze_ball/domain/entities/ball.dart';

void main() {
  group('Ball Entity', () {
    test('should create a ball with correct properties', () {
      // Arrange
      final position = vm.Vector2(1.0, 2.0);
      final velocity = vm.Vector2(0.5, -0.3);
      const radius = 0.15;

      // Act
      final ball = Ball(position: position, velocity: velocity, radius: radius);

      // Assert
      expect(ball.position, equals(position));
      expect(ball.velocity, equals(velocity));
      expect(ball.radius, equals(radius));
    });

    test('should create a copy with updated properties', () {
      // Arrange
      final originalBall = Ball(
        position: vm.Vector2(1.0, 2.0),
        velocity: vm.Vector2(0.5, -0.3),
        radius: 0.15,
      );
      final newPosition = vm.Vector2(3.0, 4.0);
      final newVelocity = vm.Vector2(1.0, 0.0);

      // Act
      final copiedBall = originalBall.copyWith(
        position: newPosition,
        velocity: newVelocity,
      );

      // Assert
      expect(copiedBall.position, equals(newPosition));
      expect(copiedBall.velocity, equals(newVelocity));
      expect(copiedBall.radius, equals(originalBall.radius)); // 変更されていない
    });

    test(
      'should create a copy without changes when no parameters provided',
      () {
        // Arrange
        final originalBall = Ball(
          position: vm.Vector2(1.0, 2.0),
          velocity: vm.Vector2(0.5, -0.3),
          radius: 0.15,
        );

        // Act
        final copiedBall = originalBall.copyWith();

        // Assert
        expect(copiedBall.position, equals(originalBall.position));
        expect(copiedBall.velocity, equals(originalBall.velocity));
        expect(copiedBall.radius, equals(originalBall.radius));
      },
    );

    test('should implement equality correctly', () {
      // Arrange
      final ball1 = Ball(
        position: vm.Vector2(1.0, 2.0),
        velocity: vm.Vector2(0.5, -0.3),
        radius: 0.15,
      );
      final ball2 = Ball(
        position: vm.Vector2(1.0, 2.0),
        velocity: vm.Vector2(0.5, -0.3),
        radius: 0.15,
      );
      final ball3 = Ball(
        position: vm.Vector2(2.0, 2.0), // 異なる位置
        velocity: vm.Vector2(0.5, -0.3),
        radius: 0.15,
      );

      // Assert
      expect(ball1, equals(ball2)); // 同じプロパティ
      expect(ball1, isNot(equals(ball3))); // 異なるプロパティ
    });

    test('should implement hashCode correctly', () {
      // Arrange
      final ball1 = Ball(
        position: vm.Vector2(1.0, 2.0),
        velocity: vm.Vector2(0.5, -0.3),
        radius: 0.15,
      );
      final ball2 = Ball(
        position: vm.Vector2(1.0, 2.0),
        velocity: vm.Vector2(0.5, -0.3),
        radius: 0.15,
      );

      // Assert
      expect(ball1.hashCode, equals(ball2.hashCode)); // 同じプロパティは同じハッシュコード
    });
  });
}
