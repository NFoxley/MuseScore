import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';

/// A simple example that demonstrates the piano keyboard and staff widgets.
/// Copy and paste this entire file into your Flutter app to get started.
class PianoKeyboardExample extends StatefulWidget {
  const PianoKeyboardExample({super.key});

  @override
  State<PianoKeyboardExample> createState() => _PianoKeyboardExampleState();
}

class _PianoKeyboardExampleState extends State<PianoKeyboardExample> {
  final List<Note> _notes = [
    Note(
      midiPitch: 65, // F4
      duration: NoteDuration.quarter,
      linePosition: 0,
    ),
    Note(
      midiPitch: 57, // A3
      duration: NoteDuration.quarter,
      linePosition: 0,
    ),
  ];

  Clef _clef = Clef.treble;
  bool _useFlats = false;
  final KeySignature _keySignature = KeySignature(0, isSharp: true);
  final TimeSignature _timeSignature = TimeSignature(4, 4);

  void _handleNoteSelected(Note note) {
    setState(() {
      _notes.add(note);
    });
  }

  void _handleClear() {
    setState(() {
      _notes.clear();
    });
  }

  void _toggleClef() {
    setState(() {
      _clef = _clef == Clef.treble ? Clef.bass : Clef.treble;
    });
  }

  void _toggleAccidentals() {
    setState(() {
      _useFlats = !_useFlats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano Keyboard Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.music_note),
            onPressed: _toggleClef,
            tooltip: 'Toggle Clef',
          ),
          IconButton(
            icon: Text(_useFlats ? '♭' : '♯'),
            onPressed: _toggleAccidentals,
            tooltip: 'Toggle Accidentals',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Staff(
              notes: _notes,
              clef: _clef,
              timeSignature: _timeSignature,
              keySignature: _keySignature,
              onClear: _handleClear,
            ),
          ),
          SizedBox(
            height: 200,
            child: PianoKeyboard(
              notes: _notes,
              onNoteSelected: _handleNoteSelected,
              keySignature: _keySignature,
              useFlats: _useFlats,
              clef: _clef,
            ),
          ),
        ],
      ),
    );
  }
}

// To use this example, add the following to your main.dart:
/*
import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';

void main() {
  runApp(const MaterialApp(
    home: PianoKeyboardExample(),
  ));
}
*/
