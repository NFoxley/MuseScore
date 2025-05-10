import 'clef.dart';
import 'key_signature.dart';

/// Utility class for engraving calculations
class EngravingUtils {
  /// Get the accidental symbol for a given accidental
  static String getAccidentalSymbol(String accidental) {
    switch (accidental) {
      case '♯':
        return '♯';
      case '♭':
        return '♭';
      case '♮':
        return '♮';
      case '𝄪':
        return '𝄪';
      case '𝄫':
        return '𝄫';
      default:
        return accidental;
    }
  }

  /// Get the key signature positions for a given key signature and clef
  static List<KeySignaturePosition> getKeySignaturePositions(
      KeySignature keySignature, Clef clef) {
    final positions = <KeySignaturePosition>[];
    final isSharp = keySignature.isSharp;
    final order = isSharp ? KeySignature.sharpOrder : KeySignature.flatOrder;

    for (int i = 0; i < keySignature.accidentals; i++) {
      final note = order[i];
      final line = _getKeySignatureLine(note, clef, isSharp);
      positions.add(KeySignaturePosition(note, line));
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
        return isSharp ? _getTrebleSharpLine(note) : _getTrebleFlatLine(note);
      case Clef.tenor:
        return isSharp ? _getTrebleSharpLine(note) : _getTrebleFlatLine(note);
    }
  }

  /// Get the treble clef sharp line for a note
  static double _getTrebleSharpLine(String note) {
    switch (note) {
      case 'F':
        return 3.5; // 3rd space
      case 'C':
        return 2.5; // 2nd space
      case 'G':
        return 4.5; // 4th space
      case 'D':
        return 3.5; // 3rd space
      case 'A':
        return 2.5; // 2nd space
      case 'E':
        return 4.5; // 4th space
      case 'B':
        return 3.5; // 3rd space
      default:
        return 0.0;
    }
  }

  /// Get the treble clef flat line for a note
  static double _getTrebleFlatLine(String note) {
    switch (note) {
      case 'B':
        return 3.0; // 3rd line
      case 'E':
        return 4.0; // 4th line
      case 'A':
        return 3.0; // 3rd line
      case 'D':
        return 4.0; // 4th line
      case 'G':
        return 3.0; // 3rd line
      case 'C':
        return 4.0; // 4th line
      case 'F':
        return 3.0; // 3rd line
      default:
        return 0.0;
    }
  }

  /// Get the bass clef sharp line for a note
  static double _getBassSharpLine(String note) {
    switch (note) {
      case 'F':
        return 1.0; // F3 (1st space)
      case 'C':
        return 2.0; // C3 (middle line)
      case 'G':
        return 3.0; // G3 (2nd space)
      case 'D':
        return 4.0; // D3 (1st space)
      case 'A':
        return 5.0; // A2 (middle line)
      case 'E':
        return 6.0; // E3 (2nd space)
      case 'B':
        return 7.0; // B2 (1st space)
      default:
        return 0.0;
    }
  }

  /// Get the bass clef flat line for a note
  static double _getBassFlatLine(String note) {
    switch (note) {
      case 'B':
        return 1.0; // B♭2 (1st line)
      case 'E':
        return 2.0; // E♭3 (2nd line)
      case 'A':
        return 3.0; // A♭2 (1st line)
      case 'D':
        return 4.0; // D♭3 (2nd line)
      case 'G':
        return 5.0; // G♭2 (1st line)
      case 'C':
        return 6.0; // C♭3 (2nd line)
      case 'F':
        return 7.0; // F♭2 (1st line)
      default:
        return 0.0;
    }
  }
}

/// Represents a position in a key signature
class KeySignaturePosition {
  final String note;
  final double y;

  const KeySignaturePosition(this.note, this.y);
}
