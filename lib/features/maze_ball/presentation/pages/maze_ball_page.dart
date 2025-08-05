import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../shared/constants/game_constants.dart';
import '../viewmodels/maze_ball_viewmodel.dart';
import '../widgets/control_panel.dart';
import '../widgets/game_info_panel.dart';
import '../widgets/maze_3d_view.dart';

/// 迷路ボールゲームページ
class MazeBallPage extends StatefulWidget {
  const MazeBallPage({super.key});

  @override
  State<MazeBallPage> createState() => _MazeBallPageState();
}

class _MazeBallPageState extends State<MazeBallPage> {
  @override
  void initState() {
    super.initState();

    // 画面の向きを縦に固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ViewModelを初期化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MazeBallViewModel>().initialize();
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MazeBallViewModel>(
        builder: (context, viewModel, child) {
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
                  level: viewModel.level,
                  elapsedTime: viewModel.elapsedTime,
                  tiltForceLength: viewModel.tiltForce.length,
                  zoomLevel: viewModel.zoomLevel,
                ),
                Maze3DView(
                  maze: viewModel.maze,
                  ballPosition: viewModel.ballPosition,
                  tiltForce: viewModel.tiltForce,
                  gameWon: viewModel.isGameWon,
                  zoomLevel: viewModel.zoomLevel,
                  onZoomChanged: viewModel.updateZoomLevel,
                ),
                ControlPanel(
                  isGameWon: viewModel.isGameWon,
                  onReset: viewModel.resetGame,
                  onZoomReset: viewModel.resetZoom,
                  onNextLevel: viewModel.isGameWon ? viewModel.nextLevel : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
