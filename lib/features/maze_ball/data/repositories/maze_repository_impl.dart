import '../../domain/entities/maze.dart';
import '../../domain/repositories/maze_repository.dart';
import '../datasources/maze_generator.dart';

/// 迷路リポジトリの実装
class MazeRepositoryImpl implements MazeRepository {
  final MazeGenerator _mazeGenerator;

  MazeRepositoryImpl({required MazeGenerator mazeGenerator})
    : _mazeGenerator = mazeGenerator;

  @override
  Future<Maze> generateMaze(int width, int height) async {
    return _mazeGenerator.generateSimpleMaze(width, height);
  }

  @override
  Future<Maze> getMazeForLevel(int level) async {
    return _mazeGenerator.generateMazeForLevel(level);
  }
}
