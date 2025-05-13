import 'package:flutter_music_render/flutter_music_render.dart';

/// Represents a musical key signature
class KeySignature {
  final MusicalKey key;
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

  /// Determines if a note needs an accidental based on key signature and previous notes
  bool needsAccidental(Note note, List<Note> previousNotes) {
    // Initialize state if not done
    if (noteState.isEmpty) {
      initializeNoteState();
    }

    // Get note name based on the actual accidental type
    final noteName =
        note.getNoteName(useFlats: note.accidentalType == AccidentalType.flat);
    final baseNote = noteName[0];

    print(
        '\nChecking accidental for note: ${noteName} (MIDI: ${note.midiPitch})');
    print(
        'Previous notes: ${previousNotes.map((n) => n.getNoteName(useFlats: n.accidentalType == AccidentalType.flat)).join(", ")}');
    print('Is in key signature: ${isNoteInKeySignature(note)}');
    print('Current state: ${noteState[note.pitchClass]}');
    print('Altered notes in measure: ${alteredNotesInMeasure.keys.join(", ")}');

    // If note is in key signature and matches the key signature accidental
    if (isNoteInKeySignature(note)) {
      print('Note matches key signature, no accidental needed');
      return false;
    }

    // If note is tied, show accidental
    if (tiedNotes.contains(note.midiPitch)) {
      print('Note is tied, showing accidental');
      return true;
    }

    // Check if this base note was altered earlier in the measure
    if (alteredNotesInMeasure.containsKey(baseNote)) {
      final currentState = alteredNotesInMeasure[baseNote];
      // Only show accidental if it's different from the current state
      if (note.accidentalType != currentState) {
        print(
            'Note was altered earlier in measure and needs different accidental');
        return true;
      }
      print('Note was altered earlier in measure but matches current state');
      return false;
    }

    // If note is not in key signature, we need to show its accidental
    // This includes natural signs for notes that would otherwise be sharp/flat in the key
    final keyAccidentals = isSharp ? sharpOrder : flatOrder;
    final count = accidentalCount();
    if (keyAccidentals.sublist(0, count).contains(baseNote)) {
      // This note is in the key signature but with a different accidental
      print('Note is in key signature but with different accidental');
      return true;
    }

    // If note has an explicit accidental, show it
    if (note.accidentalType != AccidentalType.none) {
      print('Note has explicit accidental');
      return true;
    }

    print('No accidental needed');
    return false;
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
    print('Is in key signature: ${isNoteInKeySignature(note)}');

    // If note is in key signature and matches the key signature accidental,
    // treat it as if it has no explicit accidental
    if (isNoteInKeySignature(note)) {
      final keyAccidental =
          isSharp ? AccidentalType.sharp : AccidentalType.flat;
      noteState[note.pitchClass] = keyAccidental;
      print('Note is in key signature and matches key signature accidental');
      lastOctave[note.pitchClass] = note.midiPitch ~/ 12;
      return;
    }

    // Update state with the actual accidental type of the note
    if (note.accidentalType != AccidentalType.none) {
      // If note has an explicit accidental, use that
      noteState[note.pitchClass] = note.accidentalType;
      // Mark as altered in measure with base note name (without octave)
      alteredNotesInMeasure[baseNote] = note.accidentalType;
      print('Note has explicit accidental: ${note.accidentalType}');
      print('Marked as altered in measure: $baseNote');
    } else {
      // If note is natural, check if it's in the key signature
      if (isNoteInKeySignature(note)) {
        noteState[note.pitchClass] =
            isSharp ? AccidentalType.sharp : AccidentalType.flat;
        print('Note is in key signature, set to ${isSharp ? "sharp" : "flat"}');
      } else {
        noteState[note.pitchClass] = AccidentalType.none;
        print('Note is not in key signature, set to natural');
      }
    }

    // Update last octave
    lastOctave[note.pitchClass] = note.midiPitch ~/ 12;
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
    if (key == MusicalKey.c) return false;
    if (useFlats) return false;

    // Keys that use sharps: G, D, A, E, B, F#, C#
    switch (key) {
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
    switch (key) {
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
}
