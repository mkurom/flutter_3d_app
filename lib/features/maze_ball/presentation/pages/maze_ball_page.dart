import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_3d_app/shared/constants/game_constants.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/game_state.dart';
import 'package:flutter_3d_app/features/maze_ball/presentation/providers/maze_ball_provider.dart';
import 'package:flutter_3d_app/features/maze_ball/presentation/widgets/control_panel.dart';
import 'package:flutter_3d_app/features/maze_ball/presentation/widgets/game_info_panel.dart';
import 'package:flutter_3d_app/features/maze_ball/presentation/widgets/maze_3d_view.dart';

/// 迷路ボールゲームページ
class MazeBallPage extends HookConsumerWidget {
  const MazeBallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // hooksを使用してローカル状態を管理
    final showZoomFeedback = useState(false);
    final isVictoryDialogVisible = useState(false);
    final isTutorialVisible = useState(false);
    final isInitialized = useState(false);

    // 画面の向き制御とページ初期化
    useEffect(() {
      // 画面の向きを縦に固定
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // ページの初期化完了
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isInitialized.value = true;
      });

      // クリーンアップ: 画面の向き制限を解除
      return () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      };
    }, []);

    // ズームフィードバック自動非表示
    useEffect(() {
      if (showZoomFeedback.value) {
        final timer = Timer(const Duration(seconds: 2), () {
          showZoomFeedback.value = false;
        });
        return timer.cancel;
      }
      return null;
    }, [showZoomFeedback.value]);

    // グローバル状態（Provider）
    final gameStateAsync = ref.watch(mazeBallGameProvider);

    return _buildGamePage(
      context,
      ref,
      gameStateAsync,
      showZoomFeedback: showZoomFeedback,
      isVictoryDialogVisible: isVictoryDialogVisible,
      isTutorialVisible: isTutorialVisible,
      isInitialized: isInitialized,
    );
  }

  Widget _buildGamePage(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<GameState> gameStateAsync, {
    required ValueNotifier<bool> showZoomFeedback,
    required ValueNotifier<bool> isVictoryDialogVisible,
    required ValueNotifier<bool> isTutorialVisible,
    required ValueNotifier<bool> isInitialized,
  }) {
    return Scaffold(
      body: gameStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('エラーが発生しました: $error'),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(mazeBallGameProvider),
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
        data: (gameState) {
          // 勝利時のダイアログ表示は別途実装予定
          // TODO: 勝利時の適切なダイアログ表示タイミングを実装

          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: GameConstants.backgroundGradientColors,
              ),
            ),
            child: Column(
              children: [
                GameInfoPanel(
                  level: gameState.level,
                  elapsedTime: gameState.elapsedTime,
                  tiltForceLength: gameState.tiltForce.length,
                  zoomLevel: gameState.zoomLevel,
                ),
                Maze3DView(
                  maze: gameState.maze.grid,
                  ballPosition: gameState.ball.position,
                  tiltForce: gameState.tiltForce,
                  gameWon: gameState.isGameWon,
                  zoomLevel: gameState.zoomLevel,
                  onZoomChanged: (zoom) {
                    ref
                        .read(mazeBallGameProvider.notifier)
                        .updateZoomLevel(zoom);
                    showZoomFeedback.value = true;
                  },
                ),
                ControlPanel(
                  isGameWon: gameState.isGameWon,
                  onReset:
                      () => ref.read(mazeBallGameProvider.notifier).resetGame(),
                  onZoomReset:
                      () => ref.read(mazeBallGameProvider.notifier).resetZoom(),
                  onNextLevel:
                      gameState.isGameWon
                          ? () =>
                              ref
                                  .read(mazeBallGameProvider.notifier)
                                  .nextLevel()
                          : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
