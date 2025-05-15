import 'dart:math';
import 'clef.dart';
import 'note.dart';

/// Staff model responsible for positioning notes on a staff
/// Follows MuseScore's approach where:
/// - Notes have a "line" property that determines their vertical position
/// - Integer values are lines, half-integers are spaces
/// - Lines are numbered 0-4 from top to bottom of staff
class StaffModel {
  final Clef clef;

  // Define the reference positions for each clef as a map
  // Key is the MIDI pitch and value is the staff line position
  // Standard traditional staff notation

  // Special mapping for enharmonic notes
  // Maps MIDI pitch to staff line positions based on accidental type
  // This allows D# and Eb (both MIDI 63) to be drawn at different positions
  static const Map<int, Map<AccidentalType, double>> _enharmonicPositions = {
    // MIDI 40: C#2/Db2
    37: {
      AccidentalType.sharp: 6.5, // C#4 - same line as C4
      AccidentalType.flat: 6.0, // Db4 - same line as D4
    },
    // MIDI 40: C#2/Db2
    39: {
      AccidentalType.sharp: 6.0, // D#2 - same line as C4
      AccidentalType.flat: 5.5, // Eb2 - same line as D4
    },
    // MIDI 42: F#2/Gb2
    42: {
      AccidentalType.sharp: 5.0, // C#4 - same line as C4
      AccidentalType.flat: 4.5, // Db4 - same line as D4
    },
    // MIDI 44: G#2/Ab2
    44: {
      AccidentalType.sharp: 4.5, // C#4 - same line as C4
      AccidentalType.flat: 4.0, // Db4 - same line as D4
    },
    // MIDI 46: A#2/Bb2
    46: {
      AccidentalType.sharp: 4.0, // C#4 - same line as C4
      AccidentalType.flat: 3.5, // Db4 - same line as D4
    },
    // MIDI 49: C#3/Db3
    49: {
      AccidentalType.sharp: 3.0, // C#4 - same line as C4
      AccidentalType.flat: 2.5, // Db4 - same line as D4
    },
    // MIDI 51: D#3/Eb3
    51: {
      AccidentalType.sharp: 2.5, // C#4 - same line as C4
      AccidentalType.flat: 2.0, // Db4 - same line as D4
    },
    // MIDI 54: F#3/Gb3
    54: {
      AccidentalType.sharp: 1.5, // C#4 - same line as C4
      AccidentalType.flat: 1.0, // Db4 - same line as D4
    },
    // MIDI 56: G#3/Ab3
    56: {
      AccidentalType.sharp: 1.0, // C#4 - same line as C4
      AccidentalType.flat: 0.5, // Db4 - same line as D4
    },
    // MIDI 58: A#3/Bb3
    58: {
      AccidentalType.sharp: 0.5, // C#4 - same line as C4
      AccidentalType.flat: 0.0, // Db4 - same line as D4
    },
    // MIDI 61: C#4/Db4
    61: {
      AccidentalType.sharp: 5.5, // C#4 - same line as C4
      AccidentalType.flat: 5.0, // Db4 - same line as D4
    },
    // MIDI 63: D#4/Eb4
    63: {
      AccidentalType.sharp: 5.0, // D#4 - same line as D4
      AccidentalType.flat: 4.5, // Eb4 - same line as E4
    },
    // MIDI 66: F#4/Gb4
    66: {
      AccidentalType.sharp: 4.0, // F#4 - same space as F4
      AccidentalType.flat: 3.5, // Gb4 - same line as G4
    },
    // MIDI 68: G#4/Ab4
    68: {
      AccidentalType.sharp: 3.5, // G#4 - same line as G4
      AccidentalType.flat: 3.0, // Ab4 - same space as A4
    },
    // MIDI 70: A#4/Bb4
    70: {
      AccidentalType.sharp: 3.0, // A#4 - same space as A4
      AccidentalType.flat: 2.5, // Bb4 - same line as B4
    },
    // MIDI 73: C#5/Db5
    73: {
      AccidentalType.sharp: 2.0, // C#5 - same space as C5
      AccidentalType.flat: 1.5, // Db5 - same line as D5
    },
    // MIDI 75: D#5/Eb5
    75: {
      AccidentalType.sharp: 1.5, // D#5 - same line as D5
      AccidentalType.flat: 1.0, // Eb5 - same space as E5
    },
    // MIDI 78: F#5/Gb5
    78: {
      AccidentalType.sharp: 0.5, // F#5 - same line as F5
      AccidentalType.flat: 0.0, // Gb5 - same space as G5
    },
    // MIDI 80: G#5/Ab5
    80: {
      AccidentalType.sharp: 0.0, // G#5 - same space as G5
      AccidentalType.flat: -0.5, // Ab5 - same line as A5
    },
    // MIDI 82: A#5/Bb5
    82: {
      AccidentalType.sharp: -0.5, // A#5 - same line as A5
      AccidentalType.flat: -1.0, // Bb5 - same space as B5
    },
  };

  StaffModel({required this.clef});

  /// Calculate the staff line value for a note based on MIDI pitch and clef
  double calculateStaffLine(int midiPitch, {AccidentalType? accidentalType}) {
    print(
        'Staff Model: Calculating staff line for MIDI $midiPitch, accidental ${accidentalType}');

    // Handle enharmonic notes first
    if (accidentalType != null &&
        accidentalType != AccidentalType.none &&
        _enharmonicPositions.containsKey(midiPitch) &&
        _enharmonicPositions[midiPitch]!.containsKey(accidentalType)) {
      final position = _enharmonicPositions[midiPitch]![accidentalType]!;
      print(
          'Staff Model: Using enharmonic position $position for MIDI $midiPitch with accidental $accidentalType');
      return position;
    }

    // Select the reference position map based on the clef
    final Map<int, double> refPositions;
    switch (clef) {
      case Clef.treble:
        refPositions = _trebleRefPositions;
        print('Staff Model: Using treble clef reference positions');
        break;
      case Clef.bass:
        refPositions = _bassRefPositions;
        print('Staff Model: Using bass clef reference positions');
        break;
      case Clef.alto:
      case Clef.tenor:
        // Simplified for alto and tenor clefs
        refPositions = {60: 0.0}; // C4 on middle line for alto
        break;
    }

    // Check if we have an exact match in our reference positions
    if (refPositions.containsKey(midiPitch)) {
      final position = refPositions[midiPitch]!;
      print(
          'Staff Model: Using exact reference position $position for MIDI $midiPitch');
      return position;
    }

    // Find the closest reference pitches above and below our target pitch
    int? lowerPitch;
    int? higherPitch;
    double? lowerLine;
    double? higherLine;

    for (final entry in refPositions.entries) {
      if (entry.key < midiPitch &&
          (lowerPitch == null || entry.key > lowerPitch)) {
        lowerPitch = entry.key;
        lowerLine = entry.value;
      }
      if (entry.key > midiPitch &&
          (higherPitch == null || entry.key < higherPitch)) {
        higherPitch = entry.key;
        higherLine = entry.value;
      }
    }

    double staffLine;
    // Interpolate between known positions
    if (lowerPitch != null && higherPitch != null) {
      // Calculate how many staff positions per semitone
      double semitones = (higherPitch - lowerPitch).toDouble();
      double staffPositions = (lowerLine! - higherLine!)
          .abs(); // Staff positions decrease as pitch increases
      double staffPerSemitone = staffPositions / semitones;

      // Calculate the staff line
      int semitoneDistance = midiPitch - lowerPitch;
      staffLine = lowerLine - (semitoneDistance * staffPerSemitone);
      print(
          'Staff Model: Interpolated between MIDI $lowerPitch (${lowerLine}) and MIDI $higherPitch (${higherLine})');
      print(
          'Staff Model: Semitone distance: $semitoneDistance, staff per semitone: $staffPerSemitone');
    } else if (lowerPitch != null) {
      // Extrapolate downward (higher staff line values for lower pitches)
      int semitoneDistance = lowerPitch - midiPitch;
      double staffPositionChange =
          semitoneDistance * (0.5); // Each semitone is 0.5 staff positions
      staffLine = lowerLine! + staffPositionChange;
      print('Staff Model: Extrapolated below MIDI $lowerPitch (${lowerLine})');
      print(
          'Staff Model: Semitone distance: $semitoneDistance, using 0.5 positions per semitone');
    } else if (higherPitch != null) {
      // Extrapolate upward (lower staff line values for higher pitches)
      int semitoneDistance = midiPitch - higherPitch;
      double staffPositionChange =
          semitoneDistance * (0.5); // Each semitone is 0.5 staff positions
      staffLine = higherLine! - staffPositionChange;
      print(
          'Staff Model: Extrapolated above MIDI $higherPitch (${higherLine})');
      print(
          'Staff Model: Semitone distance: $semitoneDistance, using 0.5 positions per semitone');
    } else {
      // Fallback - This should not happen with our reference data
      staffLine = 0.0;
      print('Staff Model: No reference data found! Using default position 0.0');
    }

    // Apply clef-specific corrections
    if (clef == Clef.bass) {
      // For bass clef, ensure notes are properly positioned relative to G2 (MIDI 43)
      if (midiPitch < 43) {
        // Below G2 - adjust based on distance from G2
        staffLine = staffLine + 1.0;
      } else if (midiPitch > 53) {
        // Above F3 - adjust based on distance from F3
        staffLine = staffLine - 1.0;
      }
    } else if (clef == Clef.treble) {
      // For treble clef, ensure notes are properly positioned relative to E4 (MIDI 64)
      if (midiPitch < 64) {
        // Below E4 - adjust based on distance from E4
        staffLine = staffLine + 1.0;
      } else if (midiPitch > 77) {
        // Above F5 - adjust based on distance from F5
        staffLine = staffLine - 1.0;
      }
    }

    print('Staff Model: Calculated Staff Line: $staffLine');
    return staffLine;
  }

  /// Position a note on the staff according to MuseScore's conventions
  Note positionNote(Note note) {
    double staffLine =
        calculateStaffLine(note.midiPitch, accidentalType: note.accidentalType);
    return note.copyWithStaffLine(staffLine);
  }

  /// Position multiple notes on the staff
  List<Note> positionNotes(List<Note> notes) {
    return notes.map((note) => positionNote(note)).toList();
  }

  /// Determine if a staff line needs a ledger line
  bool needsLedgerLine(double staffLine) {
    // The 5 staff lines are at positions 0, 1, 2, 3, 4
    // Any note position < 0 (above the staff) or > 4 (below the staff) needs ledger lines
    return staffLine < 0 || staffLine > 4;
  }

  /// Get all ledger line positions needed for a note
  List<double> getLedgerLines(double staffLine) {
    List<double> ledgerLines = [];

    // For notes above the staff (staff line values less than 0)
    if (staffLine < 0) {
      // For A5 (staffLine = -0.5), add ledger line at -1
      if (staffLine == -1.0 || staffLine == -0.5) {
        ledgerLines.add(-1.0);
      }
      // For C6 (staffLine = -1.5), add ledger lines at -1 and -3
      else if (staffLine >= -1.5) {
        ledgerLines.add(-1.0);
        ledgerLines.add(-2.0);
      }
      // For higher notes, add all ledger lines up to the note
      else {
        for (int line = -1; line >= staffLine.floor(); line -= 2) {
          ledgerLines.add(line.toDouble());
        }
      }
    }

    // For notes below the staff (staff line values greater than 4)
    if (staffLine >= 5.5) {
      // For E2 (staffLine = 5.5), add ledger line at 5
      if (staffLine == 5.5 || staffLine == 6.0) {
        ledgerLines.add(5.0);
      }
      // For C2 (staffLine = 6.5), add ledger lines at 5 and 7
      else if (staffLine == 6.5) {
        ledgerLines.add(5.0);
        ledgerLines.add(6.0);
      }
      // For lower notes, add all ledger lines up to the note
      else {
        for (int line = 5; line <= staffLine.ceil(); line += 2) {
          ledgerLines.add(line.toDouble());
        }
      }
    }

    return ledgerLines;
  }
}

const Map<int, double> _trebleRefPositions = {
  // From low to high
  60: 5.5, // C4 (middle C) is 1st ledger line below staff
  62: 5.0, // D4 is below staff
  64: 4.5, // E4 is bottom line of staff
  65: 4.0, // F4 is space above bottom line
  67: 3.5, // G4 is second line from bottom
  69: 3.0, // A4 is second space from bottom
  71: 2.5, // B4 is middle line
  72: 2.0, // C5 is space above middle line
  74: 1.5, // D5 is fourth line from bottom
  76: 1.0, // E5 is top space
  77: 0.5, // F5 is top line
  79: 0.0, // G5 is space above staff
  81: -0.5, // A5 is 1st ledger line above staff
  83: -1.0, // B5 is 1st space above 1st ledger
  84: -1.5, // C6 is 2nd ledger line above staff
};

const Map<int, double> _bassRefPositions = {
  // From low to high
  36: 6.5, // C2 is 2nd ledger line below staff
  38: 6.0, // D2 is 1st ledger line below staff
  40: 5.5, // E2 is bottom line of staff
  41: 5.0, // F2 is space above bottom line
  43: 4.5, // G2 is bottom line from bottom
  45: 4.0, // A2 is second space from bottom
  47: 3.5, // B2 is middle line
  48: 3.0, // C3 is space above middle line
  50: 2.5, // D3 is middle line
  52: 2.0, // E3 is second top space
  53: 1.5, // F3 is second top line
  55: 1.0, // G3 is top space
  57: 0.5, // A3 is top line
  59: 0.0, // B3 is space above staff
  60: -0.5, // C4 (middle C) is 1st ledger line above staff
};
