import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../model/performances/kar_song.dart';
import '../model/performances/lyrics_token.dart';
import '../model/performances/midi_note.dart';
import 'midi_reader.dart';


// TCVN3 support

const _tcvn3Chars = {
  'µ','¸','¶','·','¹','¨','»','¾','¼','½','Æ','©','Ç','Ê','È','É','Ë','®',
  'Ì','Ð','Î','Ï','Ñ','ª','Ò','Õ','Ó','Ô','Ö','×','Ý','Ø','Ü','Þ','ß','ã',
  'á','â','ä','«','å','è','æ','ç','é','¬','ê','í','ë','ì','î','ï','ó','ñ',
  'ò','ô','­','õ','ø','ö','÷','ù','ú','ý','û','ü','þ',
};

bool _isTCVN3(String text) =>
    text.runes.any((r) => _tcvn3Chars.contains(String.fromCharCode(r)));

String _convertTCVN3(String text) {
  const tcvn3 = ['µ','¸','¶','·','¹','¨','»','¾','¼','½','Æ','©','Ç','Ê','È','É','Ë','®','Ì','Ð','Î','Ï','Ñ','ª','Ò','Õ','Ó','Ô','Ö','×','Ý','Ø','Ü','Þ','ß','ã','á','â','ä','«','å','è','æ','ç','é','¬','ê','í','ë','ì','î','ï','ó','ñ','ò','ô','­','õ','ø','ö','÷','ù','ú','ý','û','ü','þ'];
  const unicode = ['à','á','ả','ã','ạ','ă','ằ','ắ','ẳ','ẵ','ặ','â','ầ','ấ','ẩ','ẫ','ậ','đ','è','é','ẻ','ẽ','ẹ','ê','ề','ế','ể','ễ','ệ','ì','í','ỉ','ĩ','ị','ò','ó','ỏ','õ','ọ','ô','ồ','ố','ổ','ỗ','ộ','ơ','ờ','ớ','ở','ỡ','ợ','ù','ú','ủ','ũ','ụ','ư','ừ','ứ','ử','ữ','ự','ỳ','ý','ỷ','ỹ','ỵ'];
  for (int i = 0; i < tcvn3.length; i++) {
    text = text.replaceAll(tcvn3[i], unicode[i]);
  }
  return text;
}


// Decoder

String _decodeUtf16LE(Uint8List data) {
  final chars = <int>[];
  for (int i = 0; i + 1 < data.length; i += 2) {
    final code = data[i] | (data[i + 1] << 8);
    // Loại bỏ các ký tự điều khiển MIDI bị lẫn vào text (0x00-0x1F) ngoại trừ \n, \r
    if (code > 0x1F || code == 0x0A || code == 0x0D) {
      chars.add(code);
    }
  }
  return String.fromCharCodes(chars);
}

String decodeLyric(Uint8List data, {String? encoding}) {
  if (data.isEmpty) return '';

  // Ưu tiên tuyệt đối encoding được khai báo trong file
  if (encoding == 'UTF-16LE') {
    return _decodeUtf16LE(data);
  }

  // Fallback an toàn cho tiếng Việt
  try {
    final text = utf8.decode(data);
    if (_isTCVN3(text)) return _convertTCVN3(text);
    return text;
  } catch (_) {
    final text = latin1.decode(data, allowInvalid: true);
    if (_isTCVN3(text)) return _convertTCVN3(text);
    return text;
  }
}

class KarParser {
  KarSong parse(Uint8List bytes) {
    final reader = MidiReader(bytes);
    if (reader.readString(4) != "MThd") throw Exception("Không phải file MIDI hợp lệ");

    reader.readUInt(); // header length
    final _ = reader.readUShort(); // format
    final trackCount = reader.readUShort();
    final ticksPerBeat = reader.readUShort();

    final List<List<RawEvent>> rawTracks = [];
    for (int i = 0; i < trackCount; i++) {
      rawTracks.add(reader.readTrack());
    }

    int microsecondsPerBeat = 500000;
    List<MapEntry<int, int>> tempoMap = [];
    int timeSigNum = 4;
    int timeSigDen = 4;
    String trackTitle = "";
    String? wordsEncoding;

    // Tìm tag Encoding và Meta data
    for (var track in rawTracks) {
      for (var event in track) {
        if (event is RawMetaEvent) {
          if (event.type == 0x01) {
            // Dùng allowMalformed để không chết app khi gặp byte lạ ở tag metadata
            final text = utf8.decode(event.data, allowMalformed: true);
            if (text.contains('[Words]')) {
              if (text.contains('UTF-16LE')) wordsEncoding = 'UTF-16LE';
              if (text.contains('UTF-8')) wordsEncoding = 'UTF-8';
            }
          }
          if (event.type == 0x03 && trackTitle.isEmpty) {
            trackTitle = utf8.decode(event.data, allowMalformed: true);
          }
          if (event.type == 0x51) {
            microsecondsPerBeat = ((event.data[0] & 0xFF) << 16) | ((event.data[1] & 0xFF) << 8) | (event.data[2] & 0xFF);
            tempoMap.add(MapEntry(event.tick, microsecondsPerBeat));
          }
          if (event.type == 0x58) {
            timeSigNum = event.data[0];
            timeSigDen = pow(2, event.data[1]).toInt();
          }
        }
      }
    }

    int tickToMs(int tick) {
      if (tempoMap.isEmpty) return (tick * microsecondsPerBeat) ~/ (ticksPerBeat * 1000);
      double ms = 0;
      int prevTick = 0;
      int prevTempo = 500000;
      for (var entry in tempoMap) {
        if (entry.key >= tick) break;
        ms += (entry.key - prevTick) * prevTempo / ticksPerBeat / 1000;
        prevTick = entry.key;
        prevTempo = entry.value;
      }
      ms += (tick - prevTick) * prevTempo / ticksPerBeat / 1000;
      return ms.round();
    }

    final List<LyricsToken> lyrics = [];
    final List<MidiNote> notes = [];
    final Map<int, Map<int, MapEntry<int, int>>> noteOnMap = {};

    // Xử lý Lyrics và Notes
    for (var track in rawTracks) {
      for (var event in track) {
        if (event is RawMetaEvent && (event.type == 0x01 || event.type == 0x05)) {
          String text = decodeLyric(event.data, encoding: wordsEncoding);

          // Loại bỏ các ký tự dư thừa
          text = text.replaceAll('\u0000', '').trim();

          if (text.startsWith('@') ||
              text.toLowerCase().contains('soft') ||
              text.toLowerCase().contains('karakan') ||
              text.toLowerCase().contains('words') ||
              text.isEmpty) {
            continue;
          }

          if (event.tick == 0 && !text.startsWith('\\') && !text.startsWith('/')) {
            continue;
          }

          final bool isNewVerse = text.startsWith('\\');
          final bool isNewLine = text.  startsWith('/');
          String cleanText = (isNewVerse || isNewLine) ? text.substring(1) : text;
          cleanText = cleanText.replaceAll(RegExp(r'[^\p{L}\p{N}\p{P}\p{Z}]', unicode: true), '');
          if (cleanText.trim().isNotEmpty) {
            lyrics.add(LyricsToken(
              text: cleanText,
              startMs: tickToMs(event.tick),
              isNewLine: isNewLine,
              isNewVerse: isNewVerse,
            ));
          }
        } else if (event is RawMidiEvent) {
          // Note on
          if (event.type == 0x09 && event.data2 > 0) {
            noteOnMap.putIfAbsent(event.channel, () => {})[event.data1] = MapEntry(event.tick, event.data2);
          }
          // Note off
          else if (event.type == 0x08 || (event.type == 0x09 && event.data2 == 0)) {
            final startData = noteOnMap[event.channel]?.remove(event.data1);
            if (startData != null) {
              final int startMs = tickToMs(startData.key);
              final int endMs = tickToMs(event.tick);
              notes.add(MidiNote(
                midiPitch: event.data1,
                startMs: startMs,
                durationMs: endMs - startMs,
                velocity: startData.value,
                channel: event.channel,
              ));
            }
          }
        }
      }
    }

    int maxTick = rawTracks.fold(0, (max, t) => (t.isNotEmpty && t.last.tick > max) ? t.last.tick : max);

    return KarSong(
      title: trackTitle,
      bpm: 60000000 ~/ microsecondsPerBeat,
      timeSignatureNumerator: timeSigNum,
      timeSignatureDenominator: timeSigDen,
      totalDurationMs: tickToMs(maxTick),
      lyrics: lyrics..sort((a, b) => a.startMs.compareTo(b.startMs)),
      notes: notes,
    );
  }
}