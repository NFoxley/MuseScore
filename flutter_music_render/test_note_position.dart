import 'lib/src/engraving/clef.dart';
import 'lib/src/engraving/staff_model.dart';

void main() {
  print('Note positioning test:');

  // Test treble clef
  final trebleModel = StaffModel(clef: Clef.treble);

  // Test various notes in treble clef
  testNotePosition(trebleModel, 60, 'C4', 'first ledger line below staff (5)');
  testNotePosition(trebleModel, 62, 'D4', 'space below bottom line (4)');
  testNotePosition(trebleModel, 64, 'E4', 'bottom line (3)');
  testNotePosition(trebleModel, 67, 'G4', 'second line from bottom (1)');
  testNotePosition(trebleModel, 71, 'B4', 'middle line (0)');
  testNotePosition(trebleModel, 72, 'C5', 'space above middle line (-0.5)');
  testNotePosition(trebleModel, 76, 'E5', 'top line (-2)');
  testNotePosition(trebleModel, 79, 'G5', 'space above top line (-3.5)');

  // Test bass clef
  final bassModel = StaffModel(clef: Clef.bass);

  // Test various notes in bass clef
  testNotePosition(bassModel, 43, 'G2', 'bottom line (3)');
  testNotePosition(bassModel, 48, 'C3', 'middle line (0)');
  testNotePosition(bassModel, 53, 'F3', 'top line (-2)');
  testNotePosition(bassModel, 60, 'C4', 'space above top line (-4.5)');
}

void testNotePosition(
    StaffModel model, int midiPitch, String noteName, String expectedPosition) {
  final staffLine = model.calculateStaffLine(midiPitch);
  print(
      '${model.clef} clef: $noteName (MIDI $midiPitch) staff line: $staffLine');
  print('  Expected position: $expectedPosition');

  // Check if there are ledger lines needed
  final ledgerLines =
      model.needsLedgerLine(staffLine) ? model.getLedgerLines(staffLine) : [];
  print('  Ledger lines needed: ${ledgerLines.isNotEmpty ? 'Yes' : 'No'}');
  if (ledgerLines.isNotEmpty) {
    print('  Ledger line positions: $ledgerLines');
  }
  print('');
}
