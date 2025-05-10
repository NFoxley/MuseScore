import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Keyboard Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PianoKeyboardDemo(),
    );
  }
}

class PianoKeyboardDemo extends StatefulWidget {
  const PianoKeyboardDemo({super.key});

  @override
  State<PianoKeyboardDemo> createState() => _PianoKeyboardDemoState();
}

class _PianoKeyboardDemoState extends State<PianoKeyboardDemo> {
  final Set<int> _pressedKeys = {};
  final Set<int> _selectedKeys = {};
  double _keyWidthScaling = 1.0;

  void _handleKeyPressed(int key) {
    setState(() {
      _pressedKeys.add(key);
    });
  }

  void _handleKeyReleased(int key) {
    setState(() {
      _pressedKeys.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano Keyboard Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                _keyWidthScaling = (_keyWidthScaling + 0.1).clamp(0.5, 2.0);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                _keyWidthScaling = (_keyWidthScaling - 0.1).clamp(0.5, 2.0);
              });
            },
          ),
        ],
      ),
    );
  }
}
