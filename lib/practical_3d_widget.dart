import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;

class Practical3DWidget extends StatefulWidget {
  const Practical3DWidget({super.key});

  @override
  State<Practical3DWidget> createState() => _Practical3DWidgetState();
}

class _Practical3DWidgetState extends State<Practical3DWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _lastPanX = 0.0;
  double _lastPanY = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _rotationY += (details.globalPosition.dx - _lastPanX) * 0.01;
      _rotationX += (details.globalPosition.dy - _lastPanY) * 0.01;
      _lastPanX = details.globalPosition.dx;
      _lastPanY = details.globalPosition.dy;
    });
  }

  void _onPanStart(DragStartDetails details) {
    _lastPanX = details.globalPosition.dx;
    _lastPanY = details.globalPosition.dy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          colors: [Color(0xFF2E3440), Color(0xFF3B4252), Color(0xFF434C5E)],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _rotationController,
                  _scaleController,
                ]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: Cube3DPainter(
                      rotationX:
                          _rotationX +
                          _rotationController.value * 2 * math.pi * 0.3,
                      rotationY:
                          _rotationY +
                          _rotationController.value * 2 * math.pi * 0.5,
                      scale: 0.8 + _scaleController.value * 0.4,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.refresh,
                      label: 'リセット',
                      onPressed: () {
                        setState(() {
                          _rotationX = 0.0;
                          _rotationY = 0.0;
                        });
                      },
                    ),
                    _buildControlButton(
                      icon:
                          _rotationController.isAnimating
                              ? Icons.pause
                              : Icons.play_arrow,
                      label: _rotationController.isAnimating ? '一時停止' : '再生',
                      onPressed: () {
                        if (_rotationController.isAnimating) {
                          _rotationController.stop();
                        } else {
                          _rotationController.repeat();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '🎮 タッチ＆ドラッグで立方体を回転\n'
                  '✨ 自動アニメーション + インタラクティブ操作',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Cube3DPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final double scale;

  Cube3DPainter({
    required this.rotationX,
    required this.rotationY,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cubeSize = math.min(size.width, size.height) * 0.3 * scale;

    // 立方体の頂点を定義（ローカル座標）
    final vertices = [
      vm.Vector3(-1, -1, -1), // 0: 左下奥
      vm.Vector3(1, -1, -1), // 1: 右下奥
      vm.Vector3(1, 1, -1), // 2: 右上奥
      vm.Vector3(-1, 1, -1), // 3: 左上奥
      vm.Vector3(-1, -1, 1), // 4: 左下手前
      vm.Vector3(1, -1, 1), // 5: 右下手前
      vm.Vector3(1, 1, 1), // 6: 右上手前
      vm.Vector3(-1, 1, 1), // 7: 左上手前
    ];

    // 回転行列を作成
    final rotX = vm.Matrix3.rotationX(rotationX);
    final rotY = vm.Matrix3.rotationY(rotationY);
    final rotation = rotY * rotX;

    // 頂点を変換（回転 + スケール + 投影）
    final projectedVertices =
        vertices.map((vertex) {
          final rotated = rotation * vertex;
          final scaled = rotated * cubeSize;

          // 簡易的な透視投影
          final distance = 400.0;
          final z = scaled.z + distance;
          final projectionScale = distance / z;

          return Offset(
            center.dx + scaled.x * projectionScale,
            center.dy - scaled.y * projectionScale,
          );
        }).toList();

    // 面を定義（頂点のインデックス）
    final faces = [
      [0, 1, 2, 3], // 奥面
      [4, 7, 6, 5], // 手前面
      [0, 4, 5, 1], // 下面
      [2, 6, 7, 3], // 上面
      [0, 3, 7, 4], // 左面
      [1, 5, 6, 2], // 右面
    ];

    final faceColors = [
      Colors.red.withValues(alpha: 0.7),
      Colors.green.withValues(alpha: 0.7),
      Colors.blue.withValues(alpha: 0.7),
      Colors.yellow.withValues(alpha: 0.7),
      Colors.purple.withValues(alpha: 0.7),
      Colors.cyan.withValues(alpha: 0.7),
    ];

    // Z-sortingのために面の中心のZ座標を計算
    final faceCenters =
        faces.map((face) {
          double avgZ = 0;
          for (int i in face) {
            final rotated = rotation * vertices[i];
            avgZ += rotated.z;
          }
          return avgZ / face.length;
        }).toList();

    // Z座標でソート（奥から手前へ）
    final faceIndices = List.generate(faces.length, (i) => i);
    faceIndices.sort((a, b) => faceCenters[a].compareTo(faceCenters[b]));

    // 面を描画
    for (int faceIndex in faceIndices) {
      final face = faces[faceIndex];
      final color = faceColors[faceIndex];

      final path = Path();
      path.moveTo(projectedVertices[face[0]].dx, projectedVertices[face[0]].dy);

      for (int i = 1; i < face.length; i++) {
        path.lineTo(
          projectedVertices[face[i]].dx,
          projectedVertices[face[i]].dy,
        );
      }
      path.close();

      // 面を塗りつぶし
      final fillPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // 面の境界線を描画
      final strokePaint =
          Paint()
            ..color = Colors.white.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
      canvas.drawPath(path, strokePaint);
    }

    // 頂点を描画（デバッグ用）
    for (final vertex in projectedVertices) {
      final pointPaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
      canvas.drawCircle(vertex, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(Cube3DPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX ||
        oldDelegate.rotationY != rotationY ||
        oldDelegate.scale != scale;
  }
}
