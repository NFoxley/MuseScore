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
    const Note(
      midiPitch: 60, // C4
      duration: NoteDuration.whole,
      linePosition: 0,
      color: Colors.blue, // Example of a colored note
    ),
    // Half note
    const Note(
      midiPitch: 62, // D4
      duration: NoteDuration.half,
      linePosition: 0,
      color: Colors.red, // Example of a colored note
    ),
    // Quarter note
    const Note(
      midiPitch: 64, // E4
      duration: NoteDuration.quarter,
      linePosition: 0,
    ),
    // Eighth note
    const Note(
      midiPitch: 65, // F4
      duration: NoteDuration.eighth,
      linePosition: 0,
    ),
    // Sixteenth note
    const Note(
      midiPitch: 67, // G4
      duration: NoteDuration.sixteenth,
      linePosition: 0,
    ),
    // Rest examples with different durations
    const Note(
      midiPitch: -1, // Whole rest
      duration: NoteDuration.whole,
      linePosition: 0,
    ),
    const Note(
      midiPitch: -1, // Half rest
      duration: NoteDuration.half,
      linePosition: 0,
    ),
    const Note(
      midiPitch: -1, // Quarter rest
      duration: NoteDuration.quarter,
      linePosition: 0,
    ),
    const Note(
      midiPitch: -1, // Eighth rest
      duration: NoteDuration.eighth,
      linePosition: 0,
    ),
    const Note(
      midiPitch: -1, // Sixteenth rest
      duration: NoteDuration.sixteenth,
      linePosition: 0,
    ),
  ];

  Clef _clef = Clef.treble;
  bool _useFlats = false;
  KeySignature _keySignature = KeySignature(key: MusicalKey.c);
  TimeSignature _timeSignature = TimeSignature(4, 4);

  // Add map to track key states
  final Map<int, PianoKeyState> _keyStates = {};

  // Track the note to center
  int? _centerMidiPitch;

  // Track the color of the next note to be added
  Color? _nextNoteColor;

  @override
  void initState() {
    super.initState();
    // Initialize key signature state
    _keySignature.initializeNoteState();

    // Example: Highlight and center F4 (MIDI pitch 65)
    _keyStates[65] = PianoKeyState.selected;
    _centerMidiPitch = 65;
  }

  void _handleNoteSelected(Note note) {
    setState(() {
      // Create a new note with the current color if set
      final coloredNote = note.copyWith(color: _nextNoteColor);
      _notes.add(coloredNote);

      // Update key signature state after adding note
      _keySignature.updateNoteState(coloredNote);

      // Example: Highlight and center the first note of a passage
      if (_notes.length == 1) {
        _keyStates[note.midiPitch] = PianoKeyState.selected;
        _centerMidiPitch = note.midiPitch;
      }
    });
  }

  void _handleClear() {
    setState(() {
      _notes.clear();
      // Reinitialize key signature state after clearing notes
      _keySignature.initializeNoteState();
      // Clear key states and center note
      _keyStates.clear();
      _centerMidiPitch = null;
      // Clear next note color
      _nextNoteColor = null;
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

  // Add method to center a specific note
  void _centerNote(int midiPitch) {
    setState(() {
      _centerMidiPitch = midiPitch;
    });
  }

  // Add method to set the color for the next note
  void _setNextNoteColor(Color? color) {
    setState(() {
      _nextNoteColor = color;
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
          // Add color picker buttons
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.blue),
            onPressed: () => _setNextNoteColor(Colors.blue),
            tooltip: 'Set next note to blue',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.red),
            onPressed: () => _setNextNoteColor(Colors.red),
            tooltip: 'Set next note to red',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens, color: Colors.green),
            onPressed: () => _setNextNoteColor(Colors.green),
            tooltip: 'Set next note to green',
          ),
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: () => _setNextNoteColor(null),
            tooltip: 'Reset note color',
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
          // Add button to center A♭5 (MIDI pitch 80)
          IconButton(
            icon: const Text('A♭5'),
            onPressed: () => _centerNote(80),
            tooltip: 'Center A♭5',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                keyStates: _keyStates,
                centerMidiPitch: _centerMidiPitch,
              ),
            ),
            // Add second staff for A major scale
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Staff(
                notes: const [
                  // A major scale from A2 to A3 in bass clef
                  // Each note has its proper staff position and accidental type
                  Note(
                      midiPitch: 45,
                      duration: NoteDuration.quarter,
                      linePosition: -6,
                      accidentalType: AccidentalType.none), // A2
                  Note(
                      midiPitch: 47,
                      duration: NoteDuration.quarter,
                      linePosition: -5,
                      accidentalType: AccidentalType.none), // B2
                  Note(
                      midiPitch: 49,
                      duration: NoteDuration.quarter,
                      linePosition: -4,
                      accidentalType: AccidentalType.sharp), // C#3
                  Note(
                      midiPitch: 50,
                      duration: NoteDuration.quarter,
                      linePosition: -3,
                      accidentalType: AccidentalType.none), // D3
                  Note(
                      midiPitch: 52,
                      duration: NoteDuration.quarter,
                      linePosition: -2,
                      accidentalType: AccidentalType.none), // E3
                  Note(
                      midiPitch: 54,
                      duration: NoteDuration.quarter,
                      linePosition: -1,
                      accidentalType: AccidentalType.sharp), // F#3
                  Note(
                      midiPitch: 56,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.sharp), // G#3
                  Note(
                      midiPitch: 57,
                      duration: NoteDuration.quarter,
                      linePosition: 1,
                      accidentalType: AccidentalType.none), // A3
                ],
                clef: Clef.bass,
                timeSignature: const TimeSignature(4, 4),
                keySignature:
                    KeySignature(key: MusicalKey.a, mode: KeyMode.major),
              ),
            ),
            // Add third staff demonstrating courtesy accidentals and natural signs
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Staff(
                notes: const [
                  // Example in C major showing courtesy accidentals and natural signs
                  Note(
                      midiPitch: 60,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.none), // C4
                  Note(
                      midiPitch: 61,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.sharp), // C#4
                  Note(
                      midiPitch: 60,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType:
                          AccidentalType.natural), // C4 with natural
                  Note(
                      midiPitch: 62,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.none), // D4
                  // Example of double accidentals
                  Note(
                      midiPitch: 61,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.doubleSharp), // C##4
                  Note(
                      midiPitch: 59,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.doubleFlat), // Cbb4
                ],
                clef: Clef.treble,
                timeSignature: const TimeSignature(4, 4),
                keySignature:
                    KeySignature(key: MusicalKey.c, mode: KeyMode.major),
              ),
            ),
            // Add fourth staff demonstrating accidentals in different key signatures
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Staff(
                notes: const [
                  // Example in Bb major showing how accidentals work with flats
                  Note(
                      midiPitch: 58,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.none), // A#4/Bb4
                  Note(
                      midiPitch: 60,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType:
                          AccidentalType.natural), // C5 with natural
                  Note(
                      midiPitch: 58,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.flat), // Bb4
                  Note(
                      midiPitch: 57,
                      duration: NoteDuration.quarter,
                      linePosition: 0,
                      accidentalType: AccidentalType.none), // A4
                ],
                clef: Clef.treble,
                timeSignature: const TimeSignature(4, 4),
                keySignature:
                    KeySignature(key: MusicalKey.bb, mode: KeyMode.major),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accidental Rules Documentation:
///
/// 1. Key Signature Rules:
///    - Notes in the key signature don't need accidentals unless they're altered
///    - In A major (3 sharps: F#, C#, G#), these notes are shown with courtesy accidentals
///    - Natural notes (A, B, D, E) are shown without accidentals
///
/// 2. Courtesy Accidentals:
///    - Used when a note is repeated after being altered
///    - Example: C4 -> C#4 -> C4 (natural sign needed)
///    - Helps prevent confusion when reading the music
///
/// 3. Natural Signs:
///    - Required when canceling a sharp/flat from the key signature
///    - Example: In Bb major, C5 needs a natural sign to cancel the Bb
///
/// 4. Double Accidentals:
///    - Double sharp (##) raises a note by two semitones
///    - Double flat (bb) lowers a note by two semitones
///    - Used in complex harmonic contexts
///
/// 5. Enharmonic Equivalents:
///    - Same pitch can be written different ways (e.g., A# = Bb)
///    - Choice depends on the musical context and key signature
///    - Example: In Bb major, Bb is preferred over A#
///
/// 6. Accidental Duration:
///    - Accidentals affect all notes of the same pitch in the same measure
///    - Reset at the start of each new measure
///    - Courtesy accidentals can be used across measures for clarity

void main() {
  runApp(const MaterialApp(
    home: PianoKeyboardExample(),
  ));
}
