import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';

/// A simple example that demonstrates the piano keyboard and staff widgets.
///
/// To use this example in your app:
/// 1. Add flutter_music_render to your pubspec.yaml:
///    ```yaml
///    dependencies:
///      flutter_music_render:
///        path: /path/to/flutter_music_render
///    ```
/// 2. Run `flutter pub get`
/// 3. Copy this entire file into your app
/// 4. Update the main() function to use your app's entry point
class PianoKeyboardExample extends StatefulWidget {
  const PianoKeyboardExample({super.key});

  @override
  State<PianoKeyboardExample> createState() => _PianoKeyboardExampleState();
}

class _PianoKeyboardExampleState extends State<PianoKeyboardExample> {
  final List<Note> _notes = [
    // Whole note
    Note(
      midiPitch: 60, // C4
      duration: NoteDuration.whole,
      linePosition: 0,
    ),
    // Half note
    Note(
      midiPitch: 62, // D4
      duration: NoteDuration.half,
      linePosition: 0,
    ),
    // Quarter note
    Note(
      midiPitch: 64, // E4
      duration: NoteDuration.quarter,
      linePosition: 0,
    ),
    // Eighth note
    Note(
      midiPitch: 65, // F4
      duration: NoteDuration.eighth,
      linePosition: 0,
    ),
    // Sixteenth note
    Note(
      midiPitch: 67, // G4
      duration: NoteDuration.sixteenth,
      linePosition: 0,
    ),
    // Rest examples with different durations
    Note(
      midiPitch: -1, // Whole rest
      duration: NoteDuration.whole,
      linePosition: 0,
    ),
    Note(
      midiPitch: -1, // Half rest
      duration: NoteDuration.half,
      linePosition: 0,
    ),
    Note(
      midiPitch: -1, // Quarter rest
      duration: NoteDuration.quarter,
      linePosition: 0,
    ),
    Note(
      midiPitch: -1, // Eighth rest
      duration: NoteDuration.eighth,
      linePosition: 0,
    ),
    Note(
      midiPitch: -1, // Sixteenth rest
      duration: NoteDuration.sixteenth,
      linePosition: 0,
    ),
  ];

  Clef _clef = Clef.treble;
  bool _useFlats = false;
  KeySignature _keySignature = KeySignature(key: MusicalKey.c);
  final TimeSignature _timeSignature = TimeSignature(4, 4);

  @override
  void initState() {
    super.initState();
    // Initialize key signature state
    _keySignature.initializeNoteState();
  }

  void _handleNoteSelected(Note note) {
    setState(() {
      _notes.add(note);
      // Update key signature state after adding note
      _keySignature.updateNoteState(note);
    });
  }

  void _handleClear() {
    setState(() {
      _notes.clear();
      // Reinitialize key signature state after clearing notes
      _keySignature.initializeNoteState();
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

  void _changeKeySignature(KeySignature key) {
    setState(() {
      _keySignature = key;
      // Initialize new key signature state
      _keySignature.initializeNoteState();
      // Clear notes when changing key
      _notes.clear();
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
          PopupMenuButton<KeySignature>(
            icon: const Icon(Icons.music_note),
            tooltip: 'Select Key Signature',
            onSelected: _changeKeySignature,
            itemBuilder: (context) => [
              // Major keys
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.c, mode: KeyMode.major),
                child: const Text('C Major'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.bb, mode: KeyMode.major),
                child: const Text('B♭ Major'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.e, mode: KeyMode.major),
                child: const Text('E Major'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.db, mode: KeyMode.major),
                child: const Text('D♭ Major'),
              ),
              // Minor keys
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.a, mode: KeyMode.minor),
                child: const Text('A minor'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.g, mode: KeyMode.minor),
                child: const Text('G minor'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.e, mode: KeyMode.minor),
                child: const Text('E minor'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.d, mode: KeyMode.minor),
                child: const Text('D minor'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.bb, mode: KeyMode.minor),
                child: const Text('B♭ minor'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.c, mode: KeyMode.minor),
                child: const Text('C minor'),
              ),
              PopupMenuItem(
                value: KeySignature(key: MusicalKey.f, mode: KeyMode.minor),
                child: const Text('F minor'),
              ),
            ],
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
// import 'package:flutter/material.dart';
// import 'package:flutter_music_render/flutter_music_render.dart';

// void main() {
//   runApp(const MaterialApp(
//     home: PianoKeyboardExample(),
//   ));
// }
