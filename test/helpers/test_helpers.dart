import 'package:mockito/annotations.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/game_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/maze_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/repositories/sensor_repository.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/physics_usecase.dart';
import 'package:flutter_3d_app/features/maze_ball/domain/usecases/game_usecase.dart';

@GenerateMocks([
  GameRepository,
  MazeRepository,
  SensorRepository,
  PhysicsUseCase,
  GameUseCase,
])
void main() {}
