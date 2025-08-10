import 'package:vector_math/vector_math.dart' as vm;

/// センサーデータの抽象リポジトリ
abstract class SensorRepository {
  /// Starts accelerometer stream
  ///
  /// Returns a stream of 2D acceleration vectors where:
  /// - x: acceleration in device's x-axis (positive = right)
  /// - y: acceleration in device's y-axis (positive = up)
  /// - Values typically range from -10 to 10 m/s²
  ///
  /// Throws [PlatformException] if sensor is unavailable
  Stream<vm.Vector2> startAccelerometerStream();

  /// Stops the accelerometer stream
  ///
  /// Safe to call multiple times. No-op if stream is already stopped.
  void stopAccelerometerStream();
}
