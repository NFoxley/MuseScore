import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';
import 'package:flutter_music_render/flutter_music_render.dart' as staff_model;
import '../engraving/note.dart';
import '../engraving/clef.dart';
import '../engraving/key_signature.dart';
import '../engraving/time_signature.dart';
import '../engraving/staff_engraving.dart';
import '../engraving/engraving.dart';
import '../engraving/staff_model.dart';

/// A widget that displays a musical staff with notes.
class Staff extends StatefulWidget {
  final List<Note> notes;
  final Clef clef;
  final TimeSignature? timeSignature;
  final KeySignature keySignature;
  final VoidCallback? onClear;
  final double spatium; // Base unit of measurement

  const Staff({
    super.key,
    required this.notes,
    required this.clef,
    required this.timeSignature,
    required this.keySignature,
    this.onClear,
    this.spatium = 12.0, // Default spatium size
  });

  @override
  State<Staff> createState() => StaffState();
}

class StaffState extends State<Staff> {
  late staff_model.StaffModel _staffModel;

  @override
  void initState() {
    super.initState();
    _staffModel = staff_model.StaffModel(clef: widget.clef);
  }

  @override
  void didUpdateWidget(Staff oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clef != widget.clef) {
      _staffModel = staff_model.StaffModel(clef: widget.clef);
    }
  }

  void addNote(Note note) {
    setState(() {
      // Position the note correctly on the staff before adding it
      final positionedNote = _staffModel.positionNote(note);
      widget.notes.add(positionedNote);
      print(
          'Added note to staff: MIDI ${note.midiPitch}, Staff line: ${positionedNote.staffLine}');
    });
  }

  void clearNotes() {
    setState(() {
      widget.notes.clear();
      if (widget.onClear != null) {
        widget.onClear!();
      }
      print('Cleared all notes from staff');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final staffWidth = constraints.maxWidth * 0.8;
            final staffHeight = constraints.maxHeight * 0.8;

            // Calculate spatium based on both width and height constraints
            final widthSpatium = staffWidth / 32;
            final heightSpatium = staffHeight / 8;
            final spatium =
                widthSpatium < heightSpatium ? widthSpatium : heightSpatium;

            print('Staff rendering with ${widget.notes.length} notes');
            widget.notes
                .forEach((note) => print('Note: MIDI ${note.midiPitch}'));

            return CustomPaint(
              painter: StaffPainter(
                notes: widget.notes,
                clef: widget.clef,
                timeSignature: widget.timeSignature,
                keySignature: widget.keySignature,
                spatium: spatium,
              ),
              size: Size(staffWidth, staffHeight),
              child: Container(),
            );
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearNotes,
            tooltip: 'Clear notes',
          ),
        ),
      ],
    );
  }
}

/// A painter that draws a musical staff.
class StaffPainter extends CustomPainter {
  /// The list of notes to display
  final List<Note> notes;

  /// The clef to display
  final Clef clef;

  /// The time signature to display
  final TimeSignature? timeSignature;

  /// The key signature to display
  final KeySignature keySignature;

  /// The base unit of measurement
  final double spatium;

  /// Creates a new staff painter.
  StaffPainter({
    required this.notes,
    required this.clef,
    required this.timeSignature,
    required this.keySignature,
    required this.spatium,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate staff dimensions
    final staffHeight = spatium * 4; // 4 spaces between 5 lines
    final staffTop = (size.height - staffHeight) / 2;

    // Draw staff with clef, key signature, and time signature
    StaffEngraving.drawStaff(
      canvas,
      size,
      clef,
      keySignature,
      timeSignature,
      notes,
      spatium: spatium,
    );
  }

  @override
  bool shouldRepaint(covariant StaffPainter oldDelegate) {
    return notes != oldDelegate.notes ||
        clef != oldDelegate.clef ||
        timeSignature != oldDelegate.timeSignature ||
        keySignature != oldDelegate.keySignature ||
        spatium != oldDelegate.spatium;
  }
}

/// A model representing the staff
