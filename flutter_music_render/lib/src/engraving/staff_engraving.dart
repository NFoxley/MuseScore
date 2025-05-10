/// Staff engraving module for music notation
///
/// This module is responsible for handling the placement and rendering of staff
/// elements according to standard music notation rules.
import 'dart:ui';
import 'package:flutter/material.dart';

import 'note.dart';
import 'clef.dart';
import 'key_signature.dart';
import 'time_signature.dart';
import 'engraving.dart';
import 'note_engraving.dart';
import 'staff_model.dart' as staff_model;

/// Class for staff engraving
class StaffEngraving {
  /// Draw a staff with clef, key signature, and time signature
  static void drawStaff(
    Canvas canvas,
    Size size,
    Clef clef,
    KeySignature keySignature,
    TimeSignature? timeSignature, {
    required double spatium,
  }) {
    print('StaffEngraving: Drawing staff with spatium: $spatium');
    final staffHeight = spatium * 4; // 4 spaces between 5 lines
    final staffTop = (size.height - staffHeight) / 2;
    print('StaffEngraving: Staff height: $staffHeight, Staff top: $staffTop');
    print('StaffEngraving: Size: $size');

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = EngravingStyle.staffLineThickness * spatium
      ..style = PaintingStyle.stroke;

    // Draw staff lines (now lines 0-4 from top to bottom)
    for (int i = 0; i < 5; i++) {
      final y = staffTop + i * spatium;
      print('StaffEngraving: Drawing staff line $i at y: $y');
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Debug info - Now correctly labeled for staff lines 0-4
    print('StaffEngraving: Staff lines from top to bottom:');
    print('StaffEngraving: Top line (0): ${staffTop + 0 * spatium}');
    print('StaffEngraving: Second line (1): ${staffTop + 1 * spatium}');
    print('StaffEngraving: Middle line (2): ${staffTop + 2 * spatium}');
    print('StaffEngraving: Fourth line (3): ${staffTop + 3 * spatium}');
    print('StaffEngraving: Bottom line (4): ${staffTop + 4 * spatium}');

    // Draw clef
    final clefStyle = TextStyle(
      fontFamily: 'Bravura',
      fontSize: spatium * 4,
      color: Colors.black,
    );

    final clefSymbol = getClefSymbol(clef);
    print('StaffEngraving: Drawing clef $clef with symbol $clefSymbol');
    final clefTextPainter = TextPainter(
      text: TextSpan(text: clefSymbol, style: clefStyle),
      textDirection: TextDirection.ltr,
    );
    clefTextPainter.layout();

    // Position clef according to MuseScore rules
    final clefX = EngravingStyle.staffMargin * spatium;
    final clefY =
        staffTop + (EngravingStyle.clefYPositions[clef]! - 2.5) * spatium;
    print('StaffEngraving: Positioning clef at ($clefX, $clefY)');
    clefTextPainter.paint(canvas, Offset(clefX, clefY));

    // Draw key signature
    var currentX =
        clefX + clefTextPainter.width + EngravingStyle.clefMargin * spatium;
    print('StaffEngraving: Starting key signature at X: $currentX');

    final keySignaturePositions =
        EngravingUtils.getKeySignaturePositions(keySignature, clef);
    final keySignatureSymbol = keySignature.isSharp ? '♯' : '♭';
    final keySignatureStyle = TextStyle(
      fontFamily: 'Bravura',
      fontSize: spatium * 2,
      color: Colors.black,
    );

    for (final position in keySignaturePositions) {
      final textPainter = TextPainter(
        text: TextSpan(text: keySignatureSymbol, style: keySignatureStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final x = currentX;
      final y = staffTop + position.y * spatium;
      print('StaffEngraving: Drawing key signature at ($x, $y)');
      textPainter.paint(canvas, Offset(x, y));

      currentX += EngravingStyle.keysigAccidentalDistance * spatium;
    }

    // Draw time signature if needed
    if (timeSignature != null) {
      final timeX = currentX + EngravingStyle.keysigMargin * spatium;
      final timeY = staffTop + 2.0 * spatium; // Center on staff
      print('StaffEngraving: Drawing time signature at ($timeX, $timeY)');

      final numeratorPainter = TextPainter(
        text: TextSpan(
          text: timeSignature.numerator.toString(),
          style: TextStyle(
            fontFamily: 'Bravura',
            fontSize: spatium * 2,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      numeratorPainter.layout();
      numeratorPainter.paint(canvas, Offset(timeX, timeY - spatium));

      final denominatorPainter = TextPainter(
        text: TextSpan(
          text: timeSignature.denominator.toString(),
          style: TextStyle(
            fontFamily: 'Bravura',
            fontSize: spatium * 2,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      denominatorPainter.layout();
      denominatorPainter.paint(canvas, Offset(timeX, timeY + spatium * 0.5));
    }
  }

  /// Draw notes on the staff
  static void drawNotes(
    Canvas canvas,
    Size size,
    List<Note> notes,
    Clef clef,
    KeySignature keySignature,
    double startX, {
    required double spatium,
  }) {
    print('DRAW: Drawing ${notes.length} notes with clef $clef');
    final staffHeight = spatium * 4;
    final staffTop = (size.height - staffHeight) / 2;
    print('DRAW: Staff dimensions - height: $staffHeight, top: $staffTop');
    print('DRAW: Size: $size');

    // Create a staff model to handle note positioning
    final staffModel = staff_model.StaffModel(clef: clef);

    // Position notes on the staff
    final positionedNotes = staffModel.positionNotes(notes);

    // Calculate available width for notes
    final availableWidth =
        size.width - startX - EngravingStyle.staffMargin * spatium;
    final noteSpacing = availableWidth / (notes.length + 1);

    // Debug staff line positions - now correctly labeled for staff lines 0-4
    print('DRAW: Staff line positions:');
    print('DRAW: Top line (0): ${staffTop + 0 * spatium}');
    print('DRAW: Second line (1): ${staffTop + 1 * spatium}');
    print('DRAW: Middle line (2): ${staffTop + 2 * spatium}');
    print('DRAW: Fourth line (3): ${staffTop + 3 * spatium}');
    print('DRAW: Bottom line (4): ${staffTop + 4 * spatium}');

    double currentX = startX;

    for (final note in positionedNotes) {
      print('DRAW: Note MIDI ${note.midiPitch} at X: $currentX');

      // Get staff line from the note (follows MuseScore convention)
      final staffLine = note.staffLine;
      print('DRAW: Staff line position: $staffLine');

      // Calculate Y position - this is critical to get right
      // Staff lines are numbered from top to bottom:
      // 0.0 = top line
      // 1.0 = second line from top
      // 2.0 = middle line
      // 3.0 = fourth line from top (second from bottom)
      // 4.0 = bottom line
      final y = staffTop + staffLine * spatium;
      print('DRAW: Y position: $y');

      // Draw ledger lines if needed
      // if (staffModel.needsLedgerLine(staffLine)) {
      //   drawLedgerLines(canvas, staffModel as StaffModel, staffLine, currentX,
      //       staffTop, spatium,
      //       clef: clef, midiPitch: note.midiPitch);
      // }

      // Get note symbol
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

      // Draw the note
      final textPainter = TextPainter(
        text: TextSpan(
          text: noteSymbol,
          style: TextStyle(
            fontFamily: 'Bravura',
            fontSize: spatium * 5.0 * 0.95, // 5% smaller
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      print('DRAW: Text painter height: ${textPainter.height}');

      // Calculate proper note positioning
      // Center the note horizontally
      final xOffset = currentX - (textPainter.width / 2);

      // Calculate the base Y position
      final baseYPosition = staffTop + (staffLine * spatium);

      // Apply the optical center offset
      final opticalCenterRatio = 0.5; // 50% - center of note head
      final verticalOffset = textPainter.height * opticalCenterRatio;
      final yOffset = baseYPosition - verticalOffset;

      // Debug information
      print('DRAW: Note MIDI ${note.midiPitch} placed at ($xOffset, $yOffset)');
      print('DRAW: Original staff line: ${staffLine}, Corrected: $staffLine');
      print('DRAW: Y position: $baseYPosition');
      print(
          'DRAW: Text height: ${textPainter.height}, Optical center: $verticalOffset');
      print('DRAW: Final position: $yOffset');

      // Draw the note at the calculated position
      textPainter.paint(canvas, Offset(xOffset, yOffset));

      // Draw accidental if needed
      if (note.showAccidental && note.accidentalType != AccidentalType.none) {
        drawAccidental(
            canvas,
            note.accidentalType,
            xOffset -
                (spatium * 1.2), // Position to left of note with proper spacing
            y, // Use the same y position as the note
            spatium,
            staffLine: staffLine,
            staffTop: staffTop,
            midiPitch: note.midiPitch,
            clef: clef);
      }

      currentX += noteSpacing;
    }
  }

  // /// Draw ledger lines for a note
  // static void drawLedgerLines(Canvas canvas, StaffModel staffModel,
  //     double staffLine, double noteX, double staffTop, double spatium,
  //     {Clef? clef, int? midiPitch}) {
  //   final paint = Paint()
  //     ..color = Colors.black
  //     ..strokeWidth = spatium * 0.1
  //     ..style = PaintingStyle.stroke;

  //   // final ledgerLines = staffModel.getLedgerLines(staffLine);

  //   // Ledger lines should be slightly wider than the note head
  //   final ledgerWidth = spatium * 1.6;

  //   for (final line in ledgerLines) {
  //     // Apply corrections based on clef and pitch
  //     double correctedLine;

  //     if (clef == Clef.treble) {
  //       // For treble clef ledger lines
  //       if (line >= 5.0) {
  //         // Correct ledger lines for C4 and below
  //         if (line == 6.0) {
  //           // Second ledger line below staff becomes first ledger line
  //           correctedLine = 5.0;
  //         } else if (line > 6.0) {
  //           // Other lower ledger lines: shift up by 1.0
  //           correctedLine = line - 1.0;
  //         } else {
  //           // First ledger line remains as is
  //           correctedLine = line;
  //         }
  //       } else {
  //         // Ledger lines above the staff - keep as is
  //         correctedLine = line;
  //       }
  //     } else if (clef == Clef.bass) {
  //       // For bass clef ledger lines
  //       if (line <= -1.0) {
  //         // Ledger lines above the staff
  //         if (midiPitch != null && midiPitch >= 57) {
  //           // For A3 and above, correct to match note
  //           correctedLine = line + 1.0;
  //         } else {
  //           correctedLine = line;
  //         }
  //       } else if (line >= 5.0) {
  //         // Ledger lines below the staff
  //         if (midiPitch != null && midiPitch <= 43) {
  //           // For G2 and below, correct to match note
  //           correctedLine = line - 1.0;
  //         } else {
  //           correctedLine = line;
  //         }
  //       } else {
  //         // On staff - keep as is
  //         correctedLine = line;
  //       }
  //     } else {
  //       // Other clefs - keep as is
  //       correctedLine = line;
  //     }

  //     // Calculate Y position
  //     final y = staffTop + correctedLine * spatium;
  //     print(
  //         'DRAW: Ledger line at original staff position $line, corrected to $correctedLine, Y: $y');

  //     canvas.drawLine(
  //       Offset(noteX - ledgerWidth / 2, y),
  //       Offset(noteX + ledgerWidth / 2, y),
  //       paint,
  //     );
  //   }
  // }

  /// Get the clef symbol for a given clef
  static String getClefSymbol(Clef clef) {
    switch (clef) {
      case Clef.treble:
        return '𝄞';
      case Clef.bass:
        return '𝄢';
      case Clef.alto:
        return '𝄡';
      case Clef.tenor:
        return '𝄡';
    }
  }

  /// Calculate the starting X position for notes after clef and key signature
  static double calculateNoteStartX(
    Size size,
    Clef clef,
    KeySignature keySignature,
    TimeSignature timeSignature,
  ) {
    final spatium = size.height / 4;
    final clefStyle = TextStyle(
      fontFamily: 'Bravura',
      fontSize: spatium * 4,
      color: Colors.black,
    );

    final clefSymbol = getClefSymbol(clef);
    final clefTextPainter = TextPainter(
      text: TextSpan(text: clefSymbol, style: clefStyle),
      textDirection: TextDirection.ltr,
    );
    clefTextPainter.layout();

    var x = EngravingStyle.staffMargin * spatium + // Initial margin
        clefTextPainter.width + // Clef width
        EngravingStyle.clefMargin * spatium; // Margin after clef

    // Add key signature width
    if (keySignature != null) {
      x += keySignature.accidentals *
          EngravingStyle.keysigAccidentalDistance *
          spatium;
    }

    // Add time signature width
    if (timeSignature != null) {
      x += EngravingStyle.keysigMargin * spatium + // Margin after key signature
          spatium * 2; // Approximate time signature width
    }

    return x;
  }

  /// Draw an accidental symbol
  static void drawAccidental(Canvas canvas, AccidentalType accidentalType,
      double x, double y, double spatium,
      {double? staffLine, double? staffTop, int? midiPitch, Clef? clef}) {
    String symbol;

    switch (accidentalType) {
      case AccidentalType.sharp:
        symbol = '♯';
        break;
      case AccidentalType.flat:
        symbol = '♭';
        break;
      case AccidentalType.natural:
        symbol = '♮';
        break;
      case AccidentalType.doubleSharp:
        symbol = '𝄪';
        break;
      case AccidentalType.doubleFlat:
        symbol = '𝄫';
        break;
      default:
        return; // No accidental to draw
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontFamily: 'Bravura',
          fontSize: spatium * 3.5, // Slightly smaller than note head
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Use the same approach as for notes
    double yOffset;

    if (staffLine != null &&
        staffTop != null &&
        midiPitch != null &&
        clef != null) {
      // Apply the same precise corrections as for notes
      double correctedStaffLine;

      if (clef == Clef.treble) {
        if (midiPitch == 60) {
          // C4 - place directly on first ledger line below staff
          correctedStaffLine = 5.0;
        } else if (midiPitch == 62) {
          // D4 - place in space between staff and first ledger line
          correctedStaffLine = 4.5;
        } else {
          // E4 and higher - use staff line as is
          correctedStaffLine = staffLine;
        }
      } else if (clef == Clef.bass) {
        // Bass clef corrections
        if (midiPitch == 43) {
          // G2 - should be on second line from bottom
          correctedStaffLine = 3.0;
        } else if (midiPitch == 48) {
          // C3 - should be in space above middle line
          correctedStaffLine = 1.5;
        } else if (midiPitch == 53) {
          // F3 - should be on top line
          correctedStaffLine = 0.0;
        } else if (midiPitch < 43) {
          // Below G2 - adjust based on distance from G2
          correctedStaffLine = staffLine;
        } else if (midiPitch > 53) {
          // Above F3 - adjust based on distance from F3
          correctedStaffLine = staffLine;
        } else {
          // Between G2 and F3 - use staff line as is
          correctedStaffLine = staffLine;
        }
      } else {
        // For other clefs, use staff line as is
        correctedStaffLine = staffLine;
      }

      final baseYPosition = staffTop + (correctedStaffLine * spatium);
      final opticalCenterRatio = 0.5;
      final verticalOffset = textPainter.height * opticalCenterRatio;
      yOffset = baseYPosition - verticalOffset;
    } else {
      // If direct positioning is used
      final opticalCenterRatio = 0.5;
      final verticalOffset = textPainter.height * opticalCenterRatio;
      yOffset = y - verticalOffset;
    }

    textPainter.paint(canvas, Offset(x, yOffset));
  }
}
