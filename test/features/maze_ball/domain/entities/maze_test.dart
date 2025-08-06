import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';
import 'package:flutter_3d_app/shared/constants/game_constants.dart';

void main() {
  group('Maze Entity', () {
    late Maze testMaze;

    setUp(() {
      // テスト用の3x3迷路を作成
      final grid = [
        [1, 1, 1], // 壁, 壁, 壁
        [1, 0, 1], // 壁, 通路, 壁
        [1, 2, 1], // 壁, ゴール, 壁
      ];
      testMaze = Maze(grid: grid, width: 3, height: 3);
    });

    test('should create a maze with correct properties', () {
      // Assert
      expect(testMaze.width, equals(3));
      expect(testMaze.height, equals(3));
      expect(testMaze.grid.length, equals(3));
      expect(testMaze.grid[0].length, equals(3));
    });

    test('should return correct cell type for valid coordinates', () {
      // Assert
      expect(testMaze.getCellType(0, 0), equals(MazeCellType.wall));
      expect(testMaze.getCellType(1, 1), equals(MazeCellType.passage));
      expect(testMaze.getCellType(1, 2), equals(MazeCellType.goal));
    });

    test('should return wall for out of bounds coordinates', () {
      // Assert
      expect(testMaze.getCellType(-1, 0), equals(MazeCellType.wall));
      expect(testMaze.getCellType(0, -1), equals(MazeCellType.wall));
      expect(testMaze.getCellType(3, 1), equals(MazeCellType.wall));
      expect(testMaze.getCellType(1, 3), equals(MazeCellType.wall));
    });

    test('should correctly identify walls', () {
      // Assert
      expect(testMaze.isWall(0, 0), isTrue);
      expect(testMaze.isWall(1, 1), isFalse);
      expect(testMaze.isWall(1, 2), isFalse);
      expect(testMaze.isWall(-1, 0), isTrue); // 範囲外は壁
    });

    test('should correctly identify goals', () {
      // Assert
      expect(testMaze.isGoal(1, 2), isTrue);
      expect(testMaze.isGoal(0, 0), isFalse);
      expect(testMaze.isGoal(1, 1), isFalse);
    });

    test('should correctly identify passages', () {
      // Assert
      expect(testMaze.isPassage(1, 1), isTrue);
      expect(testMaze.isPassage(0, 0), isFalse);
      expect(testMaze.isPassage(1, 2), isFalse);
    });

    test('should implement equality correctly', () {
      // Arrange
      final grid1 = [
        [1, 0],
        [0, 2],
      ];
      final grid2 = [
        [1, 0],
        [0, 2],
      ];
      final grid3 = [
        [1, 1],
        [0, 2],
      ];

      final maze1 = Maze(grid: grid1, width: 2, height: 2);
      final maze2 = Maze(grid: grid2, width: 2, height: 2);
      final maze3 = Maze(grid: grid3, width: 2, height: 2);

      // Assert
      expect(maze1, equals(maze2)); // 同じグリッド
      expect(maze1, isNot(equals(maze3))); // 異なるグリッド
    });

    test('should handle unknown cell types gracefully', () {
      // Arrange
      final gridWithUnknownType = [
        [1, 0],
        [0, 99], // 未知のタイプ
      ];
      final maze = Maze(grid: gridWithUnknownType, width: 2, height: 2);

      // Act & Assert
      expect(maze.getCellType(1, 1), equals(MazeCellType.wall)); // デフォルトで壁になる
    });
  });
}
