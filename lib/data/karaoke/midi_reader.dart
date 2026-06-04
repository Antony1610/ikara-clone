import 'dart:typed_data';
import 'dart:convert';

abstract class RawEvent {
  final int tick;
  RawEvent(this.tick);
}

class RawMetaEvent extends RawEvent {
  final int type;
  final Uint8List data;
  RawMetaEvent(super.tick, this.type, this.data);
}

class RawMidiEvent extends RawEvent {
  final int type;
  final int channel;
  final int data1;
  final int data2;
  RawMidiEvent(super.tick, this.type, this.channel, this.data1, this.data2);
}

class MidiReader {
  final Uint8List buf;
  int pos = 0;
  MidiReader(this.buf);

  int readByte() => buf[pos++] & 0xFF; // 1 byte
  int readUShort() => (readByte() << 8) | readByte(); // 2 bytes
  int readUInt() => (readUShort() << 16) | readUShort(); // 4 bytes

  int readVarLen() {
    int value = 0;
    int b;
    do {
      b = readByte();
      value = (value << 7) | (b & 0x7F);
    } while ((b & 0x80) != 0);
    return value;
  }

  String readString(int len) {
    final s = latin1.decode(buf.sublist(pos, pos + len));
    pos += len;
    return s;
  }

  List<RawEvent> readTrack() {
    final id = readString(4);
    final len = readUInt();
    if (id != "MTrk") {
      pos += len;
      return [];
    }
    final end = pos + len;
    final List<RawEvent> events = [];
    int tick = 0;
    int runningStatus = 0;

    while (pos < end) {
      tick += readVarLen();
      int statusByte = readByte();

      if ((statusByte & 0x80) == 0) {
        pos--;
        statusByte = runningStatus;
      } else if (statusByte < 0xF0) {
        runningStatus = statusByte;
      }

      if (statusByte == 0xFF) {
        int type = readByte();
        int vLen = readVarLen();
        events.add(RawMetaEvent(tick, type, buf.sublist(pos, pos + vLen)));
        pos += vLen;
      } else if (statusByte >= 0xF0) {
        int vLen = readVarLen();
        pos += vLen;
      } else {
        int type = (statusByte >> 4) & 0x0F;
        int channel = statusByte & 0x0F;
        int d1 = readByte();
        int d2 = (type == 0x0C || type == 0x0D) ? 0 : readByte();
        events.add(RawMidiEvent(tick, type, channel, d1, d2));
      }
    }
    return events;
  }
}