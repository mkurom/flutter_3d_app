import 'package:vector_math/vector_math.dart' as vm;

/// ボールエンティティ
class Ball {
  final vm.Vector2 position;
  final vm.Vector2 velocity;
  final double radius;

  const Ball({
    required this.position,
    required this.velocity,
    required this.radius,
  });

  Ball copyWith({vm.Vector2? position, vm.Vector2? velocity, double? radius}) {
    return Ball(
      position: position ?? this.position,
      velocity: velocity ?? this.velocity,
      radius: radius ?? this.radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ball &&
        other.position == position &&
        other.velocity == velocity &&
        other.radius == radius;
  }

  @override
  int get hashCode => position.hashCode ^ velocity.hashCode ^ radius.hashCode;
}
