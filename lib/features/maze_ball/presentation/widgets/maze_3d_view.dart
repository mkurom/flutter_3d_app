import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/shared/constants/game_constants.dart';
import 'package:flutter_3d_app/features/maze_ball/presentation/widgets/maze_3d_painter.dart';

/// 3D迷路ビューウィジェット
class Maze3DView extends StatelessWidget {
  const Maze3DView({
    super.key,
    required this.maze,
    required this.ballPosition,
    required this.tiltForce,
    required this.gameWon,
    required this.zoomLevel,
    required this.onZoomChanged,
  });
  final List<List<int>> maze;
  final vm.Vector2 ballPosition;
  final vm.Vector2 tiltForce;
  final bool gameWon;
  final double zoomLevel;
  final Function(double) onZoomChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onScaleStart: (details) {
              // スケール開始時の処理
            },
            onScaleUpdate: (details) {
              final newZoom = zoomLevel * details.scale;
              final clampedZoom = newZoom.clamp(
                GameConstants.minZoom,
                GameConstants.maxZoom,
              );
              onZoomChanged(clampedZoom);
            },
            onDoubleTap: () {
              // ダブルタップでズームレベルを切り替え
              if (zoomLevel < 2.0) {
                onZoomChanged(2.0);
              } else {
                onZoomChanged(1.0);
              }
            },
            child: CustomPaint(
              painter: Maze3DPainter(
                maze: maze,
                ballPosition: ballPosition,
                tiltForce: tiltForce,
                gameWon: gameWon,
                zoomLevel: zoomLevel,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
