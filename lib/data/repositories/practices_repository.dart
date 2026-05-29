import 'package:ikara_clone/data/model/model.dart';

import '../model/practices/midi_note_practices.dart';

abstract class PracticesRepository {
  Future<List<PracticesPart>> getListPractices();
  Future<PracticesPart?> getPractices(String id);
  Future<List<MidiNotePractices>> getMidiNotes(String midiPath);

}