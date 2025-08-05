part of 'maze_ball_game.dart';

/// UI関連のヘルパーメソッド
extension MazeBallGameUIHelpers on _MazeBallGameState {
  /// 情報表示アイテムを構築
  Widget buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: GameConstants.infoIconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: GameConstants.infoTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: GameConstants.infoSubTextColor,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// コントロールボタンを構築
  Widget buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                onPressed != null
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  onPressed != null
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: onPressed != null ? Colors.white : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: onPressed != null ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ゲーム情報パネルを構築
  Widget buildGameInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameConstants.panelBackgroundColor.withOpacity(
          GameConstants.panelOpacity,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameConstants.panelBorderColor.withOpacity(
            GameConstants.panelBorderOpacity,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildInfoItem('レベル', '$_level', Icons.terrain),
          buildInfoItem(
            'タイム',
            _startTime != null
                ? '${DateTime.now().difference(_startTime!).inSeconds}s'
                : '0s',
            Icons.timer,
          ),
          buildInfoItem(
            '傾き',
            _tiltForce.length.toStringAsFixed(1),
            Icons.screen_rotation,
          ),
          buildInfoItem('ズーム', '${(_zoomLevel * 100).round()}%', Icons.zoom_in),
        ],
      ),
    );
  }

  /// 3D迷路ビューを構築
  Widget build3DMazeView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: GestureDetector(
            onScaleStart: (details) {
              _baseZoomLevel = _zoomLevel;
            },
            onScaleUpdate: (details) {
              setState(() {
                final newZoom = _baseZoomLevel * details.scale;
                _zoomLevel = newZoom.clamp(
                  GameConstants.minZoom,
                  GameConstants.maxZoom,
                );
              });
            },
            onDoubleTap: () {
              setState(() {
                // ダブルタップでズームレベルを切り替え
                if (_zoomLevel < 2.0) {
                  _zoomLevel = 2.0;
                } else {
                  _zoomLevel = 1.0;
                }
              });
            },
            child: CustomPaint(
              painter: Maze3DPainter(
                maze: _maze,
                ballPosition: _ballPosition,
                tiltForce: _tiltForce,
                gameWon: _gameWon,
                zoomLevel: _zoomLevel,
              ),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }

  /// コントロールパネルを構築
  Widget buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameConstants.panelBackgroundColor.withOpacity(
          GameConstants.panelOpacity,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameConstants.panelBorderColor.withOpacity(
            GameConstants.panelBorderOpacity,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildControlButton(
                icon: Icons.refresh,
                label: 'リセット',
                onPressed: _resetGame,
              ),
              buildControlButton(
                icon: Icons.zoom_out_map,
                label: 'ズーム\nリセット',
                onPressed: () {
                  setState(() {
                    _zoomLevel = 1.0;
                  });
                },
              ),
              buildControlButton(
                icon: Icons.skip_next,
                label: '次レベル',
                onPressed: _gameWon ? _nextLevel : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '📱 端末を傾けてボールを操作\n🎯 赤いゴールを目指そう！\n🔍 ピンチ/ダブルタップでズーム',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GameConstants.infoSubTextColor,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 勝利ダイアログを表示
  void showVictoryDialog() {
    final duration = DateTime.now().difference(_startTime!);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              '🎉 ゴール達成！',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'レベル $_level クリア！',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'タイム: ${duration.inSeconds}.${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}秒',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _nextLevel();
                },
                child: const Text('次のレベル'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetGame();
                },
                child: const Text('リスタート'),
              ),
            ],
          ),
    );
  }
}
