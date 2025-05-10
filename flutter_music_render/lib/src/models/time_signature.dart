/// Represents a musical time signature.
class TimeSignature {
  /// The number of beats per measure
  final int numerator;

  /// The note value that receives one beat
  final int denominator;

  /// Creates a new time signature.
  const TimeSignature(this.numerator, this.denominator);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSignature &&
          runtimeType == other.runtimeType &&
          numerator == other.numerator &&
          denominator == other.denominator;

  @override
  int get hashCode => numerator.hashCode ^ denominator.hashCode;
}
