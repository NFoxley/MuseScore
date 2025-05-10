/// Represents the accidental type for a note
enum AccidentalType {
  none,
  sharp,
  flat,
  natural,
  doubleSharp,
  doubleFlat,
}

/// Represents a musical note with its pitch, duration, and position
class Note {
  final int midiPitch;
  final NoteDuration duration;
  final double linePosition;

  // Accidental information
  AccidentalType accidentalType;
  bool showAccidental;

  // Staff line value following MuseScore's convention
  // 0 = center line of staff (B4 for treble, D3 for bass)
  // Positive values go DOWN (lower pitches)
  // Negative values go UP (higher pitches)
  // Integer values = lines, half-integer values = spaces
  double? _staffLine;

  double get staffLine => _staffLine ?? linePosition;

  void setStaffLine(double line) {
    _staffLine = line;
  }

  Note({
    required this.midiPitch,
    required this.duration,
    required this.linePosition,
    this.accidentalType = AccidentalType.none,
    this.showAccidental = false,
  });

  // Create a copy of this note with a new staff line
  Note copyWithStaffLine(double staffLine) {
    final note = Note(
      midiPitch: midiPitch,
      duration: duration,
      linePosition: linePosition,
      accidentalType: accidentalType,
      showAccidental: showAccidental,
    );
    note.setStaffLine(staffLine);
    return note;
  }

  // Get the note name based on MIDI pitch and whether to use flats or sharps
  String getNoteName({bool useFlats = false}) {
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

  // Get the accidental symbol as a string
  String? getAccidentalSymbol() {
    switch (accidentalType) {
      case AccidentalType.none:
        return null;
      case AccidentalType.sharp:
        return '♯';
      case AccidentalType.flat:
        return '♭';
      case AccidentalType.natural:
        return '♮';
      case AccidentalType.doubleSharp:
        return '𝄪';
      case AccidentalType.doubleFlat:
        return '𝄫';
    }
  }
}

/// Represents the duration of a note
enum NoteDuration {
  whole,
  half,
  quarter,
  eighth,
  sixteenth,
}
