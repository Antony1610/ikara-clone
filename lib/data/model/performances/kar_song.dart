import 'package:ikara_clone/data/model/performances/lyrics_token.dart';
import 'package:ikara_clone/data/model/performances/midi_note.dart';

class KarSong {
  final String title;
  final int bpm;
  final int timeSignatureNumerator;
  final int timeSignatureDenominator;
  final int totalDurationMs;
  final List<LyricsToken> lyrics;
  final List<MidiNote> notes;

  KarSong({
    required this.title,
    required this.bpm,
    required this.timeSignatureNumerator,
    required this.timeSignatureDenominator,
    required this.totalDurationMs,
    required this.lyrics,
    required this.notes
});
}