import 'package:flutter/services.dart';
import 'package:ikara_clone/data/karaoke/midi_reader.dart';
import 'package:ikara_clone/data/model/practices/midi_note_practices.dart';

class MidiParse {
  Future<List<MidiNotePractices>> parseFromPathAsync(String path) async {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();
    return parse(bytes);
  }

  List<MidiNotePractices> parse(Uint8List bytes) {
    final reader = MidiReader(bytes);
    if (reader.readString(4) != "MThd") {
      throw Exception('Không phải file Midi hợp lệ');
    }
    reader.readUInt(); // header length
    final _ = reader.readUShort(); // format
    final trackCount = reader.readUShort();
    final ticksPerBeat = reader.readUShort();
    final List<List<RawEvent>> rawTracks = [];
    for (int i = 0; i < trackCount; i++) {
      rawTracks.add(reader.readTrack());
    }

    int microsecondsPerBeat = 500000; // default 120 bpm
    List<MapEntry<int, int>> tempoMap = [];
    for (var track in rawTracks) {
      for (var event in track) {
        if (event is RawMetaEvent) {
          if (event.type == 0x51) {
            microsecondsPerBeat =
                (event.data[0] << 16 | event.data[1] << 8 | event.data[2]);
            tempoMap.add(MapEntry(event.tick, microsecondsPerBeat));
          }
        }
      }
    }

    int tickToMs(int tick) {
      if (tempoMap.isEmpty) {
        return (tick * microsecondsPerBeat) ~/ (ticksPerBeat * 1000);
      }
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

    final List<MidiNotePractices> notes = [];
    final Map<int, RawMidiEvent> activeNotes = {};
    for (var track in rawTracks) {
      for (var event in track) {
        if (event is! RawMidiEvent) continue;
        // Note on
        if (event.type == 0x09 && event.data2 > 0) {
          activeNotes[event.data1] = event;
        }

        // Note off
        if (event.type == 0x08 || (event.type == 0x09 && event.data2 == 0)) {
          final startData = activeNotes[event.data1];
          if (startData != null) {
            final startMs = tickToMs(startData.tick);
            final endMs = tickToMs(event.tick);
            notes.add(
              MidiNotePractices(
                midiPitch: event.data1,
                startMs: startMs,
                durationMs: endMs - startMs,
                velocity: event.data2,
                channel: event.channel,
              ),
            );
            activeNotes.remove(event.data1);
          }
        }
      }
    }
    return notes;
  }
}
