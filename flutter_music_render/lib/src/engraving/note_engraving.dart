/// Note engraving module for music notation
///
/// This module is responsible for handling the placement and rendering of notes
/// according to standard music notation rules.
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';

import 'note.dart';
import 'clef.dart';
import 'key_signature.dart';
import 'engraving.dart';

/// Represents a symbol used in music notation
class MusicSymbol {
  final String symbol;
  final SpPoint position;
  final double size;

  const MusicSymbol({
    required this.symbol,
    required this.position,
    required this.size,
  });

  void draw(Canvas canvas, double spatium, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: style.copyWith(
          fontSize: size * spatium,
          fontFamily: 'Bravura',
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    final offset = position.toOffset(spatium);
    print(
        'Drawing symbol $symbol at position $offset with size ${size * spatium}');
    painter.paint(canvas, offset);
  }
}

/// Note engraving module for music notation
class NoteEngraving {
  /// Calculate the staff line position for a note based on clef
  static double calculateStaffLine(Note note, Clef clef) {
    print('Calculating staff line for MIDI ${note.midiPitch} in clef $clef');

    final int midiPitch = note.midiPitch;

    // Select the reference positions based on the clef
    final Map<int, double> refPositions;
    switch (clef) {
      case Clef.treble:
        refPositions = StaffModel._trebleRefPositions;
        break;
      case Clef.bass:
        refPositions = StaffModel._bassRefPositions;
        break;
      case Clef.alto:
        refPositions = StaffModel._altoRefPositions;
        break;
      case Clef.tenor:
        refPositions = StaffModel._tenorRefPositions;
        break;
    }

    // Handle exact matches in the reference positions
    if (refPositions.containsKey(midiPitch)) {
      final position = refPositions[midiPitch]!;
      print('Exact match found: MIDI $midiPitch -> Staff line $position');
      return position;
    }

    // Find the closest reference pitches for interpolation
    final lowerPitch = refPositions.keys.where((p) => p < midiPitch).reduce((a, b) => a > b ? a : b);
    final higherPitch = refPositions.keys.where((p) => p > midiPitch).reduce((a, b) => a < b ? a : b);

    final lowerLine = refPositions[lowerPitch]!;
    final higherLine = refPositions[higherPitch]!;

    // Interpolate the position for the note
    final double stepSize = (higherLine - lowerLine) / (higherPitch - lowerPitch);
    final position = lowerLine + (midiPitch - lowerPitch) * stepSize;
    print('Interpolated position: MIDI $midiPitch -> Staff line $position');
    return position;
  }

  /// Draw ledger lines for a note if needed
  static void drawLedgerLines(
    Canvas canvas,
    double spatium,
    Note note,
    double xPosition,
    Clef clef,
  ) {
    final staffLine = calculateStaffLine(note, clef);
    print('Drawing ledger lines for staff line $staffLine');

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = spatium * 0.1
      ..style = PaintingStyle.stroke;

    // Draw ledger lines above the staff
    if (staffLine > 4.0) {
      print('Drawing ledger lines above the staff');
      for (double line = 4.0; line <= staffLine; line += 2.0) {
        final y = calculateNoteYPosition(line, spatium, 0.0);
        canvas.drawLine(
          Offset(xPosition - spatium * 0.6, y),
          Offset(xPosition + spatium * 0.6, y),
          paint,
        );
      }
    }

    // Draw ledger lines below the staff
    if (staffLine < 0.0) {
      print('Drawing ledger lines below the staff');
      for (double line = 0.0; line >= staffLine; line -= 2.0) {
        final y = calculateNoteYPosition(line, spatium, 0.0);
        canvas.drawLine(
          Offset(xPosition - spatium * 0.6, y),
          Offset(xPosition + spatium * 0.6, y),
          paint,
        );
      }
    }
  }

  /// Calculate the vertical position (y) for a note on the staff
  static double calculateNoteYPosition(
      double staffLine, double spatium, double staffTop) {
    // Convert staff line to y position
    final yPosition = staffTop + (staffLine * spatium);
    print('Note Y position: Staff line $staffLine -> Y position $yPosition');
    return yPosition;
  }

  /// Generate the symbols for a note
  static List<MusicSymbol> generateNoteSymbols(
    Note note,
    Clef clef,
    KeySignature keySignature,
    List<Note> previousNotes,
    double xPosition,
    double spatium,
    double staffTop,
    Canvas canvas,
  ) {
    // Calculate staff line position
    final staffLine = calculateStaffLine(note, clef);

    // Calculate y position based on staff line
    final y = calculateNoteYPosition(staffLine, spatium, staffTop);

    final symbols = <MusicSymbol>[];

    // Draw note using Bravura font
    String noteSymbol;
    switch (note.duration) {
      case NoteDuration.whole:
        noteSymbol = '\uE1D2'; // Bravura whole note
        break;
      case NoteDuration.half:
        noteSymbol = '\uE1D3'; // Bravura half note
        break;
      case NoteDuration.quarter:
        noteSymbol = '\uE1D5'; // Bravura quarter note
        break;
      case NoteDuration.eighth:
        noteSymbol = '\uE1D7'; // Bravura eighth note
        break;
      case NoteDuration.sixteenth:
        noteSymbol = '\uE1D9'; // Bravura sixteenth note
        break;
      default:
        noteSymbol = '\uE1D5'; // Default to quarter note
    }

    symbols.add(MusicSymbol(
      symbol: noteSymbol,
      position:
          SpPoint(xPosition / spatium, y / spatium), // Convert to spatium units
      size: 1.0, // Base size in spatium units
    ));

    return symbols;
  }
}

class StaffModel {
  static const Map<int, double> _trebleRefPositions = {
    60: 0.0, // Example: Middle C
    62: 1.0, // Example: D
    64: 2.0, // Example: E
    65: 3.0, // Example: F
    67: 4.0, // Example: G
  };

  static const Map<int, double> _bassRefPositions = {
    36: 0.0, // Example: Low C
    38: 1.0, // Example: D
    40: 2.0, // Example: E
    41: 3.0, // Example: F
    43: 4.0, // Example: G
  };

  static const Map<int, double> _altoRefPositions = {
    48: 0.0, // Example: Middle C
    50: 1.0, // Example: D
    52: 2.0, // Example: E
    53: 3.0, // Example: F
    55: 4.0, // Example: G
  };

  static const Map<int, double> _tenorRefPositions = {
    45: 0.0, // Example: Middle C
    47: 1.0, // Example: D
    49: 2.0, // Example: E
    50: 3.0, // Example: F
    52: 4.0, // Example: G
  };

  // Add similar maps for other clefs if needed
}
