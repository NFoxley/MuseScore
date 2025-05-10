import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart' as models;
import 'package:flutter_music_render/src/engraving/clef.dart';
import 'package:flutter_music_render/src/engraving/key_signature.dart';
import 'package:flutter_music_render/src/engraving/note.dart';
import 'package:flutter_music_render/src/engraving/time_signature.dart';
import 'package:flutter_music_render/src/engraving/staff_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Render Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MusicRenderDemo(),
    );
  }
}

class MusicRenderDemo extends StatefulWidget {
  const MusicRenderDemo({super.key});

  @override
  State<MusicRenderDemo> createState() => _MusicRenderDemoState();
}

class _MusicRenderDemoState extends State<MusicRenderDemo> {
  final List<Note> _notes = [];
  final Set<int> _pressedKeys = {};
  int _currentOctave = 4; // Middle C octave
  final GlobalKey<models.StaffState> _staffKey = GlobalKey<models.StaffState>();
  final KeySignature _cMajor = KeySignature(0, isSharp: true);
  Clef _currentClef = Clef.treble;
  bool _useFlats = false;

  @override
  void initState() {
    super.initState();
    // Add test notes after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addTestNotes();
    });
  }

  void _addTestNotes() {
    // Clear existing notes
    _staffKey.currentState?.clearNotes();

    // Add test notes based on current clef
    if (_currentClef == Clef.treble) {
      // Add notes that should be on specific lines of the treble clef
      _addNoteToStaff(60); // C4 (Middle C) - ledger line below staff
      _addNoteToStaff(64); // E4 - bottom line of staff
      _addNoteToStaff(71); // B4 - middle line of staff
      _addNoteToStaff(77); // F5 - top line of staff

      // Add a black key with accidental
      _addNoteToStaff(61, showAccidental: true); // C#4/Db4
    } else {
      // Add notes that should be on specific lines of the bass clef
      _addNoteToStaff(60); // C4 (Middle C) - ledger line above staff
      _addNoteToStaff(43); // G2 - bottom line of staff
      _addNoteToStaff(50); // D3 - middle line of staff
      _addNoteToStaff(57); // A3 - top line of staff

      // Add a black key with accidental
      _addNoteToStaff(56, showAccidental: true); // G#3/Ab3
    }
  }

  void _addNoteToStaff(int midiPitch, {bool showAccidental = false}) {
    final pitchClass = midiPitch % 12;
    final isBlackKey = pitchClass == 1 ||
        pitchClass == 3 ||
        pitchClass == 6 ||
        pitchClass == 8 ||
        pitchClass == 10;

    AccidentalType accidentalType = AccidentalType.none;
    if (isBlackKey) {
      accidentalType = _useFlats ? AccidentalType.flat : AccidentalType.sharp;
    }

    final note = Note(
      midiPitch: midiPitch,
      duration: NoteDuration.quarter,
      linePosition: 0, // The staff model will calculate the correct staff line
      accidentalType: accidentalType,
      showAccidental: showAccidental && isBlackKey,
    );
    _staffKey.currentState?.addNote(note);
  }

  void _handleKeyPressed(int key) {
    setState(() {
      _pressedKeys.add(key);

      // Determine if this is a black key that needs an accidental
      final pitchClass = key % 12;
      final isBlackKey = pitchClass == 1 ||
          pitchClass == 3 ||
          pitchClass == 6 ||
          pitchClass == 8 ||
          pitchClass == 10;

      AccidentalType accidentalType = AccidentalType.none;
      if (isBlackKey) {
        accidentalType = _useFlats ? AccidentalType.flat : AccidentalType.sharp;
      }

      // Create a note with appropriate accidental
      final note = Note(
        midiPitch: key,
        duration: NoteDuration.quarter,
        linePosition: 0, // Staff model will calculate the correct position
        accidentalType: accidentalType,
        showAccidental: isBlackKey, // Show accidental for black keys
      );

      print('Key pressed: MIDI $key (${_getNoteName(key)})');
      // Don't add to _notes directly - let the staff handle it
      _staffKey.currentState?.addNote(note);
    });
  }

  String _getNoteName(int midiPitch) {
    final pitchClass = midiPitch % 12;
    final octave = (midiPitch ~/ 12) - 1;

    final sharpNames = [
      'C',
      'C♯',
      'D',
      'D♯',
      'E',
      'F',
      'F♯',
      'G',
      'G♯',
      'A',
      'A♯',
      'B'
    ];

    final flatNames = [
      'C',
      'D♭',
      'D',
      'E♭',
      'E',
      'F',
      'G♭',
      'G',
      'A♭',
      'A',
      'B♭',
      'B'
    ];

    final noteName = _useFlats ? flatNames[pitchClass] : sharpNames[pitchClass];
    return '$noteName$octave';
  }

  void _handleKeyReleased(int key) {
    setState(() {
      _pressedKeys.remove(key);
    });
  }

  void _toggleAccidentalDisplay() {
    setState(() {
      _useFlats = !_useFlats;
      // Refresh notes to update accidental display
      _addTestNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Render Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.music_note),
            onPressed: _toggleClef,
            tooltip: 'Toggle Clef',
          ),
          IconButton(
            icon: Text(_useFlats ? '♭' : '♯', style: TextStyle(fontSize: 24)),
            onPressed: _toggleAccidentalDisplay,
            tooltip: 'Toggle Sharp/Flat',
          ),
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
              child: models.Staff(
                key: _staffKey,
                notes: _notes,
                clef: _currentClef,
                timeSignature: const TimeSignature(4, 4),
                keySignature: _cMajor,
                onClear: () {
                  setState(() {
                    _notes.clear();

                    // Add test notes based on current clef after clearing
                    _addTestNotes();
                  });
                },
              ),
            ),
          ),
          // Piano keyboard
          Expanded(
            flex: 3,
            child: models.PianoKeyboard(
              notes: _notes,
              onNoteSelected: (note) {
                _handleKeyPressed(note.midiPitch);
              },
              keySignature: _cMajor,
              useFlats: _useFlats,
              clef: _currentClef,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleClef() {
    setState(() {
      _currentClef = _currentClef == Clef.treble ? Clef.bass : Clef.treble;
      // Add test notes for the new clef
      _addTestNotes();
    });
  }
}
