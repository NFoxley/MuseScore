import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';
import 'package:flutter_music_render/src/engraving/note.dart';

/// A widget that displays a piano keyboard.
class PianoKeyboard extends StatelessWidget {
  /// The list of notes to be displayed
  final List<Note> notes;

  /// Callback when a note is selected
  final Function(Note) onNoteSelected;

  /// The key signature
  final KeySignature keySignature;

  /// Toggle for sharp/flat display
  final bool useFlats;

  /// The clef to determine the key range
  final Clef clef;

  /// Minimum width for white keys
  static const double minWhiteKeyWidth = 48.0;

  /// Minimum width for black keys
  static const double minBlackKeyWidth = 32.0;

  /// Height of white keys
  static const double whiteKeyHeight = 200.0;

  /// Height of black keys
  static const double blackKeyHeight = 120.0;

  /// Creates a new piano keyboard widget.
  const PianoKeyboard({
    super.key,
    required this.notes,
    required this.onNoteSelected,
    required this.keySignature,
    required this.useFlats,
    required this.clef,
  });

  @override
  Widget build(BuildContext context) {
    final (startOctave, endOctave) = _getOctaveRange();
    final whiteKeyWidth = 48.0;
    final blackKeyWidth = 32.0;
    final whiteKeyHeight = 200.0;
    final blackKeyHeight = 120.0;

    // Calculate total width needed
    final totalWhiteKeys = (endOctave - startOctave + 1) * 7;
    final totalWidth = totalWhiteKeys * whiteKeyWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        height: whiteKeyHeight,
        child: Stack(
          children: [
            // White keys
            Row(
              children: List.generate(totalWhiteKeys, (index) {
                final octave = startOctave + (index ~/ 7);
                final semitone = index % 7;
                final midiPitch = _calculateMidiPitch(octave, semitone);

                return SizedBox(
                  width: whiteKeyWidth,
                  height: whiteKeyHeight,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          final note = Note(
                            midiPitch: midiPitch,
                            duration: NoteDuration.quarter,
                            linePosition: 0,
                            accidentalType: _getAccidentalType(midiPitch),
                            showAccidental: _shouldShowAccidental(midiPitch),
                          );
                          onNoteSelected(note);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Text(
                          _getNoteLabel(midiPitch),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            // Black keys
            ...List.generate(totalWhiteKeys - 1, (index) {
              final octave = startOctave + (index ~/ 7);
              final semitone = index % 7;

              // Skip black keys between E-F and B-C
              if (semitone == 2 || semitone == 6) {
                return const SizedBox.shrink();
              }

              // Calculate MIDI pitch for black keys
              int midiPitch;
              if (semitone == 0)
                midiPitch = _calculateMidiPitch(octave, 0) + 1; // C#
              else if (semitone == 1)
                midiPitch = _calculateMidiPitch(octave, 1) + 1; // D#
              else if (semitone == 3)
                midiPitch = _calculateMidiPitch(octave, 3) + 1; // F#
              else if (semitone == 4)
                midiPitch = _calculateMidiPitch(octave, 4) + 1; // G#
              else
                midiPitch = _calculateMidiPitch(octave, 5) + 1; // A#

              return Positioned(
                left: (index + 1) * whiteKeyWidth - blackKeyWidth / 2,
                top: 0,
                child: SizedBox(
                  width: blackKeyWidth,
                  height: blackKeyHeight,
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          final note = Note(
                            midiPitch: midiPitch,
                            duration: NoteDuration.quarter,
                            linePosition: 0,
                            accidentalType: useFlats
                                ? AccidentalType.flat
                                : AccidentalType.sharp,
                            showAccidental: true,
                          );
                          onNoteSelected(note);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Text(
                          _getNoteLabel(midiPitch),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Get the octave range based on the clef
  (int, int) _getOctaveRange() {
    switch (clef) {
      case Clef.treble:
        return (4, 6); // C4-C6
      case Clef.bass:
        return (2, 4); // C2-C4
      case Clef.alto:
        return (3, 5); // C3-C5
      case Clef.tenor:
        return (3, 5); // C3-C5
    }
  }

  /// Calculate MIDI pitch for a key
  int _calculateMidiPitch(int octave, int semitone) {
    // For white keys (C, D, E, F, G, A, B)
    // C = 0, D = 2, E = 4, F = 5, G = 7, A = 9, B = 11
    // MIDI standard: Middle C (C4) is 60
    final whiteKeySemitones = [0, 2, 4, 5, 7, 9, 11];
    final semitoneIndex = semitone % 7;

    // Calculate base pitch for the octave
    // C4 (Middle C) is 60, so C3 is 48, C5 is 72, etc.
    final basePitch = (octave * 12) + 12;
    final pitch = basePitch + whiteKeySemitones[semitoneIndex];

    print(
        'MIDI calculation: octave $octave, semitone $semitone = MIDI $pitch (${_getNoteLabel(pitch)})');
    return pitch;
  }

  /// Get the note label for a MIDI pitch
  String _getNoteLabel(int midiPitch) {
    final pitchClass = midiPitch % 12;
    final octave = (midiPitch ~/ 12) - 1; // Standard MIDI octave calculation

    // Define the notes in order with their accidentals
    final sharpNames = [
      'C',
      'C♯',
      'D',
      'D♯',
      'E',
      'F',
      'F♯',
      'G',
      'G♯',
      'A',
      'A♯',
      'B'
    ];

    final flatNames = [
      'C',
      'D♭',
      'D',
      'E♭',
      'E',
      'F',
      'G♭',
      'G',
      'A♭',
      'A',
      'B♭',
      'B'
    ];

    final noteName = useFlats ? flatNames[pitchClass] : sharpNames[pitchClass];
    return '$noteName$octave';
  }

  /// Determine if a note should display an accidental based on key signature
  bool _shouldShowAccidental(int midiPitch) {
    // In a real implementation, this would check against the key signature
    // For now, we'll just show accidentals for black keys
    final pitchClass = midiPitch % 12;
    return pitchClass == 1 ||
        pitchClass == 3 ||
        pitchClass == 6 ||
        pitchClass == 8 ||
        pitchClass == 10;
  }

  /// Get the correct accidental type based on key signature preference
  AccidentalType _getAccidentalType(int midiPitch) {
    final pitchClass = midiPitch % 12;

    // Check if this is a black key
    if (pitchClass == 1 ||
        pitchClass == 3 ||
        pitchClass == 6 ||
        pitchClass == 8 ||
        pitchClass == 10) {
      return useFlats ? AccidentalType.flat : AccidentalType.sharp;
    }

    return AccidentalType.none;
  }
}
