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
import 'note_engraving.dart' hide StaffModel;
import 'staff_model.dart';

/// Class for staff engraving
class StaffEngraving {
  /// Draw a staff with clef, key signature, and time signature
  static void drawStaff(
    Canvas canvas,
    Size size,
    Clef clef,
    KeySignature keySignature,
    TimeSignature? timeSignature,
    List<Note> notes, {
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
    final clefSymbol = getClefSymbol(clef);
    final clefStyle = TextStyle(
      fontFamily: 'Bravura',
      fontSize: spatium * 4.95, // Increased by 10% from 4.5 to 4.95
      color: Colors.black,
    );
    final clefTextPainter = TextPainter(
      text: TextSpan(text: clefSymbol, style: clefStyle),
      textDirection: TextDirection.ltr,
    );
    clefTextPainter.layout();

    var clefX = EngravingStyle.staffMargin * spatium;
    // Position clef at the correct height based on clef type
    final clefY =
        staffTop + (EngravingStyle.clefYPositions[clef]! - 2.0) * spatium;
    print('StaffEngraving: Drawing clef at ($clefX, $clefY)');
    clefTextPainter.paint(canvas, Offset(clefX, clefY));

    // Draw key signature
    if (keySignature != null) {
      final positions =
          EngravingUtils.getKeySignaturePositions(keySignature, clef);
      print(
          'Drawing key signature: ${keySignature.isSharp ? "sharp" : "flat"} with ${positions.length} accidentals');

      var currentX =
          clefX + clefTextPainter.width + EngravingStyle.clefMargin * spatium;
      final isSharp = keySignature.isSharp;
      final symbol = isSharp ? '♯' : '♭';

      for (final position in positions) {
        final symbolX = currentX;
        final symbolY = staffTop + (position.y * spatium);
        print('Drawing $symbol at ($symbolX, $symbolY)');

        // Draw the accidental
        final textPainter = TextPainter(
          text: TextSpan(
            text: symbol,
            style: TextStyle(
              fontFamily: 'Bravura',
              fontSize: spatium * 2.5,
              color: Colors.black,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
            canvas, Offset(symbolX, symbolY - textPainter.height));

        // Update x position for next accidental
        currentX += EngravingStyle.keysigAccidentalDistance * spatium;
      }
      clefX = currentX;
    }

    // Draw time signature if needed
    if (timeSignature != null) {
      final timeX = clefX + EngravingStyle.clefMargin * spatium;
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

    // Draw notes
    if (notes.isNotEmpty) {
      // Add extra margin after time signature or key signature
      final startX = clefX + EngravingStyle.timesigMargin * spatium;
      drawNotes(canvas, size, notes, clef, keySignature, startX,
          spatium: spatium);
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
    final staffModel = StaffModel(clef: clef);

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
      if (staffModel.needsLedgerLine(staffLine)) {
        drawLedgerLines(
            canvas, staffModel, staffLine, currentX, staffTop, spatium,
            clef: clef, midiPitch: note.midiPitch);
      }

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
      if (keySignature.needsAccidental(note)) {
        drawAccidental(
            canvas,
            note.accidentalType,
            xOffset -
                (spatium * 1.2), // Position to left of note with proper spacing
            yOffset, // Use the same y position as the note head
            spatium,
            staffLine: staffLine,
            staffTop: staffTop,
            midiPitch: note.midiPitch,
            clef: clef);
      }

      currentX += noteSpacing;
    }
  }

  /// Draw ledger lines for a note
  static void drawLedgerLines(Canvas canvas, StaffModel staffModel,
      double staffLine, double noteX, double staffTop, double spatium,
      {Clef? clef, int? midiPitch}) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = spatium * 0.1
      ..style = PaintingStyle.stroke;

    // Get all ledger lines needed for this note
    final ledgerLines = staffModel.getLedgerLines(staffLine);

    // Draw each ledger line
    for (final line in ledgerLines) {
      // Only draw ledger lines for notes on lines, not spaces
      if (line % 1 == 0) {
        // Integer values are lines
        final y = staffTop + line * spatium;
        final ledgerWidth = spatium * 1.728; // Another 20% wider (1.44 * 1.2)

        canvas.drawLine(
          Offset(noteX - ledgerWidth / 2, y),
          Offset(noteX + ledgerWidth / 2, y),
          paint,
        );
      }
    }
  }

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
      x += keySignature.accidentalCount() *
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
          fontSize: spatium * 3.15, // 10% smaller than before (3.5 * 0.9)
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Calculate y position for accidental
    double yOffset;
    if (staffLine != null && staffTop != null) {
      // Center the accidental vertically with the note head
      final baseY = staffTop + staffLine * spatium;
      final verticalOffset = textPainter.height * 0.5; // Center vertically
      yOffset = baseY - verticalOffset;
    } else {
      yOffset = y;
    }

    textPainter.paint(canvas, Offset(x, yOffset));
  }
}
