import 'package:flutter_music_render/src/engraving/clef.dart';
import 'package:flutter_music_render/src/engraving/note.dart';

/// Represents a musical key signature
class KeySignature {
  final Key key;
  final bool useFlats;

  /// The order of sharps: F C G D A E B
  static const List<String> sharpOrder = ['F', 'C', 'G', 'D', 'A', 'E', 'B'];

  /// The order of flats: B E A D G C F
  static const List<String> flatOrder = ['B', 'E', 'A', 'D', 'G', 'C', 'F'];

  const KeySignature({
    required this.key,
    this.useFlats = false,
  });

  /// Returns the number of accidentals in this key signature
  int accidentalCount() {
    switch (key) {
      case Key.c:
        return 0;
      case Key.g:
      case Key.f:
        return 1;
      case Key.d:
      case Key.bb:
        return 2;
      case Key.a:
      case Key.eb:
        return 3;
      case Key.e:
      case Key.ab:
        return 4;
      case Key.b:
      case Key.db:
        return 5;
      case Key.fs:
      case Key.gb:
        return 6;
      case Key.cs:
      case Key.cb:
        return 7;
    }
  }

  /// Returns whether this key signature uses sharps
  bool get isSharp {
    if (key == Key.c) return false;
    if (useFlats) return false;

    // Keys that use sharps: G, D, A, E, B, F#, C#
    switch (key) {
      case Key.g:
      case Key.d:
      case Key.a:
      case Key.e:
      case Key.b:
      case Key.fs:
      case Key.cs:
        return true;
      default:
        return false;
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

  /// Returns whether a note needs an accidental based on this key signature
  bool needsAccidental(Note note) {
    // If the note has an explicit accidental, always show it
    if (note.accidentalType != AccidentalType.none) {
      return true;
    }

    // Get the pitch class of the note (0-11)
    final pitchClass = note.midiPitch % 12;

    // Check if this pitch class is affected by the key signature
    return !accidentals.contains(pitchClass);
  }

  /// Returns the list of MIDI pitch classes affected by this key signature
  List<int> getAccidentalsInKey() {
    return accidentals;
  }
}

/// Represents a musical key
enum Key {
  c, // C major / A minor
  g, // G major / E minor
  d, // D major / B minor
  a, // A major / F# minor
  e, // E major / C# minor
  b, // B major / G# minor
  fs, // F# major / D# minor
  cs, // C# major / A# minor
  f, // F major / D minor
  bb, // Bb major / G minor
  eb, // Eb major / C minor
  ab, // Ab major / F minor
  db, // Db major / Bb minor
  gb, // Gb major / Eb minor
  cb, // Cb major / Ab minor
}
