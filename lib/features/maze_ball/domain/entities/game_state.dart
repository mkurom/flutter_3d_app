import 'package:vector_math/vector_math.dart' as vm;
import 'ball.dart';
import 'maze.dart';

/// ゲーム状態エンティティ
class GameState {
  final Ball ball;
  final Maze maze;
  final vm.Vector2 tiltForce;
  final bool isGameWon;
  final int level;
  final DateTime? startTime;
  final double zoomLevel;

  const GameState({
    required this.ball,
    required this.maze,
    required this.tiltForce,
    required this.isGameWon,
    required this.level,
    this.startTime,
    required this.zoomLevel,
  });

  GameState copyWith({
    Ball? ball,
    Maze? maze,
    vm.Vector2? tiltForce,
    bool? isGameWon,
    int? level,
    DateTime? startTime,
    double? zoomLevel,
  }) {
    return GameState(
      ball: ball ?? this.ball,
      maze: maze ?? this.maze,
      tiltForce: tiltForce ?? this.tiltForce,
      isGameWon: isGameWon ?? this.isGameWon,
      level: level ?? this.level,
      startTime: startTime ?? this.startTime,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }

  /// ゲームの経過時間を取得
  Duration? get elapsedTime {
    if (startTime == null) return null;
    return DateTime.now().difference(startTime!);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        other.ball == ball &&
        other.maze == maze &&
        other.tiltForce == tiltForce &&
        other.isGameWon == isGameWon &&
        other.level == level &&
        other.startTime == startTime &&
        other.zoomLevel == zoomLevel;
  }

  @override
  int get hashCode =>
      ball.hashCode ^
      maze.hashCode ^
      tiltForce.hashCode ^
      isGameWon.hashCode ^
      level.hashCode ^
      startTime.hashCode ^
      zoomLevel.hashCode;
}
