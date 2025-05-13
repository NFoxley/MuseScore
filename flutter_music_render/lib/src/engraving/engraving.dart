/// Engraving module for music notation
///
/// This module is responsible for handling the placement and rendering of musical
/// elements according to standard music notation rules. It follows the architecture
/// found in MuseScore's engraving system.
library engraving;

import 'dart:math';
import 'package:flutter/material.dart';
import 'clef.dart';
import 'key_signature.dart';
import 'note.dart';
import 'time_signature.dart';

/// The basic unit of measurement in music notation
///
/// In traditional music engraving, the spatium is the distance between two staff lines.
/// All positioning and sizing calculations are made relative to this value.
class Spatium {
  final double value;

  const Spatium(this.value);

  double operator *(double multiplier) => value * multiplier;

  Spatium operator +(Spatium other) => Spatium(value + other.value);
  Spatium operator -(Spatium other) => Spatium(value - other.value);
}

/// Represents a point in a music score, using spatium units
class SpPoint {
  final double x;
  final double y;

  const SpPoint(this.x, this.y);

  Point<double> toPoint(double spatium) => Point(x * spatium, y * spatium);
  Offset toOffset(double spatium) => Offset(x * spatium, y * spatium);
}

/// A class that manages the style parameters for music notation
class EngravingStyle {
  // Margins and distances
  static const double staffLineThickness = 0.08; // Thickness of staff lines
  static const double staffLineSpacing = 1.0; // Space between staff lines
  static const double staffMargin = 2.0; // Margin around staff
  static const double clefMargin = 1.0; // Margin after clef
  static const double keysigMargin = 0.5; // Margin after key signature
  static const double timesigMargin = 5.0; // Margin after time signature
  static const double barlineMargin = 0.5; // Margin after barline
  static const double noteSpacing = 1.0; // Base spacing between notes
  static const double keysigAccidentalDistance =
      0.8; // Distance between key signature accidentals
  static const double stemLength = 3.5; // Length of note stems
  static const double beamSpacing = 0.25; // Space between beams
  static const double ledgerLineThickness = 0.1; // Thickness of ledger lines
  static const double ledgerLineLength = 0.4; // Length of ledger lines
  static const double accidentalDistance =
      0.5; // Distance between note and accidental
  static const double accidentalNoteDistance =
      0.5; // Distance between accidental and note
  static const double dotDistance = 0.3; // Distance between note and dot
  static const double graceNoteScale = 0.7; // Scale factor for grace notes
  static const double tupletBracketDistance =
      0.5; // Distance between tuplet bracket and notes
  static const double tupletNumberDistance =
      0.3; // Distance between tuplet number and bracket
  static const double slurDistance = 0.5; // Distance between slur and notes
  static const double tieDistance = 0.3; // Distance between tie and notes
  static const double dynamicDistance =
      1.0; // Distance between dynamic and staff
  static const double lyricDistance = 1.5; // Distance between lyrics and staff
  static const double fingeringDistance =
      0.5; // Distance between fingering and note
  static const double articulationDistance =
      0.5; // Distance between articulation and note
  static const double ornamentDistance =
      0.5; // Distance between ornament and note
  static const double glissandoDistance =
      0.5; // Distance between glissando and notes
  static const double bendDistance = 0.5; // Distance between bend and notes
  static const double tremoloDistance =
      0.3; // Distance between tremolo and notes
  static const double repeatDotDistance =
      0.3; // Distance between repeat dots and barline
  static const double voltaDistance = 1.0; // Distance between volta and staff
  static const double ottavaDistance = 1.0; // Distance between ottava and staff
  static const double pedalDistance = 1.0; // Distance between pedal and staff
  static const double hairpinDistance =
      1.0; // Distance between hairpin and staff
  static const double trillDistance = 0.5; // Distance between trill and note
  static const double turnDistance = 0.5; // Distance between turn and note
  static const double mordentDistance =
      0.5; // Distance between mordent and note
  static const double arpeggioDistance =
      0.5; // Distance between arpeggio and notes
  static const double fermataDistance =
      0.5; // Distance between fermata and note
  static const double breathDistance = 0.5; // Distance between breath and note
  static const double caesuraDistance =
      0.5; // Distance between caesura and note
  static const double repeatBarlineDistance =
      0.5; // Distance between repeat barline and notes
  static const double codaDistance = 1.0; // Distance between coda and staff
  static const double segnoDistance = 1.0; // Distance between segno and staff
  static const double dacapoDistance = 1.0; // Distance between dacapo and staff
  static const double dalSegnoDistance =
      1.0; // Distance between dal segno and staff
  static const double fineDistance = 1.0; // Distance between fine and staff
  static const double toCodaDistance =
      1.0; // Distance between to coda and staff
  static const double dacapoAlFineDistance =
      1.0; // Distance between dacapo al fine and staff
  static const double dalSegnoAlFineDistance =
      1.0; // Distance between dal segno al fine and staff
  static const double dalSegnoAlCodaDistance =
      1.0; // Distance between dal segno al coda and staff
  static const double dacapoAlCodaDistance =
      1.0; // Distance between dacapo al coda and staff

  // Clef positions (MuseScore values)
  static const Map<Clef, double> clefYPositions = {
    Clef.treble: 0.6, // G clef centered on first line (was 2.0)
    Clef.bass: -1.5, // F clef centered on third line from bottom (was 0.0)
    Clef.alto: 1.75, // C clef centered slightly above C line (was 2.75)
    Clef.tenor: 1.75, // C clef centered slightly above C line (was 2.75)
  };

  // Key signature positions
  static const Map<Clef, double> keysigYPositions = {
    Clef.treble: 2.0, // Aligned with treble clef
    Clef.bass: 3.0, // Aligned with bass clef
    Clef.alto: 3.0, // Aligned with alto clef
    Clef.tenor: 3.0, // Aligned with tenor clef
  };

  // Time signature positions
  static const Map<Clef, double> timesigYPositions = {
    Clef.treble: 2.0, // Middle line of staff
    Clef.bass: 2.0, // Middle line of staff
    Clef.alto: 2.0, // Middle line of staff
    Clef.tenor: 2.0, // Middle line of staff
  };

  // Note positions
  static const Map<Clef, double> noteYPositions = {
    Clef.treble: 2.0, // Middle line of staff
    Clef.bass: 2.0, // Middle line of staff
    Clef.alto: 2.0, // Middle line of staff
    Clef.tenor: 2.0, // Middle line of staff
  };

  // Clef pitch offsets (MuseScore values)
  static const Map<Clef, int> clefPitchOffsets = {
    Clef.treble: 67, // G4 (MIDI 67) is on line 1
    Clef.bass: 53, // F3 (MIDI 53) is on line 4
    Clef.alto: 60, // C4 (MIDI 60) is on line 3
    Clef.tenor: 60, // C4 (MIDI 60) is on line 3
  };

  // Pitch steps (MuseScore values)
  static const Map<int, int> pitchSteps = {
    0: 0, // C
    1: 0, // C#
    2: 1, // D
    3: 1, // D#
    4: 2, // E
    5: 3, // F
    6: 3, // F#
    7: 4, // G
    8: 4, // G#
    9: 5, // A
    10: 5, // A#
    11: 6, // B
  };

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
        return isSharp ? getTrebleSharpLine(note) : getTrebleFlatLine(note);
      case Clef.bass:
        return isSharp ? getBassSharpLine(note) : getBassFlatLine(note);
      case Clef.alto:
        return isSharp ? _getAltoSharpLine(note) : _getAltoFlatLine(note);
      case Clef.tenor:
        return isSharp ? _getTenorSharpLine(note) : _getTenorFlatLine(note);
    }
  }

  /// Get the treble clef sharp line for a note
  static double getTrebleSharpLine(String note) {
    switch (note) {
      case 'F':
        return 1.5; // F♯ on top line
      case 'C':
        return 3.0; // C♯ on 3rd space
      case 'G':
        return 1.0; // G♯ on 4th line
      case 'D':
        return 2.5; // D♯ on 3rd line
      case 'A':
        return 4.0; // A♯ on 2nd line
      case 'E':
        return 2.0; // E♯ on 4th line
      case 'B':
        return 3.5; // B♯ on 3rd line
      default:
        return 0.0;
    }
  }

  /// Get the treble clef flat line for a note
  static double getTrebleFlatLine(String note) {
    switch (note) {
      case 'B':
        return 3.5; // B♭ on 3rd line
      case 'E':
        return 2.0; // E♭ on 4th line
      case 'A':
        return 4.0; // A♭ on 3rd line
      case 'D':
        return 2.5; // D♭ on 4th line
      case 'G':
        return 4.5; // G♭ on 3rd line
      case 'C':
        return 3.0; // C♭ on 4th line
      case 'F':
        return 5.0; // F♭ on 3rd line
      default:
        return 0.0;
    }
  }

  /// Get the bass clef sharp line for a note
  static double getBassSharpLine(String note) {
    switch (note) {
      case 'F':
        return 2.5; // F♯ on 1st line
      case 'C':
        return 4.0; // C♯ on 2nd line
      case 'G':
        return 2.0; // G♯ on 3rd line
      case 'D':
        return 3.5; // D♯ on 4th line
      case 'A':
        return 5.0; // A♯ on 1st line
      case 'E':
        return 3.0; // E♯ on 2nd line
      case 'B':
        return 4.5; // B♯ on 3rd line
      default:
        return 0.0;
    }
  }

  /// Get the bass clef flat line for a note
  static double getBassFlatLine(String note) {
    switch (note) {
      case 'B':
        return 4.5; // B♭ on 1st line
      case 'E':
        return 3.0; // E♭ on 2nd line
      case 'A':
        return 5.0; // A♭ on 3rd line
      case 'D':
        return 3.5; // D♭ on 4th line
      case 'G':
        return 5.5; // G♭ on 1st line
      case 'C':
        return 4.0; // C♭ on 2nd line
      case 'F':
        return 6.0; // F♭ on 3rd line
      default:
        return 0.0;
    }
  }

  /// Get the alto clef sharp line for a note
  static double _getAltoSharpLine(String note) {
    switch (note) {
      case 'F':
        return 2.5; // 2nd space
      case 'C':
        return 1.5; // 1st space
      case 'G':
        return 3.5; // 3rd space
      case 'D':
        return 2.5; // 2nd space
      case 'A':
        return 1.5; // 1st space
      case 'E':
        return 3.5; // 3rd space
      case 'B':
        return 2.5; // 2nd space
      default:
        return 0.0;
    }
  }

  /// Get the alto clef flat line for a note
  static double _getAltoFlatLine(String note) {
    switch (note) {
      case 'B':
        return 2.0; // 2nd line
      case 'E':
        return 3.0; // 3rd line
      case 'A':
        return 2.0; // 2nd line
      case 'D':
        return 3.0; // 3rd line
      case 'G':
        return 2.0; // 2nd line
      case 'C':
        return 3.0; // 3rd line
      case 'F':
        return 2.0; // 2nd line
      default:
        return 0.0;
    }
  }

  /// Get the tenor clef sharp line for a note
  static double _getTenorSharpLine(String note) {
    switch (note) {
      case 'F':
        return 1.5; // 1st space
      case 'C':
        return 0.5; // middle line
      case 'G':
        return 2.5; // 2nd space
      case 'D':
        return 1.5; // 1st space
      case 'A':
        return 0.5; // middle line
      case 'E':
        return 2.5; // 2nd space
      case 'B':
        return 1.5; // 1st space
      default:
        return 0.0;
    }
  }

  /// Get the tenor clef flat line for a note
  static double _getTenorFlatLine(String note) {
    switch (note) {
      case 'B':
        return 1.0; // 1st line
      case 'E':
        return 2.0; // 2nd line
      case 'A':
        return 1.0; // 1st line
      case 'D':
        return 2.0; // 2nd line
      case 'G':
        return 1.0; // 1st line
      case 'C':
        return 2.0; // 2nd line
      case 'F':
        return 1.0; // 1st line
      default:
        return 0.0;
    }
  }
}

/// A class that provides utility functions for engraving calculations
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

  /// Calculate staff line for a MIDI pitch based on clef
  static int calculateStaffLine(int midiPitch, Clef clef) {
    final pitchOffset = EngravingStyle.clefPitchOffsets[clef]!;

    // In MuseScore, line = pitchOffset - absStep
    // where absStep = pitch / 12 * 7 + step
    final octave = (midiPitch / 12).floor();
    final step = midiPitch % 12;
    final absStep = octave * 7 + (EngravingStyle.pitchSteps[step] ?? 0);

    // Convert to staff-relative position
    final staffRelativeLine = pitchOffset - absStep;

    // Convert to line position (0-4 for the 5 lines of the staff)
    // For treble clef, middle C (60) should be on the first ledger line below the staff
    // For bass clef, middle C (60) should be on the first ledger line above the staff
    final lineAdjustment = clef == Clef.treble ? 4 : -2;

    // Convert to staff-relative position (0-4 for the 5 lines of the staff)
    return staffRelativeLine - lineAdjustment;
  }

  /// Get the symbol positions for key signature accidentals
  static List<SpPoint> getKeySignaturePositions(
      KeySignature keySignature, Clef clef) {
    final List<SpPoint> positions = [];

    // Get the line positions based on clef and key signature
    final isSharp = keySignature.isSharp;
    final count = keySignature.accidentalCount();

    // Use the correct order from KeySignature class
    final order = isSharp ? KeySignature.sharpOrder : KeySignature.flatOrder;
    print('Key signature order: $order');

    double xOffset = 0.0;

    // Use the order directly - no need to reverse for flats as flatOrder is already correct
    final notes = order.sublist(0, count);
    print('Processing notes in order: $notes');

    for (final note in notes) {
      print('Processing note: $note');
      final linePosition = isSharp
          ? (clef == Clef.treble
              ? EngravingStyle.getTrebleSharpLine(note)
              : EngravingStyle.getBassSharpLine(note))
          : (clef == Clef.treble
              ? EngravingStyle.getTrebleFlatLine(note)
              : EngravingStyle.getBassFlatLine(note));
      print('Line position for $note: $linePosition');

      // Add position for this accidental
      positions.add(SpPoint(xOffset, linePosition));

      // Update x position for next accidental
      xOffset += EngravingStyle.keysigAccidentalDistance;
    }

    return positions;
  }
}
