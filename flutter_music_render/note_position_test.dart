import 'lib/src/engraving/clef.dart';
import 'lib/src/engraving/staff_model.dart';

void main() {
  print('Note positioning test:');

  // Test treble clef
  final trebleModel = StaffModel(clef: Clef.treble);

  // Test various notes in treble clef - IMPORTANT REFERENCE POSITIONS
  testNotePosition(
      trebleModel, 60, 'C4 (Middle C)', 'first ledger line below staff (5)');
  testNotePosition(trebleModel, 64, 'E4', 'first line from bottom (2)');
  testNotePosition(trebleModel, 67, 'G4', 'second line from bottom (1)');
  testNotePosition(trebleModel, 71, 'B4', 'middle line (0)');
  testNotePosition(trebleModel, 74, 'D5', 'fourth line (-1)');
  testNotePosition(trebleModel, 77, 'F5', 'top line (-2)');
  testNotePosition(trebleModel, 79, 'G5', 'first ledger line above staff (-3)');
  testNotePosition(trebleModel, 72, 'C5', 'space above middle line (-0.5)');
  testNotePosition(
      trebleModel, 84, 'C6', 'fourth ledger line above staff (-6)');

  // Test bass clef
  print('\nBass clef test:');
  final bassModel = StaffModel(clef: Clef.bass);

  // Test various notes in bass clef - IMPORTANT REFERENCE POSITIONS
  testNotePosition(bassModel, 43, 'G2', 'first line from top (-2)');
  testNotePosition(bassModel, 45, 'A2', 'space below top line (-1.5)');
  testNotePosition(bassModel, 47, 'B2', 'second line from top (-1)');
  testNotePosition(bassModel, 50, 'D3', 'middle line (0)');
  testNotePosition(bassModel, 53, 'F3', 'fourth line from top (1)');
  testNotePosition(bassModel, 55, 'G3', 'space above bottom line (1.5)');
  testNotePosition(bassModel, 57, 'A3', 'bottom line (2)');
  testNotePosition(
      bassModel, 60, 'C4 (Middle C)', 'first ledger line above staff (-3)');
  testNotePosition(bassModel, 33, 'A1', 'first ledger line below staff (3)');
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
