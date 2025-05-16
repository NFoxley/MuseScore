import 'package:flutter_music_render/flutter_music_render.dart';

enum KeyMode { major, minor }

/// Represents a musical key signature
class KeySignature {
  final MusicalKey key;
  final KeyMode mode;
  final bool useFlats;

  /// The order of sharps: F C G D A E B
  static const List<String> sharpOrder = ['F', 'C', 'G', 'D', 'A', 'E', 'B'];

  /// The order of flats: B E A D G C F
  static const List<String> flatOrder = ['B', 'E', 'A', 'D', 'G', 'C', 'F'];

  /// Tracks the state of notes in the key signature
  final Map<int, AccidentalType> noteState = {};

  /// Tracks the last octave a note was played in
  final Map<int, int> lastOctave = {};

  /// Tracks tied notes
  final Set<int> tiedNotes = {};

  /// Tracks notes that have been altered in the current measure
  final Map<String, AccidentalType> alteredNotesInMeasure = {};

  KeySignature({
    required this.key,
    this.mode = KeyMode.major,
    this.useFlats = false,
  });

  /// Initialize the note state based on key signature
  void initializeNoteState() {
    noteState.clear();
    lastOctave.clear();
    tiedNotes.clear();
    alteredNotesInMeasure.clear();

    // Initialize all notes as natural
    for (int i = 0; i < 12; i++) {
      noteState[i] = AccidentalType.none;
    }

    // Mark notes that are in the key signature
    final keyAccidentals = isSharp ? sharpOrder : flatOrder;
    final count = accidentalCount();
    print('Key Signature: ${key.toString()} (${isSharp ? "Sharps" : "Flats"})');
    print('Notes in key: ${keyAccidentals.sublist(0, count)}');

    for (final note in keyAccidentals.sublist(0, count)) {
      print('Adding ${note}${isSharp ? "♯" : "♭"} to key signature');
      // Convert note name to pitch class
      final pitchClass = _getPitchClass(note);
      noteState[pitchClass] =
          isSharp ? AccidentalType.sharp : AccidentalType.flat;
    }
  }

  /// Convert a note name to pitch class
  int _getPitchClass(String note) {
    switch (note) {
      case 'C':
        return 0;
      case 'D':
        return 2;
      case 'E':
        return 4;
      case 'F':
        return 5;
      case 'G':
        return 7;
      case 'A':
        return 9;
      case 'B':
        return 11;
      default:
        return 0;
    }
  }

  /// Returns whether a note is in the key signature
  bool isNoteInKeySignature(Note note) {
    // Get the note name with its actual accidental
    final noteName =
        note.getNoteName(useFlats: note.accidentalType == AccidentalType.flat);
    final baseNote = noteName[0]; // Get the letter name (C, D, E, etc.)

    // Get the accidentals in this key signature
    final keyAccidentals = isSharp ? sharpOrder : flatOrder;
    final count = accidentalCount();

    // Check if this note's base name is in the key signature
    final isInKey = keyAccidentals.sublist(0, count).contains(baseNote);

    // If the note is in the key signature, check if its accidental matches
    if (isInKey) {
      final keyAccidental =
          isSharp ? AccidentalType.sharp : AccidentalType.flat;
      // A note is in the key signature if:
      // 1. Its base note is in the key signature AND
      // 2. It has the same accidental as the key signature
      return note.accidentalType == keyAccidental;
    }

    return false;
  }

  /// Returns the accidental type for a note in the key signature
  AccidentalType getKeySignatureAccidental(Note note) {
    if (!isNoteInKeySignature(note)) {
      return AccidentalType.none;
    }
    return isSharp ? AccidentalType.sharp : AccidentalType.flat;
  }

  /// Called at the start of each measure to reset the altered notes
  void startNewMeasure() {
    alteredNotesInMeasure.clear();
  }

  /// Get the current state of a note
  AccidentalType getNoteState(Note note) {
    // Initialize state if not done
    if (noteState.isEmpty) {
      initializeNoteState();
    }
    return noteState[note.pitchClass] ?? AccidentalType.none;
  }

  /// Updates the note state after a note is played
  void updateNoteState(Note note) {
    if (noteState.isEmpty) {
      initializeNoteState();
    }

    // Get note name based on the actual accidental type
    final noteName =
        note.getNoteName(useFlats: note.accidentalType == AccidentalType.flat);
    final baseNote = noteName[0];

    print('\nUpdating state for note: ${noteName} (MIDI: ${note.midiPitch})');

    // Check if this note's base name is in the key signature
    final keyAccidentals = isSharp ? sharpOrder : flatOrder;
    final count = accidentalCount();
    final isBaseNoteInKey = keyAccidentals.sublist(0, count).contains(baseNote);
    print('Base note $baseNote is in key signature: $isBaseNoteInKey');

    // Track the current state of this note in the measure
    if (isBaseNoteInKey) {
      // If the note is in the key signature (has the key's sharp/flat)
      if (note.accidentalType ==
          (isSharp ? AccidentalType.sharp : AccidentalType.flat)) {
        noteState[note.pitchClass] = note.accidentalType;
        print('Note matches key signature');
      } else {
        // If the note has a different accidental than the key signature
        noteState[note.pitchClass] = note.accidentalType;
        alteredNotesInMeasure[baseNote] = note.accidentalType;
        print('Note deviates from key signature, marked as altered');
      }
    } else {
      // If the note is not in the key signature
      noteState[note.pitchClass] = note.accidentalType;
      if (note.accidentalType != AccidentalType.none) {
        alteredNotesInMeasure[baseNote] = note.accidentalType;
        print('Note has explicit accidental, marked as altered');
      }
    }

    // Update last octave
    lastOctave[note.pitchClass] = note.midiPitch ~/ 12;
  }

  /// Check if a note needs an accidental
  bool needsAccidental(Note note, List<Note> previousNotes) {
    print(
        '\nChecking accidental for note: ${note.getNoteName()} (MIDI: ${note.midiPitch})');
    print(
        'Previous notes: ${previousNotes.map((n) => n.getNoteName()).join(', ')}');

    // Get the base note name and octave
    final noteName =
        note.getNoteName(useFlats: note.accidentalType == AccidentalType.flat);
    final baseNote = noteName[0];
    final octave = (note.midiPitch ~/ 12) - 1;

    // Check if this note's base name is in the key signature
    final keyAccidentals = isSharp ? sharpOrder : flatOrder;
    final count = accidentalCount();
    final isBaseNoteInKey = keyAccidentals.sublist(0, count).contains(baseNote);
    print('Base note $baseNote is in key signature: $isBaseNoteInKey');

    // Find the most recent previous note with the same base note and octave
    AccidentalType previousAccidental = AccidentalType.none;
    bool foundPrevious = false;
    for (int i = previousNotes.length - 1; i >= 0; i--) {
      final prevNote = previousNotes[i];
      final prevNoteName = prevNote.getNoteName(
          useFlats: prevNote.accidentalType == AccidentalType.flat);
      final prevBaseNote = prevNoteName[0];
      final prevOctave = (prevNote.midiPitch ~/ 12) - 1;
      if (prevBaseNote == baseNote && prevOctave == octave) {
        previousAccidental = prevNote.accidentalType;
        foundPrevious = true;
        print(
            'Most recent previous $baseNote$octave had accidental $previousAccidental');
        break;
      }
    }

    // If no previous note found, use key signature
    if (!foundPrevious) {
      // For notes in the key signature, use the key's accidental type
      if (isBaseNoteInKey) {
        previousAccidental =
            isSharp ? AccidentalType.sharp : AccidentalType.flat;
      } else {
        // For notes not in the key signature, they are natural
        previousAccidental = AccidentalType.none;
      }
      print(
          'No previous $baseNote$octave, using key signature accidental $previousAccidental');
    }

    // Determine if we need an accidental:
    // 1. If the note is in the key signature:
    //    - Show accidental if it differs from the key signature
    // 2. If the note is not in the key signature:
    //    - Show accidental if it's an explicit accidental (not natural)
    //    - Show natural sign if previous note had an accidental
    // 3. Always show accidental if it differs from the previous note
    final needsAccidental = isBaseNoteInKey
        ? note.accidentalType != previousAccidental
        : (note.accidentalType != AccidentalType.none &&
                note.accidentalType != AccidentalType.natural) ||
            (note.accidentalType == AccidentalType.natural &&
                previousAccidental != AccidentalType.none);

    print(
        'Current accidental ${note.accidentalType} differs from previous $previousAccidental, needs accidental: $needsAccidental');
    return needsAccidental;
  }

  /// Marks a note as tied
  void markTied(int midiPitch) {
    tiedNotes.add(midiPitch);
  }

  /// Clears tied note state
  void clearTiedNotes() {
    tiedNotes.clear();
  }

  /// Returns whether this key signature uses sharps
  bool get isSharp {
    final useKey = mode == KeyMode.minor ? relativeMajor : key;
    if (useKey == MusicalKey.c) return false;
    if (useFlats) return false;
    switch (useKey) {
      case MusicalKey.g:
      case MusicalKey.d:
      case MusicalKey.a:
      case MusicalKey.e:
      case MusicalKey.b:
      case MusicalKey.fs:
      case MusicalKey.cs:
        return true;
      default:
        return false;
    }
  }

  /// Returns the number of accidentals in this key signature
  int accidentalCount() {
    final useKey = mode == KeyMode.minor ? relativeMajor : key;
    switch (useKey) {
      case MusicalKey.c:
        return 0;
      case MusicalKey.g:
      case MusicalKey.f:
        return 1;
      case MusicalKey.d:
      case MusicalKey.bb:
        return 2;
      case MusicalKey.a:
      case MusicalKey.eb:
        return 3;
      case MusicalKey.e:
      case MusicalKey.ab:
        return 4;
      case MusicalKey.b:
      case MusicalKey.db:
        return 5;
      case MusicalKey.fs:
      case MusicalKey.gb:
        return 6;
      case MusicalKey.cs:
      case MusicalKey.cb:
        return 7;
    }
  }

  /// Returns the list of accidentals in this key signature
  List<int> get accidentals {
    final count = accidentalCount();
    if (count == 0) return [];

    final List<int> result = [];
    if (isSharp) {
      // Order of sharps: F C G D A E B
      final sharpOrder = [5, 0, 7, 2, 9, 4, 11];
      for (var i = 0; i < count; i++) {
        result.add(sharpOrder[i]);
      }
    } else {
      // Order of flats: B E A D G C F
      final flatOrder = [11, 4, 9, 2, 7, 0, 5];
      for (var i = 0; i < count; i++) {
        result.add(flatOrder[i]);
      }
    }
    return result;
  }

  /// Returns the positions of accidentals in this key signature for the given clef
  List<double> getAccidentalPositions(Clef clef) {
    final positions = <double>[];
    final accidentals = this.accidentals;

    for (final accidental in accidentals) {
      // Convert MIDI pitch class to staff position
      double position;
      switch (clef) {
        case Clef.treble:
          position = (accidental - 69) / 2; // Middle C (C4) is at 0
          break;
        case Clef.bass:
          position = (accidental - 57) / 2; // Middle C (C4) is at 6
          break;
        case Clef.alto:
          position = (accidental - 60) / 2; // Middle C (C4) is at 0
          break;
        case Clef.tenor:
          position = (accidental - 62) / 2; // Middle C (C4) is at 2
          break;
      }
      positions.add(position);
    }

    return positions;
  }

  /// Returns the list of MIDI pitch classes affected by this key signature
  List<int> getAccidentalsInKey() {
    return accidentals;
  }

  MusicalKey get relativeMajor {
    if (mode == KeyMode.major) return key;
    switch (key) {
      case MusicalKey.a:
        return MusicalKey.c;
      case MusicalKey.e:
        return MusicalKey.g;
      case MusicalKey.b:
        return MusicalKey.d;
      case MusicalKey.fs:
        return MusicalKey.a;
      case MusicalKey.cs:
        return MusicalKey.e;
      case MusicalKey.g:
        return MusicalKey.bb;
      case MusicalKey.d:
        return MusicalKey.f;
      case MusicalKey.c:
        return MusicalKey.eb;
      case MusicalKey.f:
        return MusicalKey.ab;
      case MusicalKey.bb:
        return MusicalKey.db;
      case MusicalKey.eb:
        return MusicalKey.gb;
      case MusicalKey.ab:
        return MusicalKey.cb;
      case MusicalKey.db:
        return MusicalKey.e;
      case MusicalKey.gb:
        return MusicalKey.b;
      case MusicalKey.cb:
        return MusicalKey.fs;
    }
  }
}
