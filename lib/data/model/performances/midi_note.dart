import 'dart:math';

class MidiNote {
  final int midiPitch;
  final int startMs;
  int durationMs;
  final int velocity;
  final int channel;
  MidiNote({
    required this.midiPitch,
    required this.startMs,
    required this.durationMs,
    required this.velocity,
    required this.channel,
  });

  String get noteName {
    const name = [
      "C",
      "C#",
      "D",
      "D#",
      "E",
      "F",
      "F#",
      "G",
      "G#",
      "A",
      "A#",
      "B",
    ];
    return name[midiPitch % 12];
  }

  int get octave => (midiPitch ~/ 12) - 1;
  double get frequencyHz => 440.0 * pow(2.0, (midiPitch - 69)/ 12.0);
}
