import '../../../../shared/constants/game_constants.dart';

/// 迷路エンティティ
class Maze {
  final List<List<int>> grid;
  final int width;
  final int height;

  const Maze({required this.grid, required this.width, required this.height});

  /// 指定位置のセルタイプを取得
  MazeCellType getCellType(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return MazeCellType.wall;
    }
    return MazeCellType.values.firstWhere(
      (type) => type.value == grid[y][x],
      orElse: () => MazeCellType.wall,
    );
  }

  /// 壁かどうかを判定
  bool isWall(int x, int y) {
    return getCellType(x, y) == MazeCellType.wall;
  }

  /// ゴールかどうかを判定
  bool isGoal(int x, int y) {
    return getCellType(x, y) == MazeCellType.goal;
  }

  /// 通路かどうかを判定
  bool isPassage(int x, int y) {
    return getCellType(x, y) == MazeCellType.passage;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Maze &&
        other.width == width &&
        other.height == height &&
        _listEquals(other.grid, grid);
  }

  @override
  int get hashCode => width.hashCode ^ height.hashCode ^ grid.hashCode;

  bool _listEquals<T>(List<List<T>> a, List<List<T>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].length != b[i].length) return false;
      for (int j = 0; j < a[i].length; j++) {
        if (a[i][j] != b[i][j]) return false;
      }
    }
    return true;
  }
}
