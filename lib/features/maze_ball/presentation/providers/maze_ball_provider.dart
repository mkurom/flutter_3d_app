import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math.dart' as vm;
import 'package:flutter_3d_app/core/providers/dependency_providers.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/game_state.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/sensor_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/game_usecase.dart';

/// 迷路ボールゲームのグローバル状態管理（Provider）
class MazeBallGameProvider extends AsyncNotifier<GameState> {
 class MazeBallGameProvider extends AsyncNotifier<GameState> {
   late final GameUseCase _gameUseCase;
   late final SensorRepository _sensorRepository;

   StreamSubscription<vm.Vector2>? _sensorSubscription;
   Timer? _gameTimer;

   @override
   Future<GameState> build() async {
     _gameUseCase = ref.read(gameUseCaseProvider);
     _sensorRepository = ref.read(sensorRepositoryProvider);
     
     // プロバイダーが破棄される際にリソースをクリーンアップ
     ref.onDispose(() {
       // cleanup logic...
     });
     // ...
   }
   // ...
 }

  StreamSubscription<vm.Vector2>? _sensorSubscription;
  Timer? _gameTimer;

  @override
  Future<GameState> build() async {
    // プロバイダーが破棄される際にリソースをクリーンアップ
    ref.onDispose(() {
      _sensorSubscription?.cancel();
      _sensorRepository.stopAccelerometerStream();
      _gameTimer?.cancel();
    });

    final gameState = await _gameUseCase.initializeGame();
    _startSensorListening();
    _startGameTimer();
    return gameState;
  }

  /// ゲームを開始
  Future<void> startGame() async {
    state = const AsyncValue.loading();
    try {
      final gameState = await _gameUseCase.initializeGame();
      _startSensorListening();
      _startGameTimer();
      state = AsyncValue.data(gameState);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 次のレベルに進む
  Future<void> nextLevel() async {
    final currentState = state.value;
    if (currentState == null || !currentState.isGameWon) return;

    state = const AsyncValue.loading();
    try {
      final gameState = await _gameUseCase.nextLevel(currentState);
      state = AsyncValue.data(gameState);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// ゲームをリセット
  Future<void> resetGame() async {
    state = const AsyncValue.loading();
    try {
      final gameState = await _gameUseCase.resetGame();
      state = AsyncValue.data(gameState);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// ズームレベルを更新
  void updateZoomLevel(double zoomLevel) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedState = _gameUseCase.updateZoomLevel(currentState, zoomLevel);
    state = AsyncValue.data(updatedState);
  }

  /// ズームをリセット
  void resetZoom() {
    updateZoomLevel(1.0);
  }

  void _startSensorListening() {
    _sensorSubscription?.cancel();
    _sensorSubscription = _sensorRepository.startAccelerometerStream().listen(
      _onTiltForceChanged,
    );
  }

  void _onTiltForceChanged(vm.Vector2 tiltForce) {
    final currentState = state.value;
    if (currentState == null) return;

    final updatedState = _gameUseCase.updateGameState(currentState, tiltForce);
    state = AsyncValue.data(updatedState);
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      // 60 FPS でゲーム状態を更新
      final currentState = state.value;
      if (currentState != null && !currentState.isGameWon) {
        try {
          final updatedState = _gameUseCase.updateGameState(
            currentState,
            currentState.tiltForce,
          );
          if (!ref.exists(mazeBallGameProvider)) return; // プロバイダーが存在しない場合は処理を停止
          state = AsyncValue.data(updatedState);
        } catch (e) {
          // プロバイダーが破棄されている場合は無視
        }
      }
    });
  }
}

/// 迷路ボールゲームの状態プロバイダー
/// グローバルゲーム状態プロバイダー（複数ページで共有可能）
final mazeBallGameProvider =
    AsyncNotifierProvider<MazeBallGameProvider, GameState>(() {
      return MazeBallGameProvider();
    });

/// 最高記録を取得するプロバイダー
final bestTimeProvider = FutureProvider.family<Duration?, int>((
  ref,
  level,
) async {
  final gameUseCase = ref.read(gameUseCaseProvider);
  return gameUseCase.getBestTime(level);
});

/// ゲーム状態の各フィールドへの便利なアクセス
final isGameWonProvider = Provider<bool>((ref) {
  final gameState = ref.watch(mazeBallGameProvider).value;
  return gameState?.isGameWon ?? false;
});

final currentLevelProvider = Provider<int>((ref) {
  final gameState = ref.watch(mazeBallGameProvider).value;
  return gameState?.level ?? 1;
});

final zoomLevelProvider = Provider<double>((ref) {
  final gameState = ref.watch(mazeBallGameProvider).value;
  return gameState?.zoomLevel ?? 1.0;
});

final ballPositionProvider = Provider<vm.Vector2>((ref) {
  final gameState = ref.watch(mazeBallGameProvider).value;
  return gameState?.ball.position ?? vm.Vector2.zero();
});

final tiltForceProvider = Provider<vm.Vector2>((ref) {
  final gameState = ref.watch(mazeBallGameProvider).value;
  return gameState?.tiltForce ?? vm.Vector2.zero();
});

final mazeGridProvider = Provider<List<List<int>>>((ref) {
  final gameState = ref.watch(mazeBallGameProvider).value;
  return gameState?.maze.grid ?? <List<int>>[];
});

final elapsedTimeProvider = Provider<Duration?>((ref) {
  final gameState = ref.watch(mazeBallGameProvider).value;
  return gameState?.elapsedTime;
});
