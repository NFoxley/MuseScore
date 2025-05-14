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
        // Adjust vertical position: sharps slightly lower, flats slightly higher
        final verticalAdjustment =
            isSharp ? 0.1 : -0.1; // Adjust by 10% of spatium
        final symbolY =
            staffTop + ((position.y + verticalAdjustment) * spatium);
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
      final timeY = staffTop + 1.25 * spatium; // Center on staff
      print('StaffEngraving: Drawing time signature at ($timeX, $timeY)');

      final numeratorPainter = TextPainter(
        text: TextSpan(
          text: timeSignature.numerator.toString(),
          style: TextStyle(
            fontFamily: 'Bravura',
            fontSize: spatium * 2.6,
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
            fontSize: spatium * 2.6,
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

    double currentX = startX;
    final previousNotes = <Note>[];

    // Initialize key signature state
    keySignature.initializeNoteState();

    for (final note in positionedNotes) {
      print('DRAW: Note MIDI ${note.midiPitch} at X: $currentX');

      // Calculate staff line position
      final staffLine = note.staffLine;
      print('DRAW: Staff line: $staffLine');

      // Draw ledger lines if needed
      if (staffLine < 0 || staffLine > 4) {
        drawLedgerLines(
            canvas, staffModel, staffLine, currentX, staffTop, spatium,
            clef: clef, midiPitch: note.midiPitch);
      }

      // Draw the note
      final textPainter = TextPainter(
        text: TextSpan(
          text: '\uE1D5', // Quarter note symbol
          style: TextStyle(
            fontFamily: 'Bravura',
            fontSize: spatium * 5.0,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate proper note positioning
      final xOffset = currentX - (textPainter.width / 2);
      final baseYPosition = staffTop + (staffLine * spatium);
      final opticalCenterRatio = 0.5;
      final verticalOffset = textPainter.height * opticalCenterRatio;
      final yOffset = baseYPosition - verticalOffset;

      // Draw the note at the calculated position
      textPainter.paint(canvas, Offset(xOffset, yOffset));

      // Determine if we need to show an accidental
      bool needsAccidental = false;
      AccidentalType accidentalToShow = note.accidentalType;

      // Get the base note name and full note name with accidental
      final noteName = note.getNoteName(
          useFlats: note.accidentalType == AccidentalType.flat);
      final baseNote = noteName[0];
      final fullNoteName =
          noteName.replaceAll(RegExp(r'[0-9]'), ''); // Remove octave number

      // Check if this note is in the key signature
      final keyAccidentals = keySignature.isSharp
          ? KeySignature.sharpOrder
          : KeySignature.flatOrder;
      final count = keySignature.accidentalCount();
      final isBaseNoteInKey =
          keyAccidentals.sublist(0, count).contains(baseNote);

      // Get the key signature accidental type for this note
      final keyAccidentalType = isBaseNoteInKey
          ? (keySignature.isSharp ? AccidentalType.sharp : AccidentalType.flat)
          : AccidentalType.none;

      // A note is in the key signature if its base note is in the key AND it has the key's accidental type
      final isInKeySignature =
          isBaseNoteInKey && note.accidentalType == keyAccidentalType;

      print('\nChecking accidental for note: $fullNoteName');
      print(
          'Note in key signature: ${isInKeySignature ? "$baseNote${keySignature.isSharp ? "♯" : "♭"}" : "No"}');

      // Check if any previous note of the same pitch class was altered
      bool wasAlteredEarlier = false;
      AccidentalType previousAccidental = AccidentalType.none;
      for (final prevNote in previousNotes) {
        final prevNoteName = prevNote.getNoteName(
            useFlats: prevNote.accidentalType == AccidentalType.flat);
        final prevBaseNote = prevNoteName[0];
        if (prevBaseNote == baseNote) {
          // Only consider it altered if it deviates from its key signature state
          final prevIsInKey =
              keyAccidentals.sublist(0, count).contains(prevBaseNote);
          final prevKeyAccidentalType = prevIsInKey
              ? (keySignature.isSharp
                  ? AccidentalType.sharp
                  : AccidentalType.flat)
              : AccidentalType.none;

          if (prevNote.accidentalType != prevKeyAccidentalType) {
            wasAlteredEarlier = true;
            previousAccidental = prevNote.accidentalType;
            print(
                'Note was altered earlier by $prevNoteName with ${prevNote.accidentalType}');
            break;
          }
        }
      }

      // If the note is in the key signature
      if (isBaseNoteInKey) {
        // If note matches key signature
        if (note.accidentalType == keyAccidentalType) {
          // Show accidental if it was altered earlier
          needsAccidental = wasAlteredEarlier;
          accidentalToShow = note.accidentalType;
          print(
              'Note matches key signature${wasAlteredEarlier ? " but was altered earlier" : ""}');
        } else {
          // If note is different from key signature, show appropriate accidental
          needsAccidental = true;
          accidentalToShow = note.accidentalType == AccidentalType.none
              ? AccidentalType.natural
              : note.accidentalType;
          print('Note differs from key signature, showing ${accidentalToShow}');
        }
      }
      // If not in key signature
      else {
        // If note has an explicit accidental, show it
        if (note.accidentalType != AccidentalType.none) {
          needsAccidental = true;
          accidentalToShow = note.accidentalType;
          print('Note has explicit accidental ${accidentalToShow}');
        }
        // If note was altered earlier and is now natural, show natural
        else if (wasAlteredEarlier) {
          needsAccidental = true;
          accidentalToShow = AccidentalType.natural;
          print('Note was altered earlier, showing natural');
        }
      }

      // Draw accidental if needed
      if (needsAccidental) {
        print(
            'DRAW: Drawing accidental ${accidentalToShow} for note ${note.getNoteName()}');
        drawAccidental(canvas, accidentalToShow, xOffset - (spatium * 1.2),
            yOffset, spatium,
            staffLine: staffLine,
            staffTop: staffTop,
            midiPitch: note.midiPitch,
            clef: clef);
      }

      // Update key signature state
      keySignature.updateNoteState(note);

      currentX += noteSpacing;
      previousNotes.add(note);
    }

    // Clear tied notes state after drawing
    keySignature.clearTiedNotes();
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

    // Calculate font size based on accidental type
    double fontSize = spatium * 3.15; // Base size for most accidentals
    if (accidentalType == AccidentalType.flat ||
        accidentalType == AccidentalType.doubleFlat) {
      fontSize *= 0.82; // Reduce flat accidentals by 1/3
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontFamily: 'Bravura',
          fontSize: fontSize,
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

      // Adjust vertical position based on accidental type
      double verticalOffset;
      switch (accidentalType) {
        case AccidentalType.sharp:
          verticalOffset =
              textPainter.height * 0.47; // Slightly higher for sharps
          break;
        case AccidentalType.flat:
          verticalOffset =
              textPainter.height * 0.58; // Slightly lower for flats
          break;
        case AccidentalType.natural:
          verticalOffset = textPainter.height * 0.47; // Centered for naturals
          break;
        case AccidentalType.doubleSharp:
          verticalOffset = textPainter.height * 0.45; // Same as sharp
          break;
        case AccidentalType.doubleFlat:
          verticalOffset = textPainter.height * 0.55; // Same as flat
          break;
        default:
          verticalOffset = textPainter.height * 0.5;
      }

      yOffset = baseY -
          verticalOffset -
          (spatium * 0.4); // Move up by 0.3 staff lines

      // Add small adjustment for ledger lines
      if (staffLine < 0 || staffLine > 4) {
        yOffset += spatium * 0.1; // Slight upward adjustment for ledger lines
      }
    } else {
      yOffset = y;
    }

    // Draw the accidental
    textPainter.paint(canvas, Offset(x, yOffset));

    // Debug information
    print('DRAW: Drawing accidental $symbol at ($x, $yOffset)');
    print('DRAW: Accidental height: ${textPainter.height}');
    if (staffLine != null) {
      print('DRAW: Staff line: $staffLine');
    }
  }
}
