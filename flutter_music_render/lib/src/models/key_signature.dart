/// Represents a musical key signature.
class KeySignature {
  /// The name of the key signature
  final String name;

  /// Whether this key signature uses sharps (true) or flats (false)
  final bool isSharp;

  /// The notes affected by this key signature
  final Set<String> affectedNotes;

  /// The list of accidentals in this key signature
  final List<String> accidentals;

  const KeySignature({
    required this.name,
    required this.isSharp,
    required this.affectedNotes,
    required this.accidentals,
  });

  /// The number of accidentals in the key signature
  int get accidentalCount => affectedNotes.length;

  /// The order of sharps: F C G D A E B
  static const List<String> sharpOrder = ['F', 'C', 'G', 'D', 'A', 'E', 'B'];

  /// The order of flats: B E A D G C F
  static const List<String> flatOrder = ['B', 'E', 'A', 'D', 'G', 'C', 'F'];

  /// Get the ordered list of affected notes according to sharp/flat order
  List<String> get orderedAffectedNotes {
    final order = isSharp ? sharpOrder : flatOrder;
    return order.where((note) => affectedNotes.contains(note)).toList();
  }

  /// C major / A minor (no sharps or flats)
  static const cMajor = KeySignature(
    name: 'C Major',
    isSharp: true,
    affectedNotes: {},
    accidentals: [],
  );

  /// G major / E minor (1 sharp)
  static const gMajor = KeySignature(
    name: 'G Major',
    isSharp: true,
    affectedNotes: {'F'},
    accidentals: ['♯'],
  );

  /// D major / B minor (2 sharps)
  static const dMajor = KeySignature(
    name: 'D Major',
    isSharp: true,
    affectedNotes: {'F', 'C'},
    accidentals: ['♯', '♯'],
  );

  /// A major / F# minor (3 sharps)
  static const aMajor = KeySignature(
    name: 'A Major',
    isSharp: true,
    affectedNotes: {'F', 'C', 'G'},
    accidentals: ['♯', '♯', '♯'],
  );

  /// E major / C# minor (4 sharps)
  static const eMajor = KeySignature(
    name: 'E Major',
    isSharp: true,
    affectedNotes: {'F', 'C', 'G', 'D'},
    accidentals: ['♯', '♯', '♯', '♯'],
  );

  /// B major / G# minor (5 sharps)
  static const bMajor = KeySignature(
    name: 'B Major',
    isSharp: true,
    affectedNotes: {'F', 'C', 'G', 'D', 'A'},
    accidentals: ['♯', '♯', '♯', '♯', '♯'],
  );

  /// F# major / D# minor (6 sharps)
  static const fSharpMajor = KeySignature(
    name: 'F# Major',
    isSharp: true,
    affectedNotes: {'F', 'C', 'G', 'D', 'A', 'E'},
    accidentals: ['♯', '♯', '♯', '♯', '♯', '♯'],
  );

  /// C# major / A# minor (7 sharps)
  static const cSharpMajor = KeySignature(
    name: 'C# Major',
    isSharp: true,
    affectedNotes: {'F', 'C', 'G', 'D', 'A', 'E', 'B'},
    accidentals: ['♯', '♯', '♯', '♯', '♯', '♯', '♯'],
  );

  /// F major / D minor (1 flat)
  static const fMajor = KeySignature(
    name: 'F Major',
    isSharp: false,
    affectedNotes: {'B'},
    accidentals: ['♭'],
  );

  /// Bb major / G minor (2 flats)
  static const bFlatMajor = KeySignature(
    name: 'Bb Major',
    isSharp: false,
    affectedNotes: {'B', 'E'},
    accidentals: ['♭', '♭'],
  );

  /// Eb major / C minor (3 flats)
  static const eFlatMajor = KeySignature(
    name: 'Eb Major',
    isSharp: false,
    affectedNotes: {'B', 'E', 'A'},
    accidentals: ['♭', '♭', '♭'],
  );

  /// Ab major / F minor (4 flats)
  static const aFlatMajor = KeySignature(
    name: 'Ab Major',
    isSharp: false,
    affectedNotes: {'B', 'E', 'A', 'D'},
    accidentals: ['♭', '♭', '♭', '♭'],
  );

  /// Db major / Bb minor (5 flats)
  static const dFlatMajor = KeySignature(
    name: 'Db Major',
    isSharp: false,
    affectedNotes: {'B', 'E', 'A', 'D', 'G'},
    accidentals: ['♭', '♭', '♭', '♭', '♭'],
  );

  /// Gb major / Eb minor (6 flats)
  static const gFlatMajor = KeySignature(
    name: 'Gb Major',
    isSharp: false,
    affectedNotes: {'B', 'E', 'A', 'D', 'G', 'C'},
    accidentals: ['♭', '♭', '♭', '♭', '♭', '♭'],
  );

  /// Cb major / Ab minor (7 flats)
  static const cFlatMajor = KeySignature(
    name: 'Cb Major',
    isSharp: false,
    affectedNotes: {'B', 'E', 'A', 'D', 'G', 'C', 'F'},
    accidentals: ['♭', '♭', '♭', '♭', '♭', '♭', '♭'],
  );
}
