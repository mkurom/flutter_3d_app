import 'dart:math' as math;
import 'package:flutter_3d_app/shared/constants/game_constants.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';

/// 迷路生成データソース
class MazeGenerator {
  /// シンプルな迷路を生成
  Maze generateSimpleMaze(int width, int height) {
    // すべて壁で初期化
    final grid = List.generate(height, (y) => List.generate(width, (x) => 1));

    // 通路を作成
    for (int y = 1; y < height - 1; y += 2) {
      for (int x = 1; x < width - 1; x += 2) {
        grid[y][x] = 0; // 通路

        // ランダムに隣接する壁を除去
        if (math.Random().nextBool() && x + 1 < width - 1) {
          grid[y][x + 1] = 0;
        }
        if (math.Random().nextBool() && y + 1 < height - 1) {
          grid[y + 1][x] = 0;
        }
      }
    }

    // スタート地点（左上）
    grid[1][1] = 0;

    // ゴール地点（右下）
    grid[height - 2][width - 2] = 2;

    // ゴール周辺を通路にして確実に到達可能にする
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        final goalX = width - 2 + dx;
        final goalY = height - 2 + dy;
        if (goalX >= 1 &&
            goalX < width - 1 &&
            goalY >= 1 &&
            goalY < height - 1) {
          if (grid[goalY][goalX] == 1) {
            // 壁だった場合のみ
            grid[goalY][goalX] = 0; // 通路に変更
          }
        }
      }
    }

    // ゴール地点を再設定（上記で変更された可能性があるため）
    grid[height - 2][width - 2] = 2;

    return Maze(grid: grid, width: width, height: height);
  }

  /// レベルに応じた迷路を生成
  Maze generateMazeForLevel(int level) {
    // レベルが上がるほど複雑になる（現在はシンプルな実装）
    final baseWidth = GameConstants.mazeWidth;
    final baseHeight = GameConstants.mazeHeight;

    // 将来的にはレベルに応じてサイズや複雑さを変更可能
    return generateSimpleMaze(baseWidth, baseHeight);
  }

  /// 深度優先探索による迷路生成（より複雑なアルゴリズム）
  Maze generateDFSMaze(int width, int height) {
    final grid = List.generate(height, (y) => List.generate(width, (x) => 1));

    final random = math.Random();
    final visited = List.generate(
      height,
      (y) => List.generate(width, (x) => false),
    );

    void dfs(int x, int y) {
      visited[y][x] = true;
      grid[y][x] = 0; // 通路

      final directions = [
        [0, -2], // 上
        [2, 0], // 右
        [0, 2], // 下
        [-2, 0], // 左
      ];
      directions.shuffle(random);

      for (final dir in directions) {
        final nx = x + dir[0];
        final ny = y + dir[1];

        if (nx > 0 &&
            nx < width - 1 &&
            ny > 0 &&
            ny < height - 1 &&
            !visited[ny][nx]) {
          // 壁を除去
          grid[y + dir[1] ~/ 2][x + dir[0] ~/ 2] = 0;
          dfs(nx, ny);
        }
      }
    }

    // 開始点から生成
    dfs(1, 1);

    // ゴール設定
    grid[height - 2][width - 2] = 2;

    return Maze(grid: grid, width: width, height: height);
  }
}
