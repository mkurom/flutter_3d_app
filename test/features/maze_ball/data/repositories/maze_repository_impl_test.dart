import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_3d_app/features/maze_ball/data/repositories/maze_repository_impl.dart';
import 'package:flutter_3d_app/features/maze_ball/data/datasources/maze_generator.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/entities/maze.dart';

@GenerateMocks([MazeGenerator])
import 'maze_repository_impl_test.mocks.dart';

void main() {
  group('MazeRepositoryImpl', () {
    late MazeRepositoryImpl repository;
    late MockMazeGenerator mockMazeGenerator;

    setUp(() {
      mockMazeGenerator = MockMazeGenerator();
      repository = MazeRepositoryImpl(mazeGenerator: mockMazeGenerator);
    });

    group('generateMaze', () {
      test('should return maze from generator', () async {
        // Arrange
        const width = 10;
        const height = 10;
        final expectedMaze = Maze(
          grid: List.generate(height, (y) => List.generate(width, (x) => 0)),
          width: width,
          height: height,
        );

        when(
          mockMazeGenerator.generateSimpleMaze(width, height),
        ).thenReturn(expectedMaze);

        // Act
        final result = await repository.generateMaze(width, height);

        // Assert
        expect(result, equals(expectedMaze));
        verify(mockMazeGenerator.generateSimpleMaze(width, height)).called(1);
      });

      test('should handle different maze sizes', () async {
        // Arrange
        const width = 5;
        const height = 7;
        final expectedMaze = Maze(
          grid: List.generate(height, (y) => List.generate(width, (x) => 1)),
          width: width,
          height: height,
        );

        when(
          mockMazeGenerator.generateSimpleMaze(width, height),
        ).thenReturn(expectedMaze);

        // Act
        final result = await repository.generateMaze(width, height);

        // Assert
        expect(result.width, equals(width));
        expect(result.height, equals(height));
        verify(mockMazeGenerator.generateSimpleMaze(width, height)).called(1);
      });
    });

    group('getMazeForLevel', () {
      test('should return maze for specific level', () async {
        // Arrange
        const level = 1;
        final expectedMaze = Maze(
          grid: [
            [1, 0, 1],
            [1, 0, 1],
            [1, 2, 1],
          ],
          width: 3,
          height: 3,
        );

        when(
          mockMazeGenerator.generateMazeForLevel(level),
        ).thenReturn(expectedMaze);

        // Act
        final result = await repository.getMazeForLevel(level);

        // Assert
        expect(result, equals(expectedMaze));
        verify(mockMazeGenerator.generateMazeForLevel(level)).called(1);
      });

      test('should handle different levels', () async {
        // Arrange
        const level1 = 1;
        const level2 = 5;

        final maze1 = Maze(
          grid: [
            [0],
          ],
          width: 1,
          height: 1,
        );
        final maze2 = Maze(
          grid: [
            [1],
          ],
          width: 1,
          height: 1,
        );

        when(mockMazeGenerator.generateMazeForLevel(level1)).thenReturn(maze1);
        when(mockMazeGenerator.generateMazeForLevel(level2)).thenReturn(maze2);

        // Act
        final result1 = await repository.getMazeForLevel(level1);
        final result2 = await repository.getMazeForLevel(level2);

        // Assert
        expect(result1, equals(maze1));
        expect(result2, equals(maze2));
        verify(mockMazeGenerator.generateMazeForLevel(level1)).called(1);
        verify(mockMazeGenerator.generateMazeForLevel(level2)).called(1);
      });

      test('should handle level 0', () async {
        // Arrange
        const level = 0;
        final expectedMaze = Maze(
          grid: [
            [0],
          ],
          width: 1,
          height: 1,
        );

        when(
          mockMazeGenerator.generateMazeForLevel(level),
        ).thenReturn(expectedMaze);

        // Act
        final result = await repository.getMazeForLevel(level);

        // Assert
        expect(result, equals(expectedMaze));
        verify(mockMazeGenerator.generateMazeForLevel(level)).called(1);
      });
    });

    group('error handling', () {
      test('should propagate exceptions from maze generator', () async {
        // Arrange
        const width = 10;
        const height = 10;
        when(
          mockMazeGenerator.generateSimpleMaze(width, height),
        ).thenThrow(Exception('Maze generation failed'));

        // Act & Assert
        expect(
          () async => await repository.generateMaze(width, height),
          throwsException,
        );
        verify(mockMazeGenerator.generateSimpleMaze(width, height)).called(1);
      });

      test(
        'should propagate exceptions from level-based maze generation',
        () async {
          // Arrange
          const level = 1;
          when(
            mockMazeGenerator.generateMazeForLevel(level),
          ).thenThrow(Exception('Level maze generation failed'));

          // Act & Assert
          expect(
            () async => await repository.getMazeForLevel(level),
            throwsException,
          );
          verify(mockMazeGenerator.generateMazeForLevel(level)).called(1);
        },
      );
    });
  });
}
