import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/shared/constants/game_constants.dart';

/// センサーデータソース
class SensorDataSource {
  /// 加速度センサーのストリームを取得
  Stream<vm.Vector2> getAccelerometerStream() {
    return accelerometerEventStream(
      samplingPeriod: GameConstants.sensorSamplingPeriod,
    ).map((AccelerometerEvent event) {
      // 端末の傾きを力に変換
      // Androidでは：
      // event.x = 左右の傾き（画面の左端を下に傾けると正の値）
      // event.y = 前後の傾き（画面の上端を下に傾けると正の値）
      return vm.Vector2(
        -event.x * GameConstants.accelerationScale, // 左右：右に傾けると右に移動（X軸を反転）
        event.y * GameConstants.accelerationScale, // 上下：上端を下に傾けると下に移動
      );
    });
  }
}
