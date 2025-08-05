import 'package:flutter/material.dart';
import '../../../../shared/constants/game_constants.dart';

/// コントロールパネルウィジェット
class ControlPanel extends StatelessWidget {
  final bool isGameWon;
  final VoidCallback onReset;
  final VoidCallback onZoomReset;
  final VoidCallback? onNextLevel;

  const ControlPanel({
    super.key,
    required this.isGameWon,
    required this.onReset,
    required this.onZoomReset,
    this.onNextLevel,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.refresh,
                label: 'リセット',
                onPressed: onReset,
              ),
              _buildControlButton(
                icon: Icons.zoom_out_map,
                label: 'ズーム\nリセット',
                onPressed: onZoomReset,
              ),
              _buildControlButton(
                icon: Icons.skip_next,
                label: '次レベル',
                onPressed: isGameWon ? onNextLevel : null,
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

  Widget _buildControlButton({
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
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  onPressed != null
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.2),
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
}
