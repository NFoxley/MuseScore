/// Represents a musical key signature with its number of accidentals and type
class KeySignature {
  final int accidentals;
  final bool isSharp;

  const KeySignature(this.accidentals, {required this.isSharp});

  /// Order of sharps in key signatures
  static const List<String> sharpOrder = ['F', 'C', 'G', 'D', 'A', 'E', 'B'];

  /// Order of flats in key signatures
  static const List<String> flatOrder = ['B', 'E', 'A', 'D', 'G', 'C', 'F'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeySignature &&
          runtimeType == other.runtimeType &&
          accidentals == other.accidentals &&
          isSharp == other.isSharp;

  @override
  int get hashCode => accidentals.hashCode ^ isSharp.hashCode;
}
