import '../entities/maze.dart';

/// 迷路データの抽象リポジトリ
abstract class MazeRepository {
  /// 迷路を生成
  Future<Maze> generateMaze(int width, int height);

  /// レベルに応じた迷路を取得
  Future<Maze> getMazeForLevel(int level);
}
