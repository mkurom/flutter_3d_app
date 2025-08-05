part of 'maze_ball_game.dart';

/// ゲームの設定とコンスタント
class GameConstants {
  // 物理演算の設定
  static const double friction = 0.95;
  static const double accelerationScale = 0.3;
  static const double maxSpeed = 0.15;
  static const double ballRadius = 0.15;

  // 迷路設定
  static const int mazeWidth = 15;
  static const int mazeHeight = 15;

  // ズーム機能
  static const double minZoom = 0.5;
  static const double maxZoom = 3.0;

  // 3D描画設定
  static const double wallHeight = 1.0;
  static const double ballSize = 0.4;
  static const double projectionDistance = 10.0;
  static const double baseRotationX = -math.pi / 6; // 30度傾ける（見やすさのため）

  // 色設定
  static const List<Color> wallFaceColors = [
    Color(0xFFF5E6D3), // 上面：明るいベージュ
    Color(0xFFD4A574), // 前面：中間の茶色
    Color(0xFF8B6914), // 右面：濃い茶色
  ];

  static const List<Color> wallGradientColors = [
    Color(0xFFFFF8F0), // グラデーション開始色
    Color(0xFFF5E6D3), // グラデーション終了色
  ];

  static const Color wallStrokeColor = Color(0xFF4A4A4A);
  static const double wallStrokeWidth = 2.5;

  static const Color floorColor = Color(0xFF2C3E50);
  static const Color floorStrokeColor = Color(0xFF34495E);
  static const double floorStrokeWidth = 1.0;

  static const Color goalColor = Colors.red;
  static const double goalStrokeWidth = 2.0;

  // ボールの色設定
  static const List<Color> ballColors = [
    Color(0xFFFFB74D), // オレンジ系グラデーション開始
    Color(0xFFFF9800), // オレンジ系グラデーション中間
    Color(0xFFE65100), // オレンジ系グラデーション終了
  ];

  static const Color ballHighlightColor = Colors.white;
  static const Color ballShadowColor = Colors.black;

  // 背景色設定
  static const List<Color> backgroundGradientColors = [
    Color(0xFF1C2833),
    Color(0xFF17202A),
    Color(0xFF0B0E0F),
  ];

  // UI色設定
  static const Color panelBackgroundColor = Colors.black;
  static const double panelOpacity = 0.4;
  static const Color panelBorderColor = Colors.white;
  static const double panelBorderOpacity = 0.1;

  static const Color infoIconColor = Colors.blue;
  static const Color infoTextColor = Colors.white;
  static const Color infoSubTextColor = Colors.white70;

  // アニメーション設定
  static const Duration animationDuration = Duration(
    milliseconds: 16,
  ); // 60 FPS
  static const Duration sensorSamplingPeriod = Duration(milliseconds: 16);
}

/// 迷路のセル種類
enum MazeCellType {
  wall(1),
  passage(0),
  goal(2);

  const MazeCellType(this.value);
  final int value;
}
