import 'package:flutter/material.dart';
import '../../../../shared/constants/game_constants.dart';

/// ゲーム情報パネルウィジェット
class GameInfoPanel extends StatelessWidget {
  final int level;
  final Duration? elapsedTime;
  final double tiltForceLength;
  final double zoomLevel;

  const GameInfoPanel({
    super.key,
    required this.level,
    this.elapsedTime,
    required this.tiltForceLength,
    required this.zoomLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameConstants.panelBackgroundColor.withValues(
          alpha: GameConstants.panelOpacity,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: GameConstants.panelBorderColor.withValues(
            alpha: GameConstants.panelBorderOpacity,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem('レベル', '$level', Icons.terrain),
          _buildInfoItem(
            'タイム',
            elapsedTime != null ? '${elapsedTime!.inSeconds}s' : '0s',
            Icons.timer,
          ),
          _buildInfoItem(
            '傾き',
            tiltForceLength.toStringAsFixed(1),
            Icons.screen_rotation,
          ),
          _buildInfoItem('ズーム', '${(zoomLevel * 100).round()}%', Icons.zoom_in),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
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
}
