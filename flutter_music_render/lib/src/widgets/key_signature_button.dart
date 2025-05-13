import 'package:flutter/material.dart';
import 'package:flutter_music_render/src/engraving/key_signature.dart'
    as key_sig;

/// A button that allows selecting a key signature
class KeySignatureButton extends StatelessWidget {
  final key_sig.KeySignature currentKey;
  final Function(key_sig.KeySignature) onKeySelected;

  const KeySignatureButton({
    super.key,
    required this.currentKey,
    required this.onKeySelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<key_sig.KeySignature>(
      icon: const Icon(Icons.music_note),
      tooltip: 'Select Key Signature',
      onSelected: onKeySelected,
      itemBuilder: (context) => [
        _buildKeyMenuItem(key_sig.Key.c, 'C Major'),
        _buildKeyMenuItem(key_sig.Key.bb, 'B♭ Major'),
        _buildKeyMenuItem(key_sig.Key.e, 'E Major'),
        _buildKeyMenuItem(key_sig.Key.db, 'D♭ Major'),
      ],
    );
  }

  PopupMenuItem<key_sig.KeySignature> _buildKeyMenuItem(
      key_sig.Key key, String label) {
    final keySignature = key_sig.KeySignature(key: key);
    return PopupMenuItem<key_sig.KeySignature>(
      value: keySignature,
      child: Text(label),
    );
  }
}
