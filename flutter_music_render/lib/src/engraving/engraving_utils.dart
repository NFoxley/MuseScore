import 'package:flutter_music_render/src/engraving/clef.dart';
import 'package:flutter_music_render/src/engraving/key_signature.dart';
import 'package:flutter_music_render/src/engraving/note.dart';

/// Utility class for engraving calculations
class EngravingUtils {
  /// Get the accidental symbol for a given accidental type
  static String getAccidentalSymbol(AccidentalType type) {
    switch (type) {
      case AccidentalType.sharp:
        return '♯';
      case AccidentalType.flat:
        return '♭';
      case AccidentalType.natural:
        return '♮';
      case AccidentalType.doubleSharp:
        return '𝄪';
      case AccidentalType.doubleFlat:
        return '𝄫';
      default:
        return '';
    }
  }

  /// Get the positions of accidentals in a key signature for a given clef
  static List<Point> getKeySignaturePositions(
      KeySignature keySignature, Clef clef) {
    final positions = <Point>[];
    final accidentals = keySignature.accidentals;
    final isSharp = keySignature.isSharp;

    // Get the order of accidentals based on whether we're using sharps or flats
    final order = isSharp ? KeySignature.sharpOrder : KeySignature.flatOrder;

    // Get the line positions for each accidental based on the clef
    for (var i = 0; i < accidentals.length; i++) {
      final note = order[i];
      final line =
          isSharp ? _getSharpLine(note, clef) : _getFlatLine(note, clef);
      positions.add(Point(0, line, note: note));
    }

    return positions;
  }

  /// Get the line positions for key signature accidentals
  static List<double> getKeySignatureLines(
      KeySignature keySignature, Clef clef) {
    final positions = <double>[];
    final isSharp = keySignature.isSharp;
    final order = isSharp ? KeySignature.sharpOrder : KeySignature.flatOrder;

    for (int i = 0; i < keySignature.accidentalCount(); i++) {
      final note = order[i];
      final line = _getKeySignatureLine(note, clef, isSharp);
      positions.add(line);
    }

    return positions;
  }

  /// Get the staff line for a key signature note
  static double _getKeySignatureLine(String note, Clef clef, bool isSharp) {
    switch (clef) {
      case Clef.treble:
        return isSharp ? _getTrebleSharpLine(note) : _getTrebleFlatLine(note);
      case Clef.bass:
        return isSharp ? _getBassSharpLine(note) : _getBassFlatLine(note);
      case Clef.alto:
        return isSharp ? _getAltoSharpLine(note) : _getAltoFlatLine(note);
      case Clef.tenor:
        return isSharp ? _getTenorSharpLine(note) : _getTenorFlatLine(note);
    }
  }

  /// Get the treble clef sharp line for a note
  static double _getTrebleSharpLine(String note) {
    switch (note) {
      case 'F':
        return 0.0; // F♯ on top line
      case 'C':
        return 1.5; // C♯ on second space
      case 'G':
        return 1.0; // G♯ on second line
      case 'D':
        return 3.5; // D♯ on third space
      case 'A':
        return 3.0; // A♯ on third line
      case 'E':
        return 4.5; // E♯ on fourth space
      case 'B':
        return 4.0; // B♯ on fourth line
      default:
        return 0.0;
    }
  }

  /// Get the treble clef flat line for a note
  static double _getTrebleFlatLine(String note) {
    switch (note) {
      case 'B':
        return 0.0; // B♭ on top line
      case 'E':
        return 1.5; // E♭ on second space
      case 'A':
        return 1.0; // A♭ on second line
      case 'D':
        return 3.5; // D♭ on third space
      case 'G':
        return 3.0; // G♭ on third line
      case 'C':
        return 4.5; // C♭ on fourth space
      case 'F':
        return 4.0; // F♭ on fourth line
      default:
        return 0.0;
    }
  }

  /// Get the bass clef sharp line for a note
  static double _getBassSharpLine(String note) {
    switch (note) {
      case 'F':
        return 2.0; // F♯ on middle line
      case 'C':
        return 3.5; // C♯ on third space
      case 'G':
        return 3.0; // G♯ on third line
      case 'D':
        return 4.5; // D♯ on fourth space
      case 'A':
        return 4.0; // A♯ on fourth line
      case 'E':
        return 5.5; // E♯ on fifth space
      case 'B':
        return 5.0; // B♯ on fifth line
      default:
        return 0.0;
    }
  }

  /// Get the bass clef flat line for a note
  static double _getBassFlatLine(String note) {
    switch (note) {
      case 'B':
        return 2.0; // B♭ on middle line
      case 'E':
        return 3.5; // E♭ on third space
      case 'A':
        return 3.0; // A♭ on third line
      case 'D':
        return 4.5; // D♭ on fourth space
      case 'G':
        return 4.0; // G♭ on fourth line
      case 'C':
        return 5.5; // C♭ on fifth space
      case 'F':
        return 5.0; // F♭ on fifth line
      default:
        return 0.0;
    }
  }

  /// Get the alto clef sharp line for a note
  static double _getAltoSharpLine(String note) {
    switch (note) {
      case 'F':
        return 1.0; // F♯ on second line
      case 'C':
        return 2.5; // C♯ on third space
      case 'G':
        return 2.0; // G♯ on third line
      case 'D':
        return 3.5; // D♯ on fourth space
      case 'A':
        return 3.0; // A♯ on fourth line
      case 'E':
        return 4.5; // E♯ on fifth space
      case 'B':
        return 4.0; // B♯ on fifth line
      default:
        return 0.0;
    }
  }

  /// Get the alto clef flat line for a note
  static double _getAltoFlatLine(String note) {
    switch (note) {
      case 'B':
        return 1.0; // B♭ on second line
      case 'E':
        return 2.5; // E♭ on third space
      case 'A':
        return 2.0; // A♭ on third line
      case 'D':
        return 3.5; // D♭ on fourth space
      case 'G':
        return 3.0; // G♭ on fourth line
      case 'C':
        return 4.5; // C♭ on fifth space
      case 'F':
        return 4.0; // F♭ on fifth line
      default:
        return 0.0;
    }
  }

  /// Get the tenor clef sharp line for a note
  static double _getTenorSharpLine(String note) {
    switch (note) {
      case 'F':
        return 1.5; // F♯ on second space
      case 'C':
        return 2.0; // C♯ on third line
      case 'G':
        return 2.5; // G♯ on third space
      case 'D':
        return 3.0; // D♯ on fourth line
      case 'A':
        return 3.5; // A♯ on fourth space
      case 'E':
        return 4.0; // E♯ on fifth line
      case 'B':
        return 4.5; // B♯ on fifth space
      default:
        return 0.0;
    }
  }

  /// Get the tenor clef flat line for a note
  static double _getTenorFlatLine(String note) {
    switch (note) {
      case 'B':
        return 1.5; // B♭ on second space
      case 'E':
        return 2.0; // E♭ on third line
      case 'A':
        return 2.5; // A♭ on third space
      case 'D':
        return 3.0; // D♭ on fourth line
      case 'G':
        return 3.5; // G♭ on fourth space
      case 'C':
        return 4.0; // C♭ on fifth line
      case 'F':
        return 4.5; // F♭ on fifth space
      default:
        return 0.0;
    }
  }

  /// Get the line position for a sharp in the given clef
  static double _getSharpLine(String note, Clef clef) {
    switch (clef) {
      case Clef.treble:
        switch (note) {
          case 'F':
            return 0.0; // F♯ on top line
          case 'C':
            return 1.5; // C♯ on 3rd space
          case 'G':
            return 1.0; // G♯ on 2nd line
          case 'D':
            return 3.5; // D♯ on 4th space
          case 'A':
            return 0.0; // A♯ on 1st line
          case 'E':
            return 1.5; // E♯ on 3rd space
          case 'B':
            return 1.0; // B♯ on 2nd line
          default:
            return 0.0;
        }
      case Clef.bass:
        switch (note) {
          case 'F':
            return 2.0; // F♯ on middle line
          case 'C':
            return 2.0; // C♯ on middle line
          case 'G':
            return 2.0; // G♯ on middle line
          case 'D':
            return 2.0; // D♯ on middle line
          case 'A':
            return 2.0; // A♯ on middle line
          case 'E':
            return 2.0; // E♯ on middle line
          case 'B':
            return 2.0; // B♯ on middle line
          default:
            return 0.0;
        }
      case Clef.alto:
        switch (note) {
          case 'F':
            return 1.0; // F♯ on 2nd line
          case 'C':
            return 2.5; // C♯ on 3rd space
          case 'G':
            return 2.0; // G♯ on 3rd line
          case 'D':
            return 3.5; // D♯ on 4th space
          case 'A':
            return 3.0; // A♯ on 4th line
          case 'E':
            return 4.5; // E♯ below staff
          case 'B':
            return 4.0; // B♯ on bottom line
          default:
            return 0.0;
        }
      case Clef.tenor:
        switch (note) {
          case 'F':
            return 1.5; // F♯ on 2nd space
          case 'C':
            return 2.0; // C♯ on 3rd line
          case 'G':
            return 2.5; // G♯ on 3rd space
          case 'D':
            return 3.0; // D♯ on 4th line
          case 'A':
            return 3.5; // A♯ on 4th space
          case 'E':
            return 4.0; // E♯ on bottom line
          case 'B':
            return 4.5; // B♯ below staff
          default:
            return 0.0;
        }
    }
  }

  /// Get the line position for a flat in the given clef
  static double _getFlatLine(String note, Clef clef) {
    switch (clef) {
      case Clef.treble:
        switch (note) {
          case 'B':
            return 2.0; // B♭ on 3rd line
          case 'E':
            return 3.5; // E♭ on 4th space
          case 'A':
            return 1.0; // A♭ on 2nd line
          case 'D':
            return 2.5; // D♭ on 3rd space
          case 'G':
            return 0.0; // G♭ on 1st line
          case 'C':
            return 3.5; // C♭ on 4th space
          case 'F':
            return 1.0; // F♭ on 2nd line
          default:
            return 0.0;
        }
      case Clef.bass:
        switch (note) {
          case 'B':
            return 2.0; // B♭ on middle line
          case 'E':
            return 2.0; // E♭ on middle line
          case 'A':
            return 2.0; // A♭ on middle line
          case 'D':
            return 2.0; // D♭ on middle line
          case 'G':
            return 2.0; // G♭ on middle line
          case 'C':
            return 2.0; // C♭ on middle line
          case 'F':
            return 2.0; // F♭ on middle line
          default:
            return 0.0;
        }
      case Clef.alto:
        switch (note) {
          case 'B':
            return 3.0; // B♭ on 4th line
          case 'E':
            return 3.5; // E♭ on 4th space
          case 'A':
            return 2.0; // A♭ on 3rd line
          case 'D':
            return 2.5; // D♭ on 3rd space
          case 'G':
            return 1.0; // G♭ on 2nd line
          case 'C':
            return 1.5; // C♭ on 2nd space
          case 'F':
            return 0.0; // F♭ on 1st line
          default:
            return 0.0;
        }
      case Clef.tenor:
        switch (note) {
          case 'B':
            return 3.5; // B♭ on 4th space
          case 'E':
            return 4.0; // E♭ on bottom line
          case 'A':
            return 3.0; // A♭ on 4th line
          case 'D':
            return 3.5; // D♭ on 4th space
          case 'G':
            return 2.0; // G♭ on 3rd line
          case 'C':
            return 2.5; // C♭ on 3rd space
          case 'F':
            return 1.0; // F♭ on 2nd line
          default:
            return 0.0;
        }
    }
  }
}

/// Simple point class for positioning
class Point {
  final double x;
  final double y;
  final String note;

  const Point(this.x, this.y, {this.note = ''});
}
