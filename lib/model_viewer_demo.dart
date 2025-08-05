import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelViewerDemo extends StatefulWidget {
  const ModelViewerDemo({super.key});

  @override
  State<ModelViewerDemo> createState() => _ModelViewerDemoState();
}

class _ModelViewerDemoState extends State<ModelViewerDemo> {
  bool _isLoading = true;
  String _selectedModel = 'astronaut';
  bool _autoRotate = true;
  bool _enableAR = true;

  final Map<String, Map<String, String>> _models = {
    'astronaut': {
      'name': '宇宙飛行士',
      'src': 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
      'poster': 'https://modelviewer.dev/shared-assets/models/Astronaut.webp',
      'description': 'NASA提供の宇宙飛行士3Dモデル',
    },
    'brainstorm': {
      'name': 'ブレインストーム',
      'src': 'https://modelviewer.dev/shared-assets/models/brainstem.gltf',
      'poster': 'https://modelviewer.dev/shared-assets/models/brainstem.webp',
      'description': '医学的な脳幹の3Dモデル',
    },
    'horse': {
      'name': '馬',
      'src': 'https://modelviewer.dev/shared-assets/models/Horse.glb',
      'poster': 'https://modelviewer.dev/shared-assets/models/Horse.webp',
      'description': 'リアルな馬の3Dモデル',
    },
  };

  @override
  Widget build(BuildContext context) {
    final currentModel = _models[_selectedModel]!;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0f0f23), Color(0xFF1a1a2e), Color(0xFF16213e)],
        ),
      ),
      child: Column(
        children: [
          // モデル選択バー
          Container(
            height: 60,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children:
                  _models.entries.map((entry) {
                    final isSelected = _selectedModel == entry.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedModel = entry.key),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              entry.value['name']!,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.white70,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          // 3Dモデルビューア
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    ModelViewer(
                      backgroundColor: const Color(0xFF1a1a2e),
                      src: currentModel['src']!,
                      poster: currentModel['poster'],
                      alt: currentModel['description']!,
                      ar: _enableAR,
                      autoRotate: _autoRotate,
                      cameraControls: true,
                      shadowIntensity: 0.7,
                      shadowSoftness: 0.5,
                      loading: Loading.lazy,
                      onWebViewCreated: (controller) {
                        setState(() => _isLoading = false);
                      },
                    ),
                    if (_isLoading)
                      Container(
                        color: const Color(0xFF1a1a2e),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.blue),
                              SizedBox(height: 16),
                              Text(
                                '3Dモデル読み込み中...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // コントロールオーバーレイ
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Column(
                        children: [
                          _buildControlIcon(
                            icon: _autoRotate ? Icons.pause : Icons.play_arrow,
                            onTap:
                                () =>
                                    setState(() => _autoRotate = !_autoRotate),
                            tooltip: _autoRotate ? '自動回転停止' : '自動回転開始',
                          ),
                          const SizedBox(height: 8),
                          _buildControlIcon(
                            icon: Icons.view_in_ar,
                            onTap: () => setState(() => _enableAR = !_enableAR),
                            tooltip: 'AR${_enableAR ? '無効' : '有効'}',
                            isActive: _enableAR,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 情報パネル
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.threed_rotation, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      currentModel['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentModel['description']!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🖱️ ドラッグ: 回転 | 📏 ピンチ: ズーム | 📱 AR対応',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlIcon({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              isActive
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                isActive
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.blue : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
