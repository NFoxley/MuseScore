/// Represents a musical note.
class Note {
  /// The MIDI pitch of the note (0-127)
  final int midiPitch;

  /// The duration of the note in beats
  final Duration duration;

  /// The staff line position (0-4)
  final int line;

  /// The horizontal position index
  final int index;

  /// The name of the note (C, D, E, etc.)
  final String name;

  /// The octave number (0-10)
  final int octave;

  /// Whether this is a black key
  final bool isBlackKey;

  /// The accidental of the note (null if none)
  final String? accidental;

  /// Creates a new note.
  const Note({
    required this.midiPitch,
    required this.duration,
    required this.line,
    required this.index,
    required this.name,
    required this.octave,
    required this.isBlackKey,
    this.accidental,
  });

  /// Creates a note from a MIDI pitch.
  static Note fromMidiPitch(int midiPitch) {
    final noteIndex = midiPitch % 12;
    final octave = (midiPitch ~/ 12) - 1;

    // Define the notes in order with their accidentals
    const List<String> noteNames = [
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
    const List<bool> isBlackKeyList = [
      false, // C
      true, // C♯
      false, // D
      true, // D♯
      false, // E
      false, // F
      true, // F♯
      false, // G
      true, // G♯
      false, // A
      true, // A♯
      false, // B
    ];

    final noteName = noteNames[noteIndex];
    final isBlackKey = isBlackKeyList[noteIndex];

    return Note(
      midiPitch: midiPitch,
      duration: Duration.quarter,
      line: 0, // This will be calculated by the staff
      index: 0, // This will be set by the staff
      name: noteName,
      octave: octave,
      isBlackKey: isBlackKey,
      accidental: isBlackKey ? '♯' : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          midiPitch == other.midiPitch &&
          duration == other.duration &&
          line == other.line &&
          index == other.index &&
          name == other.name &&
          octave == other.octave &&
          isBlackKey == other.isBlackKey &&
          accidental == other.accidental;

  @override
  int get hashCode =>
      midiPitch.hashCode ^
      duration.hashCode ^
      line.hashCode ^
      index.hashCode ^
      name.hashCode ^
      octave.hashCode ^
      isBlackKey.hashCode ^
      accidental.hashCode;
}

/// Represents a musical duration.
class Duration {
  /// The duration value in beats
  final double value;

  /// The stem direction: 1 for up, -1 for down, 0 for no stem
  final int stemDirection;

  /// Whether this duration requires a beam
  final bool requiresBeam;

  /// Whether this duration has a dot
  final bool hasDot;

  /// Creates a new duration.
  const Duration(
    this.value, {
    this.stemDirection = 1,
    this.requiresBeam = false,
    this.hasDot = false,
  });

  /// Standard duration values
  static const Duration whole = Duration(4.0, stemDirection: 0);
  static const Duration half = Duration(2.0);
  static const Duration quarter = Duration(1.0);
  static const Duration eighth = Duration(0.5, requiresBeam: true);
  static const Duration sixteenth = Duration(0.25, requiresBeam: true);
  static const Duration thirtySecond = Duration(0.125, requiresBeam: true);
  static const Duration sixtyFourth = Duration(0.0625, requiresBeam: true);

  /// Dotted duration values
  static const Duration dottedHalf = Duration(3.0, hasDot: true);
  static const Duration dottedQuarter = Duration(1.5, hasDot: true);
  static const Duration dottedEighth =
      Duration(0.75, requiresBeam: true, hasDot: true);
  static const Duration dottedSixteenth =
      Duration(0.375, requiresBeam: true, hasDot: true);
  static const Duration dottedThirtySecond =
      Duration(0.1875, requiresBeam: true, hasDot: true);
  static const Duration dottedSixtyFourth =
      Duration(0.09375, requiresBeam: true, hasDot: true);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Duration &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          stemDirection == other.stemDirection &&
          requiresBeam == other.requiresBeam &&
          hasDot == other.hasDot;

  @override
  int get hashCode =>
      value.hashCode ^
      stemDirection.hashCode ^
      requiresBeam.hashCode ^
      hasDot.hashCode;
}
