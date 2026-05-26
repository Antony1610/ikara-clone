import 'package:ikara_clone/data/karaoke/midi_parse.dart';
import 'package:ikara_clone/data/model/practices/midi_note_practices.dart';
import 'package:ikara_clone/data/repositories/midi_parse_repository.dart';

class MidiParseRepositoryImpl implements MidiParseRepository{

  final _midiParse = MidiParse();
  @override
  Future<List<MidiNotePractices>> getMidiNotes(String midiPath) {
    return _midiParse.parseFromPathAsync(midiPath);
  }
  
}