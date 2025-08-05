part of 'maze_ball_game.dart';

/// 3D迷路を描画するCustomPainter
class Maze3DPainter extends CustomPainter {
  final List<List<int>> maze;
  final vm.Vector2 ballPosition;
  final vm.Vector2 tiltForce;
  final bool gameWon;
  final double zoomLevel;

  Maze3DPainter({
    required this.maze,
    required this.ballPosition,
    required this.tiltForce,
    required this.gameWon,
    this.zoomLevel = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseScale = math.min(size.width, size.height) * 0.025;
    final scale = baseScale * zoomLevel;

    // 3D変換パラメータ
    // 迷路を画面に平行にする基本回転
    final rotationX =
        GameConstants.baseRotationX + tiltForce.y * 0.1; // 端末の傾きで視点も変化
    final rotationY = tiltForce.x * 0.1;

    final rotX = vm.Matrix3.rotationX(rotationX);
    final rotY = vm.Matrix3.rotationY(rotationY);
    final rotation = rotY * rotX;

    // 迷路の壁を描画
    for (int y = 0; y < maze.length; y++) {
      for (int x = 0; x < maze[y].length; x++) {
        if (maze[y][x] == MazeCellType.wall.value) {
          // 壁
          _drawWall(
            canvas,
            center,
            scale,
            rotation,
            x.toDouble(),
            y.toDouble(),
          );
        } else if (maze[y][x] == MazeCellType.goal.value) {
          // ゴール
          _drawGoal(
            canvas,
            center,
            scale,
            rotation,
            x.toDouble(),
            y.toDouble(),
          );
        } else {
          // 床
          _drawFloor(
            canvas,
            center,
            scale,
            rotation,
            x.toDouble(),
            y.toDouble(),
          );
        }
      }
    }

    // ボールを描画
    _drawBall(canvas, center, scale, rotation, ballPosition.x, ballPosition.y);

    // 勝利エフェクト
    if (gameWon) {
      _drawVictoryEffect(canvas, size);
    }
  }

  void _drawWall(
    Canvas canvas,
    Offset center,
    double scale,
    vm.Matrix3 rotation,
    double x,
    double y,
  ) {
    final vertices = [
      vm.Vector3(x, y, 0),
      vm.Vector3(x + 1, y, 0),
      vm.Vector3(x + 1, y + 1, 0),
      vm.Vector3(x, y + 1, 0),
      vm.Vector3(x, y, GameConstants.wallHeight),
      vm.Vector3(x + 1, y, GameConstants.wallHeight),
      vm.Vector3(x + 1, y + 1, GameConstants.wallHeight),
      vm.Vector3(x, y + 1, GameConstants.wallHeight),
    ];

    final projectedVertices =
        vertices.map((vertex) {
          final adjusted =
              vertex - vm.Vector3(maze[0].length / 2, maze.length / 2, 0);
          final rotated = rotation * adjusted;
          return _project3D(rotated, center, scale);
        }).toList();

    // 壁面を描画（上面と可視面のみ）
    final faces = [
      [4, 5, 6, 7], // 上面
      [0, 1, 5, 4], // 前面
      [1, 2, 6, 5], // 右面
    ];

    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      final path = Path();
      path.moveTo(projectedVertices[face[0]].dx, projectedVertices[face[0]].dy);
      for (int j = 1; j < face.length; j++) {
        path.lineTo(
          projectedVertices[face[j]].dx,
          projectedVertices[face[j]].dy,
        );
      }
      path.close();

      // 面の方向によって異なるグラデーションを適用
      Paint paint;
      if (i == 0) {
        // 上面：明るいグラデーション
        paint =
            Paint()
              ..shader = LinearGradient(
                colors: GameConstants.wallGradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(path.getBounds())
              ..style = PaintingStyle.fill;
      } else {
        // 側面：通常の色
        paint =
            Paint()
              ..color = GameConstants.wallFaceColors[i]
              ..style = PaintingStyle.fill;
      }
      canvas.drawPath(path, paint);

      final strokePaint =
          Paint()
            ..color = GameConstants.wallStrokeColor.withOpacity(0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = GameConstants.wallStrokeWidth;
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawFloor(
    Canvas canvas,
    Offset center,
    double scale,
    vm.Matrix3 rotation,
    double x,
    double y,
  ) {
    final vertices = [
      vm.Vector3(x, y, 0),
      vm.Vector3(x + 1, y, 0),
      vm.Vector3(x + 1, y + 1, 0),
      vm.Vector3(x, y + 1, 0),
    ];

    final projectedVertices =
        vertices.map((vertex) {
          final adjusted =
              vertex - vm.Vector3(maze[0].length / 2, maze.length / 2, 0);
          final rotated = rotation * adjusted;
          return _project3D(rotated, center, scale);
        }).toList();

    final path = Path();
    path.moveTo(projectedVertices[0].dx, projectedVertices[0].dy);
    for (int i = 1; i < projectedVertices.length; i++) {
      path.lineTo(projectedVertices[i].dx, projectedVertices[i].dy);
    }
    path.close();

    final paint =
        Paint()
          ..color = GameConstants.floorColor.withOpacity(0.8)
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // 床の輪郭線も追加
    final strokePaint =
        Paint()
          ..color = GameConstants.floorStrokeColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = GameConstants.floorStrokeWidth;
    canvas.drawPath(path, strokePaint);
  }

  void _drawGoal(
    Canvas canvas,
    Offset center,
    double scale,
    vm.Matrix3 rotation,
    double x,
    double y,
  ) {
    final vertices = [
      vm.Vector3(x, y, 0),
      vm.Vector3(x + 1, y, 0),
      vm.Vector3(x + 1, y + 1, 0),
      vm.Vector3(x, y + 1, 0),
    ];

    final projectedVertices =
        vertices.map((vertex) {
          final adjusted =
              vertex - vm.Vector3(maze[0].length / 2, maze.length / 2, 0);
          final rotated = rotation * adjusted;
          return _project3D(rotated, center, scale);
        }).toList();

    final path = Path();
    path.moveTo(projectedVertices[0].dx, projectedVertices[0].dy);
    for (int i = 1; i < projectedVertices.length; i++) {
      path.lineTo(projectedVertices[i].dx, projectedVertices[i].dy);
    }
    path.close();

    final paint =
        Paint()
          ..color = GameConstants.goalColor.withOpacity(0.8)
          ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final strokePaint =
        Paint()
          ..color = GameConstants.goalColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = GameConstants.goalStrokeWidth;
    canvas.drawPath(path, strokePaint);
  }

  void _drawBall(
    Canvas canvas,
    Offset center,
    double scale,
    vm.Matrix3 rotation,
    double x,
    double y,
  ) {
    final ballCenter = vm.Vector3(x + 0.5, y + 0.5, 0.5);
    final adjusted =
        ballCenter - vm.Vector3(maze[0].length / 2, maze.length / 2, 0);
    final rotated = rotation * adjusted;
    final projected = _project3D(rotated, center, scale);

    final ballRadius = scale * GameConstants.ballSize;

    // ボールの影
    final shadowPaint =
        Paint()
          ..color = GameConstants.ballShadowColor.withOpacity(0.3)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(projected.dx + 3, projected.dy + 3),
      ballRadius * 0.8,
      shadowPaint,
    );

    // ボール本体
    final ballPaint =
        Paint()
          ..shader = RadialGradient(
            colors: GameConstants.ballColors,
          ).createShader(
            Rect.fromCircle(center: projected, radius: ballRadius),
          );
    canvas.drawCircle(projected, ballRadius, ballPaint);

    // ボールのハイライト
    final highlightPaint =
        Paint()
          ..color = GameConstants.ballHighlightColor.withOpacity(0.6)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(projected.dx - ballRadius * 0.3, projected.dy - ballRadius * 0.3),
      ballRadius * 0.3,
      highlightPaint,
    );
  }

  void _drawVictoryEffect(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.yellow.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi;
      final radius = 50 + i * 10;
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius;
      canvas.drawCircle(Offset(x, y), 5, paint);
    }
  }

  Offset _project3D(vm.Vector3 point, Offset center, double scale) {
    final z = point.z + GameConstants.projectionDistance;
    final projectionScale = GameConstants.projectionDistance / z;

    return Offset(
      center.dx + point.x * scale * projectionScale,
      center.dy + point.y * scale * projectionScale, // Y軸の反転を削除
    );
  }

  @override
  bool shouldRepaint(Maze3DPainter oldDelegate) {
    return oldDelegate.ballPosition != ballPosition ||
        oldDelegate.tiltForce != tiltForce ||
        oldDelegate.gameWon != gameWon ||
        oldDelegate.zoomLevel != zoomLevel;
  }
}
