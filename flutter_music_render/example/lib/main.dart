import 'package:flutter/material.dart';
import 'package:flutter_music_render/flutter_music_render.dart';
import 'package:flutter_music_render/src/engraving/clef.dart';
import 'package:flutter_music_render/src/engraving/key_signature.dart'
    as key_sig;
import 'package:flutter_music_render/src/engraving/note.dart';
import 'package:flutter_music_render/src/engraving/time_signature.dart';
import 'package:flutter_music_render/src/widgets/key_signature_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Music Render Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Music Render Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Clef _selectedClef = Clef.treble;
  key_sig.KeySignature _selectedKey = key_sig.KeySignature(key: key_sig.Key.c);
  TimeSignature _timeSignature = TimeSignature(4, 4);
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _generateNotes();
  }

  void _generateNotes() {
    // Generate some example notes
    _notes = [
      Note(
          midiPitch: 60, duration: NoteDuration.quarter, linePosition: 0), // C4
      Note(
          midiPitch: 62, duration: NoteDuration.quarter, linePosition: 0), // D4
      Note(
          midiPitch: 64, duration: NoteDuration.quarter, linePosition: 0), // E4
      Note(
          midiPitch: 65, duration: NoteDuration.quarter, linePosition: 0), // F4
      Note(
          midiPitch: 67, duration: NoteDuration.quarter, linePosition: 0), // G4
      Note(
          midiPitch: 69, duration: NoteDuration.quarter, linePosition: 0), // A4
      Note(
          midiPitch: 71, duration: NoteDuration.quarter, linePosition: 0), // B4
      Note(
          midiPitch: 72, duration: NoteDuration.quarter, linePosition: 0), // C5
    ];
  }

  void _onClefChanged(Clef clef) {
    setState(() {
      _selectedClef = clef;
    });
  }

  void _onKeyChanged(key_sig.KeySignature key) {
    setState(() {
      _selectedKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clef selection
                DropdownButton<Clef>(
                  value: _selectedClef,
                  items: Clef.values.map((clef) {
                    return DropdownMenuItem<Clef>(
                      value: clef,
                      child: Text(clef.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (Clef? newValue) {
                    if (newValue != null) {
                      _onClefChanged(newValue);
                    }
                  },
                ),
                const SizedBox(width: 16),
                // Key signature selection
                KeySignatureButton(
                  currentKey: _selectedKey,
                  onKeySelected: _onKeyChanged,
                ),
              ],
            ),
          ),
          Expanded(
            child: Staff(
              clef: _selectedClef,
              keySignature: _selectedKey,
              timeSignature: _timeSignature,
              notes: _notes,
            ),
          ),
        ],
      ),
    );
  }
}
