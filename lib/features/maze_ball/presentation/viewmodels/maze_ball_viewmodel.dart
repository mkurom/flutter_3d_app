import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math.dart' as vm;
import '../../domain/entities/game_state.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../../domain/usecases/game_usecase.dart';

/// 迷路ボールゲームのViewModel
class MazeBallViewModel extends ChangeNotifier {
  final GameUseCase _gameUseCase;
  final SensorRepository _sensorRepository;

  late GameState _gameState;
  StreamSubscription<vm.Vector2>? _sensorSubscription;
  Timer? _gameTimer;

  MazeBallViewModel({
    required GameUseCase gameUseCase,
    required SensorRepository sensorRepository,
  }) : _gameUseCase = gameUseCase,
       _sensorRepository = sensorRepository;

  // Getters
  GameState get gameState => _gameState;
  bool get isGameWon => _gameState.isGameWon;
  int get level => _gameState.level;
  double get zoomLevel => _gameState.zoomLevel;
  vm.Vector2 get ballPosition => _gameState.ball.position;
  vm.Vector2 get tiltForce => _gameState.tiltForce;
  List<List<int>> get maze => _gameState.maze.grid;

  Duration? get elapsedTime => _gameState.elapsedTime;

  /// ViewModelを初期化
  Future<void> initialize() async {
    _gameState = await _gameUseCase.initializeGame();
    _startSensorListening();
    _startGameTimer();
    notifyListeners();
  }

  /// ゲームを開始
  Future<void> startGame() async {
    _gameState = await _gameUseCase.initializeGame();
    _startSensorListening();
    _startGameTimer();
    notifyListeners();
  }

  /// 次のレベルに進む
  Future<void> nextLevel() async {
    if (!_gameState.isGameWon) return;

    _gameState = await _gameUseCase.nextLevel(_gameState);
    notifyListeners();
  }

  /// ゲームをリセット
  Future<void> resetGame() async {
    _gameState = await _gameUseCase.resetGame();
    notifyListeners();
  }

  /// ズームレベルを更新
  void updateZoomLevel(double zoomLevel) {
    _gameState = _gameUseCase.updateZoomLevel(_gameState, zoomLevel);
    notifyListeners();
  }

  /// ズームをリセット
  void resetZoom() {
    updateZoomLevel(1.0);
  }

  /// 最高記録を取得
  Future<Duration?> getBestTime(int level) async {
    return await _gameUseCase.getBestTime(level);
  }

  void _startSensorListening() {
    _sensorSubscription?.cancel();
    _sensorSubscription = _sensorRepository.startAccelerometerStream().listen(
      _onTiltForceChanged,
    );
  }

  void _onTiltForceChanged(vm.Vector2 tiltForce) {
    _gameState = _gameUseCase.updateGameState(_gameState, tiltForce);
    notifyListeners();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      // 60 FPS でゲーム状態を更新
      if (!_gameState.isGameWon) {
        _gameState = _gameUseCase.updateGameState(
          _gameState,
          _gameState.tiltForce,
        );
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    _sensorRepository.stopAccelerometerStream();
    _gameTimer?.cancel();
    super.dispose();
  }
}
