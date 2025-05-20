import 'package:flutter/material.dart';

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
  /// The MIDI pitch of the note (-1 for rests)
  final int midiPitch;

  /// The duration of the note
  final NoteDuration duration;

  /// The position on the staff (0 = middle line)
  final double linePosition;

  /// The type of accidental
  final AccidentalType accidentalType;

  /// Whether to show the accidental
  final bool showAccidental;

  /// The color of the note (null for default color)
  final Color? color;

  /// The staff line position (calculated)
  final double staffLine;

  /// Whether the stem points up (true) or down (false)
  final bool stemUp;

  /// Creates a new note
  const Note({
    required this.midiPitch,
    required this.duration,
    required this.linePosition,
    this.accidentalType = AccidentalType.none,
    this.showAccidental = false,
    this.color,
    this.stemUp = true, // Default to up stem
  }) : staffLine = linePosition;

  /// Creates a copy of this note with the given fields replaced with new values
  Note copyWith({
    int? midiPitch,
    NoteDuration? duration,
    double? linePosition,
    AccidentalType? accidentalType,
    bool? showAccidental,
    Color? color,
    bool? stemUp,
  }) {
    return Note(
      midiPitch: midiPitch ?? this.midiPitch,
      duration: duration ?? this.duration,
      linePosition: linePosition ?? this.linePosition,
      accidentalType: accidentalType ?? this.accidentalType,
      showAccidental: showAccidental ?? this.showAccidental,
      color: color ?? this.color,
      stemUp: stemUp ?? this.stemUp,
    );
  }

  /// Creates a copy of this note with a new staff line
  Note copyWithStaffLine(double newStaffLine) {
    return Note(
      midiPitch: midiPitch,
      duration: duration,
      linePosition: newStaffLine,
      accidentalType: accidentalType,
      showAccidental: showAccidental,
      color: color,
      stemUp: stemUp,
    );
  }

  /// Creates a copy of this note with a new stem direction
  Note copyWithStemDirection(bool stemUp) {
    return Note(
      midiPitch: midiPitch,
      duration: duration,
      linePosition: linePosition,
      accidentalType: accidentalType,
      showAccidental: showAccidental,
      color: color,
      stemUp: stemUp,
    );
  }

  /// Gets the note name (e.g., "C", "D#", "Eb")
  String getNoteName({bool useFlats = false}) {
    if (midiPitch == -1) return "Rest";

    final sharpNames = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B'
    ];

    final flatNames = [
      'C',
      'Db',
      'D',
      'Eb',
      'E',
      'F',
      'Gb',
      'G',
      'Ab',
      'A',
      'Bb',
      'B'
    ];

    final noteIndex = midiPitch % 12;
    final octave = (midiPitch ~/ 12) - 1;

    // Use flats if explicitly requested or if the note has a flat accidental
    final shouldUseFlats = useFlats || accidentalType == AccidentalType.flat;
    final noteNames = shouldUseFlats ? flatNames : sharpNames;
    final name = noteNames[noteIndex];

    return '$name$octave';
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

  /// Get the pitch class of the note (0-11)
  int get pitchClass => midiPitch % 12;

  void setStaffLine(double line) {
    // Implementation needed
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
