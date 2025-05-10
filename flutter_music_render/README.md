# Flutter Music Render

A Flutter package for rendering musical notation and providing keyboard input, inspired by MuseScore.

## Features

- Render musical notation on staffs (treble and bass)
- Piano keyboard input with visual feedback
- Support for different clefs and time signatures
- Note duration support
- Octave selection

## Getting started

Add this package to your Flutter project by adding the following to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_music_render: ^0.1.0
```

## Usage

Here's a simple example that shows how to use the package to create a piano keyboard that draws notes on a staff:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';

class MusicRenderDemo extends StatefulWidget {
  const MusicRenderDemo({super.key});

  @override
  State<MusicRenderDemo> createState() => _MusicRenderDemoState();
}

class _MusicRenderDemoState extends State<MusicRenderDemo> {
  final List<Note> _notes = [];
  final Set<int> _pressedKeys = {};
  int _currentOctave = 4; // Middle C octave

  void _handleKeyPressed(int key) {
    setState(() {
      _pressedKeys.add(key);
      // Convert MIDI key number to note
      final note = Note(
        pitch: key,
        duration: Duration.quarter,
        octave: _currentOctave,
      );
      _notes.add(note);
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
        title: const Text('Music Render Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _currentOctave = (_currentOctave - 1).clamp(0, 8);
              });
            },
          ),
          Text('Octave: $_currentOctave'),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _currentOctave = (_currentOctave + 1).clamp(0, 8);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Staff display
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Staff(
                notes: _notes,
                clef: Clef.treble,
                timeSignature: const TimeSignature(4, 4),
              ),
            ),
          ),
          // Piano keyboard
          Expanded(
            flex: 3,
            child: PianoKeyboard(
              numberOfKeys: 61, // 5 octaves
              onKeyPressed: _handleKeyPressed,
              onKeyReleased: _handleKeyReleased,
              pressedKeys: _pressedKeys,
            ),
          ),
        ],
      ),
    );
  }
}

## Additional information

This package is designed to match MuseScore's appearance and functionality. It's ideal for:

- Music education apps
- Note input interfaces
- Piano learning applications
- Music theory teaching tools

For more information, visit the [MuseScore website](https://musescore.org). 