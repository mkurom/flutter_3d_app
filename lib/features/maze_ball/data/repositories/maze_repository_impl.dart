import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/maze_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/maze_generator.dart';

/// 迷路リポジトリの実装
class MazeRepositoryImpl implements MazeRepository {
  MazeRepositoryImpl({required MazeGenerator mazeGenerator})
    : _mazeGenerator = mazeGenerator;
  final MazeGenerator _mazeGenerator;

  @override
  Future<Maze> generateMaze(int width, int height) async {
    return _mazeGenerator.generateSimpleMaze(width, height);
  }

  @override
  Future<Maze> getMazeForLevel(int level) async {
    return _mazeGenerator.generateMazeForLevel(level);
  }
}
