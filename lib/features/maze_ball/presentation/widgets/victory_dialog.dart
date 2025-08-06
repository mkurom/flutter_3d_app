import 'package:flutter/material.dart';

/// 勝利ダイアログウィジェット
class VictoryDialog extends StatelessWidget {
  final int level;
  final Duration elapsedTime;
  final VoidCallback onNextLevel;
  final VoidCallback onRestart;

  const VictoryDialog({
    super.key,
    required this.level,
    required this.elapsedTime,
    required this.onNextLevel,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      title: const Text('🎉 ゴール達成！', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'レベル $level クリア！',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'タイム: ${elapsedTime.inSeconds}.${(elapsedTime.inMilliseconds % 1000).toString().padLeft(3, '0')}秒',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onNextLevel();
          },
          child: const Text('次のレベル'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRestart();
          },
          child: const Text('リスタート'),
        ),
      ],
    );
  }

  /// ダイアログを表示するstaticメソッド
  static void show(
    BuildContext context, {
    required int level,
    required Duration elapsedTime,
    required VoidCallback onNextLevel,
    required VoidCallback onRestart,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => VictoryDialog(
            level: level,
            elapsedTime: elapsedTime,
            onNextLevel: onNextLevel,
            onRestart: onRestart,
          ),
    );
  }
}
