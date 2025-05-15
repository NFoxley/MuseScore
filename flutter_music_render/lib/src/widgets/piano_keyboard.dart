import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';
import 'package:flutter_music_render/src/engraving/note.dart';

/// The state of a piano key
enum PianoKeyState {
  /// No special state
  none,

  /// Key is currently being played
  played,

  /// Key is selected/highlighted
  selected,

  /// Key is part of a selected chord
  otherInSelectedChord,
}

/// A widget that displays a piano keyboard.
class PianoKeyboard extends StatefulWidget {
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

  /// Map of MIDI pitches to their current state
  final Map<int, PianoKeyState>? keyStates;

  /// MIDI pitch to center in the viewport
  final int? centerMidiPitch;

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
    this.keyStates,
    this.centerMidiPitch,
  });

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard>
    with SingleTickerProviderStateMixin {
  // Map to track currently pressed keys
  final Map<int, PianoKeyState> _pressedKeys = {};
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _centerNoteIfNeeded();
  }

  @override
  void didUpdateWidget(PianoKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.centerMidiPitch != widget.centerMidiPitch) {
      _centerNoteIfNeeded();
    }
  }

  void _centerNoteIfNeeded() {
    if (widget.centerMidiPitch == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final (startOctave, endOctave) = _getOctaveRange();
      final totalWhiteKeys = (endOctave - startOctave + 1) * 7;
      final totalWidth = totalWhiteKeys * PianoKeyboard.minWhiteKeyWidth;

      // Calculate the position of the target note
      final targetOctave = (widget.centerMidiPitch! ~/ 12) - 1;
      final pitchClass = widget.centerMidiPitch! % 12;

      // Convert MIDI pitch to white key index
      final whiteKeyIndex = _getWhiteKeyIndex(pitchClass);
      final octaveOffset = targetOctave - startOctave;

      if (octaveOffset < 0 || octaveOffset > endOctave - startOctave) {
        // Note is outside the visible range, scroll to the edge
        final scrollPosition = octaveOffset < 0 ? 0.0 : totalWidth.toDouble();
        _scrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }

      // Calculate the center position
      final targetPosition =
          (octaveOffset * 7 + whiteKeyIndex) * PianoKeyboard.minWhiteKeyWidth;
      final viewportWidth = _scrollController.position.viewportDimension;
      final scrollPosition = targetPosition -
          (viewportWidth / 2) +
          (PianoKeyboard.minWhiteKeyWidth / 2);

      // Ensure we don't scroll beyond bounds
      final maxScroll = _scrollController.position.maxScrollExtent;
      final clampedScroll = scrollPosition.clamp(0.0, maxScroll);

      _scrollController.animateTo(
        clampedScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  int _getWhiteKeyIndex(int pitchClass) {
    // Convert MIDI pitch class to white key index (0-6)
    switch (pitchClass) {
      case 0:
        return 0; // C
      case 2:
        return 1; // D
      case 4:
        return 2; // E
      case 5:
        return 3; // F
      case 7:
        return 4; // G
      case 9:
        return 5; // A
      case 11:
        return 6; // B
      default:
        return 0; // Default to C
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getKeyColor(bool isWhite, int midiPitch) {
    final state = widget.keyStates?[midiPitch] ??
        _pressedKeys[midiPitch] ??
        PianoKeyState.none;

    switch (state) {
      case PianoKeyState.played:
        return isWhite ? Colors.blue.shade200 : Colors.blue.shade800;
      case PianoKeyState.selected:
        return isWhite ? Colors.green.shade200 : Colors.green.shade800;
      case PianoKeyState.otherInSelectedChord:
        return isWhite ? Colors.yellow.shade200 : Colors.yellow.shade800;
      case PianoKeyState.none:
      default:
        return isWhite ? Colors.white : Colors.black;
    }
  }

  void _handleKeyPress(int midiPitch) {
    setState(() {
      _pressedKeys[midiPitch] = PianoKeyState.played;
    });

    _animationController.forward(from: 0.0).then((_) {
      setState(() {
        _pressedKeys.remove(midiPitch);
      });
    });

    final note = Note(
      midiPitch: midiPitch,
      duration: NoteDuration.quarter,
      linePosition: 0,
      accidentalType: _getAccidentalType(midiPitch),
      showAccidental: _shouldShowAccidental(midiPitch),
    );
    widget.onNoteSelected(note);
  }

  @override
  Widget build(BuildContext context) {
    final (startOctave, endOctave) = _getOctaveRange();
    const whiteKeyWidth = 48.0;
    const blackKeyWidth = 32.0;
    const whiteKeyHeight = 200.0;
    const blackKeyHeight = 120.0;

    // Calculate total width needed
    final totalWhiteKeys = (endOctave - startOctave + 1) * 7;
    final totalWidth = totalWhiteKeys * whiteKeyWidth;

    return SingleChildScrollView(
      controller: _scrollController,
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
                        onTap: () => _handleKeyPress(midiPitch),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getKeyColor(true, midiPitch),
                            border: Border.all(color: Colors.black),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(4),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _getNoteLabel(midiPitch),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
                        onTap: () => _handleKeyPress(midiPitch),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getKeyColor(false, midiPitch),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(4),
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _getNoteLabel(midiPitch),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
    switch (widget.clef) {
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

    final noteName =
        widget.useFlats ? flatNames[pitchClass] : sharpNames[pitchClass];
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
      return widget.useFlats ? AccidentalType.flat : AccidentalType.sharp;
    }

    return AccidentalType.none;
  }
}
