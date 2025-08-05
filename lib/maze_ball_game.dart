import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' as vm;

// Part files
part 'maze_ball_game_constants.dart';
part 'maze_ball_game_painter.dart';
part 'maze_ball_game_ui_helpers.dart';

class MazeBallGame extends StatefulWidget {
  const MazeBallGame({super.key});

  @override
  State<MazeBallGame> createState() => _MazeBallGameState();
}

class _MazeBallGameState extends State<MazeBallGame>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  // ボールの物理状態
  vm.Vector2 _ballPosition = vm.Vector2(1.0, 1.0); // 迷路内の位置
  vm.Vector2 _ballVelocity = vm.Vector2.zero();

  // 加速度センサーの値
  vm.Vector2 _tiltForce = vm.Vector2.zero();

  // ゲーム状態
  bool _gameWon = false;
  int _level = 1;
  DateTime? _startTime;

  // ズーム機能
  double _zoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  // 迷路データ (1=壁, 0=通路, 2=ゴール)
  late List<List<int>> _maze;

  @override
  void initState() {
    super.initState();

    // 画面の向きを縦に固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _generateMaze();
    _startTime = DateTime.now();

    _animationController = AnimationController(
      duration: GameConstants.animationDuration,
      vsync: this,
    );
    _animationController.repeat();
    _animationController.addListener(_updatePhysics);

    _initializeSensors();
  }

  @override
  void dispose() {
    // 画面の向き制限を解除（他の画面で自由に回転できるように）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _animationController.dispose();
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  void _initializeSensors() {
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: GameConstants.sensorSamplingPeriod,
    ).listen((AccelerometerEvent event) {
      setState(() {
        // 端末の傾きを力に変換
        // Androidでは：
        // event.x = 左右の傾き（画面の左端を下に傾けると正の値）
        // event.y = 前後の傾き（画面の上端を下に傾けると正の値）

        _tiltForce = vm.Vector2(
          -event.x * GameConstants.accelerationScale, // 左右：右に傾けると右に移動（X軸を反転）
          event.y * GameConstants.accelerationScale, // 上下：上端を下に傾けると下に移動
        );
      });
    });
  }

  void _generateMaze() {
    // シンプルな迷路生成（実際にはより複雑なアルゴリズムを使用可能）
    _maze = List.generate(
      GameConstants.mazeHeight,
      (y) => List.generate(GameConstants.mazeWidth, (x) => 1),
    ); // すべて壁で初期化

    // 通路を作成
    for (int y = 1; y < GameConstants.mazeHeight - 1; y += 2) {
      for (int x = 1; x < GameConstants.mazeWidth - 1; x += 2) {
        _maze[y][x] = 0; // 通路

        // ランダムに隣接する壁を除去
        if (math.Random().nextBool() && x + 1 < GameConstants.mazeWidth - 1) {
          _maze[y][x + 1] = 0;
        }
        if (math.Random().nextBool() && y + 1 < GameConstants.mazeHeight - 1) {
          _maze[y + 1][x] = 0;
        }
      }
    }

    // スタート地点（左上）
    _maze[1][1] = 0;

    // ゴール地点（右下）
    _maze[GameConstants.mazeHeight - 2][GameConstants.mazeWidth - 2] = 2;

    // ゴール周辺を通路にして確実に到達可能にする
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        final goalX = GameConstants.mazeWidth - 2 + dx;
        final goalY = GameConstants.mazeHeight - 2 + dy;
        if (goalX >= 1 &&
            goalX < GameConstants.mazeWidth - 1 &&
            goalY >= 1 &&
            goalY < GameConstants.mazeHeight - 1) {
          if (_maze[goalY][goalX] == 1) {
            // 壁だった場合のみ
            _maze[goalY][goalX] = 0; // 通路に変更
          }
        }
      }
    }

    // ゴール地点を再設定（上記で変更された可能性があるため）
    _maze[GameConstants.mazeHeight - 2][GameConstants.mazeWidth - 2] = 2;

    // デバッグ用：ゴールの位置を出力
    print(
      'ゴール位置: X=${GameConstants.mazeWidth - 2}, Y=${GameConstants.mazeHeight - 2}',
    );

    // ボールの初期位置
    _ballPosition = vm.Vector2(1.0, 1.0);
    _ballVelocity = vm.Vector2.zero();
    _gameWon = false;
  }

  void _updatePhysics() {
    if (_gameWon) return;

    // 重力（傾き）による加速
    // ボールの動きが自然になるように、重力方向を調整
    final gravity = vm.Vector2(_tiltForce.x, _tiltForce.y);
    _ballVelocity += gravity;

    // 速度制限
    if (_ballVelocity.length > GameConstants.maxSpeed) {
      _ballVelocity = _ballVelocity.normalized() * GameConstants.maxSpeed;
    }

    // 新しい位置を計算
    final newPosition = _ballPosition + _ballVelocity;

    // 壁との衝突判定
    final resolvedPosition = _resolveCollisions(newPosition);
    _ballPosition = resolvedPosition;

    // 摩擦力を適用
    _ballVelocity *= GameConstants.friction;

    // ゴール判定（より寛容に）
    final mazeX = _ballPosition.x.floor();
    final mazeY = _ballPosition.y.floor();

    // ボールがゴールエリアに重なっているかチェック
    for (int checkY = mazeY; checkY <= mazeY + 1; checkY++) {
      for (int checkX = mazeX; checkX <= mazeX + 1; checkX++) {
        if (checkX >= 0 &&
            checkX < GameConstants.mazeWidth &&
            checkY >= 0 &&
            checkY < GameConstants.mazeHeight &&
            _maze[checkY][checkX] == 2) {
          // ボールの中心とゴールの距離をチェック
          final goalCenterX = checkX + 0.5;
          final goalCenterY = checkY + 0.5;
          final distance = math.sqrt(
            math.pow(_ballPosition.x - goalCenterX, 2) +
                math.pow(_ballPosition.y - goalCenterY, 2),
          );

          // ボールがゴールに十分近い場合
          if (distance < 0.7) {
            // ボールの半径 + マージン
            _onGoalReached();
            return;
          }
        }
      }
    }
  }

  vm.Vector2 _resolveCollisions(vm.Vector2 newPosition) {
    final result = vm.Vector2.copy(newPosition);

    // X方向の衝突判定
    final leftEdge = (result.x - GameConstants.ballRadius).floor();
    final rightEdge = (result.x + GameConstants.ballRadius).ceil();
    final topEdge = (result.y - GameConstants.ballRadius).floor();
    final bottomEdge = (result.y + GameConstants.ballRadius).ceil();

    // 壁との衝突をチェック
    for (
      int checkY = math.max(0, topEdge);
      checkY <= math.min(GameConstants.mazeHeight - 1, bottomEdge);
      checkY++
    ) {
      for (
        int checkX = math.max(0, leftEdge);
        checkX <= math.min(GameConstants.mazeWidth - 1, rightEdge);
        checkX++
      ) {
        if (_maze[checkY][checkX] == 1) {
          // 壁
          // 壁との距離を計算
          final wallCenterX = checkX + 0.5;
          final wallCenterY = checkY + 0.5;

          final dx = result.x - wallCenterX;
          final dy = result.y - wallCenterY;

          final distance = math.sqrt(dx * dx + dy * dy);
          final minDistance = GameConstants.ballRadius + 0.5; // 壁の半径 + ボールの半径

          if (distance < minDistance) {
            // 衝突を解決
            final pushDirection = vm.Vector2(dx, dy).normalized();
            final pushAmount = minDistance - distance;
            result.add(pushDirection * pushAmount);

            // 速度の反射（簡略化）
            final normal = pushDirection;
            final dot = _ballVelocity.dot(normal);
            _ballVelocity -= normal * (dot * 1.5);
          }
        }
      }
    }

    return result;
  }

  void _onGoalReached() {
    setState(() {
      _gameWon = true;
    });

    showVictoryDialog();
  }

  void _nextLevel() {
    setState(() {
      _level++;
      _generateMaze();
      _startTime = DateTime.now();
    });
  }

  void _resetGame() {
    setState(() {
      _level = 1;
      _generateMaze();
      _startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          colors: GameConstants.backgroundGradientColors,
        ),
      ),
      child: Column(
        children: [
          buildGameInfoPanel(),
          build3DMazeView(),
          buildControlPanel(),
        ],
      ),
    );
  }
}
