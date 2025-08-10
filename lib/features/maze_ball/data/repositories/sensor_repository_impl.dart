import 'dart:async';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/sensor_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/sensor_datasource.dart';

/// センサーリポジトリの実装
class SensorRepositoryImpl implements SensorRepository {
  SensorRepositoryImpl({required SensorDataSource sensorDataSource})
    : _sensorDataSource = sensorDataSource;
  final SensorDataSource _sensorDataSource;
  StreamSubscription<vm.Vector2>? _accelerometerSubscription;
  StreamController<vm.Vector2>? _streamController;

  @override
  @override
  Stream<vm.Vector2> startAccelerometerStream() {
    // Stop existing stream if running
    if (_streamController != null) {
      stopAccelerometerStream();
    }

    _streamController = StreamController<vm.Vector2>.broadcast();

    _accelerometerSubscription = _sensorDataSource
        .getAccelerometerStream()
        .listen((tiltForce) {
          _streamController?.add(tiltForce);
        });

    return _streamController!.stream;
  }

  @override
  void stopAccelerometerStream() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _streamController?.close();
    _streamController = null;
  }
}
