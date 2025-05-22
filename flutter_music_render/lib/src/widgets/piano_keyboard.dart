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

  /// Optional custom key range. If not provided, will be determined by clef.
  /// The range is specified as (startMidiPitch, endMidiPitch) inclusive.
  /// For example, (60, 72) would show from middle C (C4) to C5.
  final (int, int)? keyRange;

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
    this.keyRange,
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

  // Track if we're currently scrolling
  bool _isScrolling = false;
  // Track the last tap position for scroll detection
  Offset? _lastTapPosition;

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
      // Reset scroll position if centerMidiPitch changes
      _scrollController.jumpTo(0);
      _centerNoteIfNeeded();
    }
  }

  void _centerNoteIfNeeded() {
    if (widget.centerMidiPitch == null) return;

    // Use a post-frame callback to ensure the widget is fully built and laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Check if widget is still mounted

      final (startMidiPitch, endMidiPitch) = _getKeyRange();
      final targetMidiPitch = widget.centerMidiPitch!;

      // Calculate the position of the target note
      int whiteKeysBeforeTarget = 0;
      for (int pitch = startMidiPitch; pitch < targetMidiPitch; pitch++) {
        if (_isWhiteKey(pitch)) {
          whiteKeysBeforeTarget++;
        }
      }

      // Calculate the total width of white keys before the target
      final targetPosition =
          whiteKeysBeforeTarget * PianoKeyboard.minWhiteKeyWidth;

      // Get the viewport width
      final viewportWidth = _scrollController.position.viewportDimension;

      // Calculate the scroll position to center the target note
      final scrollPosition = targetPosition -
          (viewportWidth / 2) +
          (PianoKeyboard.minWhiteKeyWidth / 2);

      // Ensure we don't scroll beyond bounds
      final maxScroll = _scrollController.position.maxScrollExtent;
      final clampedScroll = scrollPosition.clamp(0.0, maxScroll);

      debugPrint('Centering note: MIDI pitch $targetMidiPitch');
      debugPrint('White keys before target: $whiteKeysBeforeTarget');
      debugPrint('Target position: $targetPosition');
      debugPrint('Viewport width: $viewportWidth');
      debugPrint('Scroll position: $scrollPosition');
      debugPrint('Clamped scroll: $clampedScroll');

      _scrollController.animateTo(
        clampedScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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
    // Only trigger note entry if we're not scrolling
    if (!_isScrolling) {
      final note = Note(
        midiPitch: midiPitch,
        duration: NoteDuration.quarter,
        linePosition: 0,
        accidentalType: _getAccidentalType(midiPitch),
        showAccidental: _shouldShowAccidental(midiPitch),
      );
      widget.onNoteSelected(note);
    }
  }

  void _handleKeyDown(int midiPitch) {
    setState(() {
      _pressedKeys[midiPitch] = PianoKeyState.played;
    });
  }

  void _handleKeyUp(int midiPitch) {
    setState(() {
      _pressedKeys.remove(midiPitch);
    });
  }

  @override
  Widget build(BuildContext context) {
    final (startMidiPitch, endMidiPitch) = _getKeyRange();
    const whiteKeyWidth = 48.0;
    const blackKeyWidth = 32.0;
    const whiteKeyHeight = 200.0;
    const blackKeyHeight = 120.0;

    // Calculate total width needed based on the number of white keys in range
    int totalWhiteKeys = 0;
    for (int pitch = startMidiPitch; pitch <= endMidiPitch; pitch++) {
      if (_isWhiteKey(pitch)) {
        totalWhiteKeys++;
      }
    }
    final totalWidth = totalWhiteKeys * whiteKeyWidth;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        _isScrolling = true;
        _lastTapPosition = details.globalPosition;
      },
      onHorizontalDragUpdate: (details) {
        if (_lastTapPosition != null) {
          final dx = details.globalPosition.dx - _lastTapPosition!.dx;
          _scrollController.jumpTo(_scrollController.offset - dx);
          _lastTapPosition = details.globalPosition;
        }
      },
      onHorizontalDragEnd: (_) {
        _isScrolling = false;
        _lastTapPosition = null;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics:
            const NeverScrollableScrollPhysics(), // Disable default scrolling
        child: SizedBox(
          width: totalWidth,
          height: whiteKeyHeight,
          child: Stack(
            children: [
              // White keys
              Row(
                children: List.generate(totalWhiteKeys, (index) {
                  final midiPitch = _getNthWhiteKey(startMidiPitch, index);
                  if (midiPitch > endMidiPitch) return const SizedBox.shrink();

                  return SizedBox(
                    width: whiteKeyWidth,
                    height: whiteKeyHeight,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTapDown: (_) => _handleKeyDown(midiPitch),
                          onTapUp: (_) {
                            _handleKeyUp(midiPitch);
                            _handleKeyPress(midiPitch);
                          },
                          onTapCancel: () => _handleKeyUp(midiPitch),
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
                final whiteKeyPitch = _getNthWhiteKey(startMidiPitch, index);
                if (whiteKeyPitch >= endMidiPitch)
                  return const SizedBox.shrink();

                // Check if there's a black key between this white key and the next
                final nextWhiteKeyPitch =
                    _getNthWhiteKey(startMidiPitch, index + 1);
                if (nextWhiteKeyPitch > endMidiPitch)
                  return const SizedBox.shrink();

                // If there's a black key between these white keys
                if (nextWhiteKeyPitch - whiteKeyPitch == 2) {
                  final blackKeyPitch = whiteKeyPitch + 1;
                  return Positioned(
                    left: (index + 1) * whiteKeyWidth - blackKeyWidth / 2,
                    top: 0,
                    child: SizedBox(
                      width: blackKeyWidth,
                      height: blackKeyHeight,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTapDown: (_) => _handleKeyDown(blackKeyPitch),
                            onTapUp: (_) {
                              _handleKeyUp(blackKeyPitch);
                              _handleKeyPress(blackKeyPitch);
                            },
                            onTapCancel: () => _handleKeyUp(blackKeyPitch),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getKeyColor(false, blackKeyPitch),
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(4),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    _getNoteLabel(blackKeyPitch),
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
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Get the key range based on the clef or custom range
  (int, int) _getKeyRange() {
    if (widget.keyRange != null) {
      return widget.keyRange!;
    }

    // Default ranges based on clef (in MIDI pitches)
    switch (widget.clef) {
      case Clef.treble:
        return (60, 84); // C4-C6
      case Clef.bass:
        return (36, 60); // C2-C4
      case Clef.alto:
        return (48, 72); // C3-C5
      case Clef.tenor:
        return (48, 72); // C3-C5
    }
  }

  /// Check if a MIDI pitch corresponds to a white key
  bool _isWhiteKey(int midiPitch) {
    final pitchClass = midiPitch % 12;
    return pitchClass == 0 || // C
        pitchClass == 2 || // D
        pitchClass == 4 || // E
        pitchClass == 5 || // F
        pitchClass == 7 || // G
        pitchClass == 9 || // A
        pitchClass == 11; // B
  }

  /// Get the nth white key starting from a given MIDI pitch
  int _getNthWhiteKey(int startPitch, int n) {
    int currentPitch = startPitch;
    int whiteKeysFound = 0;

    while (whiteKeysFound < n) {
      currentPitch++;
      if (_isWhiteKey(currentPitch)) {
        whiteKeysFound++;
      }
    }

    return currentPitch;
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
