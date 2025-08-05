import 'package:flutter/material.dart';
import 'package:flutter_3d_app/practical_3d_widget.dart';
import 'package:flutter_3d_app/model_viewer_demo.dart';
import 'package:flutter_3d_app/maze_ball_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 3D App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter 3D App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedDemo = 0;

  final List<Widget> _demos = [
    const Practical3DWidget(),
    const ModelViewerDemo(),
    const MazeBallGame(),
  ];

  final List<String> _demoTitles = ['インタラクティブ立方体', '3Dモデルビューア', '迷路ボールゲーム'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('${widget.title} - ${_demoTitles[_selectedDemo]}'),
      ),
      body: _demos[_selectedDemo],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedDemo,
        onTap: (index) => setState(() => _selectedDemo = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: 'インタラクティブ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.threed_rotation),
            label: 'モデルビューア',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: '迷路ゲーム',
          ),
        ],
      ),
    );
  }
}
