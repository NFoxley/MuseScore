import 'package:flutter_music_render/flutter_music_render.dart';

/// Represents a single note in a melody with its timing and properties
class MelodyNote {
  final String letterName; // A-G
  final int octave; // 4 for C4, 5 for C5, etc.
  final AccidentalType accidentalType;
  final double duration;
  final bool isTied;

  MelodyNote({
    required this.letterName,
    required this.octave,
    this.accidentalType = AccidentalType.none,
    required this.duration,
    this.isTied = false,
  });

  /// Get the accidental symbol (♯, ♭, ♮, 𝄪, 𝄫)
  String? get accidental {
    switch (accidentalType) {
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
      case AccidentalType.none:
        return null;
    }
  }

  /// Get the full note name with accidental (e.g., "C♯4", "B♭3", "F♮5")
  String get fullName => accidental != null
      ? '$letterName$accidental$octave'
      : '$letterName$octave';

  /// Compute MIDI pitch from letter, accidental, and octave
  int get midiPitch => _getMidiPitch(letterName, accidentalType, octave);

  static int _getMidiPitch(
      String letter, AccidentalType accidental, int octave) {
    final base = {
      'C': 0,
      'D': 2,
      'E': 4,
      'F': 5,
      'G': 7,
      'A': 9,
      'B': 11,
    }[letter.toUpperCase()]!;
    int offset = 0;
    switch (accidental) {
      case AccidentalType.sharp:
        offset = 1;
        break;
      case AccidentalType.flat:
        offset = -1;
        break;
      case AccidentalType.doubleSharp:
        offset = 2;
        break;
      case AccidentalType.doubleFlat:
        offset = -2;
        break;
      default:
        offset = 0;
    }
    return (octave + 1) * 12 + base + offset;
  }

  factory MelodyNote.fromJson(Map<String, dynamic> json) {
    return MelodyNote(
      letterName: json['letterName'] as String,
      octave: json['octave'] as int,
      accidentalType: AccidentalType.values.firstWhere(
        (e) => e.toString() == 'AccidentalType.${json['accidentalType']}',
        orElse: () => AccidentalType.none,
      ),
      duration: (json['duration'] as num).toDouble(),
      isTied: json['isTied'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letterName': letterName,
      'octave': octave,
      'accidentalType': accidentalType.toString().split('.').last,
      'duration': duration,
      'isTied': isTied,
    };
  }

  /// Create a note from a letter name, accidental, octave, and duration
  factory MelodyNote.fromName(
      String letterName, String? accidental, int octave, double duration) {
    final accidentalType = _getAccidentalType(accidental);
    return MelodyNote(
      letterName: letterName,
      octave: octave,
      accidentalType: accidentalType,
      duration: duration,
    );
  }

  static AccidentalType _getAccidentalType(String? accidental) {
    switch (accidental) {
      case '♯':
        return AccidentalType.sharp;
      case '♭':
        return AccidentalType.flat;
      case '𝄪':
        return AccidentalType.doubleSharp;
      case '𝄫':
        return AccidentalType.doubleFlat;
      case '♮':
        return AccidentalType.natural;
      case null:
        return AccidentalType.none;
      default:
        throw ArgumentError('Invalid accidental: $accidental');
    }
  }
}

/// Represents a complete melody with its properties and notes
class MelodyProfile {
  final String id;
  final String name;
  final MusicalKey key;
  final Clef clef;
  final TimeSignature? timeSignature;
  final List<MelodyNote> notes;
  final String? description;
  final int difficulty; // 1-5 scale

  MelodyProfile({
    required this.id,
    required this.name,
    required this.key,
    required this.clef,
    this.timeSignature,
    required this.notes,
    this.description,
    this.difficulty = 1,
  });

  factory MelodyProfile.fromJson(Map<String, dynamic> json) {
    return MelodyProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      key: MusicalKey.values.firstWhere(
        (e) => e.toString() == 'MusicalKey.${json['key']}',
      ),
      clef: Clef.values.firstWhere(
        (e) => e.toString() == 'Clef.${json['clef']}',
      ),
      timeSignature: json['timeSignature'] != null
          ? TimeSignature(
              json['timeSignature']['numerator'] as int,
              json['timeSignature']['denominator'] as int,
            )
          : null,
      notes: (json['notes'] as List)
          .map((note) => MelodyNote.fromJson(note as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'key': key.toString().split('.').last,
      'clef': clef.toString().split('.').last,
      'timeSignature': timeSignature != null
          ? {
              'numerator': timeSignature!.numerator,
              'denominator': timeSignature!.denominator,
            }
          : null,
      'notes': notes.map((note) => note.toJson()).toList(),
      'description': description,
      'difficulty': difficulty,
    };
  }
}

/// Example melodies for testing and demonstration
class ExampleMelodies {
  static final List<MelodyProfile> melodies = [
    MelodyProfile(
      id: 'melody_001',
      name: 'Simple C Major Scale',
      key: MusicalKey.c,
      clef: Clef.treble,
      timeSignature: TimeSignature(4, 4),
      notes: [
        MelodyNote.fromName('C', null, 4, 1.0), // C4
        MelodyNote.fromName('D', null, 4, 1.0), // D4
        MelodyNote.fromName('E', null, 4, 1.0), // E4
        MelodyNote.fromName('F', null, 4, 1.0), // F4
        MelodyNote.fromName('G', null, 4, 1.0), // G4
        MelodyNote.fromName('A', null, 4, 1.0), // A4
        MelodyNote.fromName('B', null, 4, 1.0), // B4
        MelodyNote.fromName('C', null, 5, 1.0), // C5
      ],
      description: 'A simple ascending C major scale',
      difficulty: 1,
    ),
    MelodyProfile(
      id: 'melody_002',
      name: 'E Major with Accidentals',
      key: MusicalKey.e,
      clef: Clef.treble,
      timeSignature: TimeSignature(3, 4),
      notes: [
        MelodyNote.fromName('E', null, 4, 1.0), // E4
        MelodyNote.fromName('F', null, 4, 0.5), // F4
        MelodyNote.fromName('F', '♯', 4, 0.5), // F#4
        MelodyNote.fromName('G', null, 4, 1.0), // G4
        MelodyNote.fromName('G', '♮', 4, 1.0), // G-natural
      ],
      description: 'A melody in E major with some accidentals',
      difficulty: 2,
    ),
    MelodyProfile(
      id: 'melody_003',
      name: 'D-flat Major Exercise',
      key: MusicalKey.db,
      clef: Clef.treble,
      timeSignature: TimeSignature(4, 4),
      notes: [
        MelodyNote.fromName('C', '♯', 4, 1.0), // C#4/Db4
        MelodyNote.fromName('D', '♯', 4, 1.0), // D#4/Eb4
        MelodyNote.fromName('F', '♯', 4, 1.0), // F#4/Gb4
        MelodyNote.fromName('F', '♮', 4, 1.0), // F-natural
        MelodyNote.fromName('G', '♭', 4, 1.0), // Gb4
      ],
      description: 'A melody in D-flat major with natural signs',
      difficulty: 3,
    ),
  ];

  /// Convert all example melodies to JSON
  static List<Map<String, dynamic>> toJson() {
    return melodies.map((melody) => melody.toJson()).toList();
  }

  /// Load melodies from JSON
  static List<MelodyProfile> fromJson(List<Map<String, dynamic>> json) {
    return json.map((melody) => MelodyProfile.fromJson(melody)).toList();
  }
}
