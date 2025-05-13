import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';

/// A button that allows selecting a key signature
class KeySignatureButton extends StatelessWidget {
  final KeySignature currentKey;
  final Function(KeySignature) onKeySelected;

  const KeySignatureButton({
    super.key,
    required this.currentKey,
    required this.onKeySelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<KeySignature>(
      icon: const Icon(Icons.music_note),
      tooltip: 'Select Key Signature',
      onSelected: onKeySelected,
      itemBuilder: (context) => [
        _buildKeyMenuItem(MusicalKey.c, 'C Major'),
        _buildKeyMenuItem(MusicalKey.bb, 'B♭ Major'),
        _buildKeyMenuItem(MusicalKey.e, 'E Major'),
        _buildKeyMenuItem(MusicalKey.db, 'D♭ Major'),
      ],
    );
  }

  PopupMenuItem<KeySignature> _buildKeyMenuItem(MusicalKey key, String label) {
    final keySignature = KeySignature(key: key);
    return PopupMenuItem<KeySignature>(
      value: keySignature,
      child: Text(label),
    );
  }
}
