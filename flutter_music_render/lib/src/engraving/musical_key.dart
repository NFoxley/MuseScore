/// Represents a musical key
enum MusicalKey {
  c, // C major / A minor
  g, // G major / E minor
  d, // D major / B minor
  a, // A major / F# minor
  e, // E major / C# minor
  b, // B major / G# minor
  fs, // F# major / D# minor
  cs, // C# major / A# minor
  f, // F major / D minor
  bb, // Bb major / G minor
  eb, // Eb major / C minor
  ab, // Ab major / F minor
  db, // Db major / Bb minor
  gb, // Gb major / Eb minor
  cb, // Cb major / Ab minor
}

extension MusicalKeyDisplay on MusicalKey {
  String get displayName {
    switch (this) {
      case MusicalKey.c:
        return 'C';
      case MusicalKey.g:
        return 'G';
      case MusicalKey.d:
        return 'D';
      case MusicalKey.a:
        return 'A';
      case MusicalKey.e:
        return 'E';
      case MusicalKey.b:
        return 'B';
      case MusicalKey.fs:
        return 'F♯';
      case MusicalKey.cs:
        return 'C♯';
      case MusicalKey.f:
        return 'F';
      case MusicalKey.bb:
        return 'B♭';
      case MusicalKey.eb:
        return 'E♭';
      case MusicalKey.ab:
        return 'A♭';
      case MusicalKey.db:
        return 'D♭';
      case MusicalKey.gb:
        return 'G♭';
      case MusicalKey.cb:
        return 'C♭';
    }
  }
}
