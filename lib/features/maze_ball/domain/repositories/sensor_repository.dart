import 'package:vector_math/vector_math.dart' as vm;

/// センサーデータの抽象リポジトリ
abstract class SensorRepository {
  /// 加速度センサーのストリームを開始
  Stream<vm.Vector2> startAccelerometerStream();

  /// センサーストリームを停止
  void stopAccelerometerStream();
}
