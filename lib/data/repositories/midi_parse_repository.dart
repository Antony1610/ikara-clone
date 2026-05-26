import 'package:ikara_clone/data/model/practices/midi_note_practices.dart';

abstract class MidiParseRepository {
  Future<List<MidiNotePractices>> getMidiNotes(String midiPath);
}