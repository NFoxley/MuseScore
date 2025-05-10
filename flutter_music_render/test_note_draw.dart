import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lib/src/engraving/clef.dart';
import 'lib/src/engraving/staff_model.dart';
import 'lib/src/engraving/note.dart';
import 'lib/src/engraving/key_signature.dart';
import 'lib/src/engraving/time_signature.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note Drawing Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Drawing Debug'),
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: NotePainter(),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class NotePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spatium = 10.0; // Set a fixed spatium for testing

    // Draw staff lines for reference
    final staffLinesPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    final staffTop = 100.0;
    final staffHeight = spatium * 4;

    // Draw 5 staff lines
    for (int i = 0; i < 5; i++) {
      final y = staffTop + i * spatium;
      canvas.drawLine(
        Offset(50, y),
        Offset(size.width - 50, y),
        staffLinesPaint,
      );

      // Label each line
      final linePainter = TextPainter(
        text: TextSpan(
          text: 'Line ${i - 2}',
          style: const TextStyle(color: Colors.blue),
        ),
        textDirection: TextDirection.ltr,
      );
      linePainter.layout();
      linePainter.paint(canvas, Offset(10, y - 10));
    }

    // Create a StaffModel for testing
    final staffModel = StaffModel(clef: Clef.treble);

    // Test several notes at different positions
    final testNotes = [
      (60, 'C4'), // Should be on first ledger line below staff (staff line 5)
      (64, 'E4'), // Should be on bottom line (staff line 2)
      (71, 'B4'), // Should be on middle line (staff line 0)
      (76, 'E5'), // Should be on top line (staff line -2)
    ];

    var x = 100.0;
    final spacing = 100.0;

    // Draw a notehead at each position
    for (final (midiPitch, name) in testNotes) {
      // Calculate staff line
      final staffLine = staffModel.calculateStaffLine(midiPitch);

      // Calculate Y position
      final y = staffTop + (staffLine + 2) * spatium;

      // Draw position indicator line at the calculated Y position
      canvas.drawLine(
        Offset(x - 20, y),
        Offset(x + 20, y),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2.0,
      );

      // Draw the notehead
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

      // Center the note horizontally
      final xOffset = x - (textPainter.width / 2);

      // For vertical positioning, draw with three different methods to compare

      // Method 1: Direct placement at y (no centering)
      textPainter.paint(canvas, Offset(xOffset, y));

      // Method 2: Centering by offsetting half the height
      textPainter.paint(
          canvas, Offset(xOffset + 50, y - textPainter.height / 2));

      // Method 3: Offset by 3/4 of the height for better visual centering
      textPainter.paint(
          canvas, Offset(xOffset + 100, y - textPainter.height * 0.75));

      // Add debug info
      final debugPainter = TextPainter(
        text: TextSpan(
          text: '$name (MIDI $midiPitch)\nStaff line: $staffLine\nY: $y',
          style: const TextStyle(color: Colors.black, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      debugPainter.layout();
      debugPainter.paint(canvas, Offset(x - 30, y + 30));

      x += spacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
