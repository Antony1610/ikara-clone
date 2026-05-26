import 'dart:math';

class MidiNotePractices {
  final int midiPitch;
  final int startMs;
  int durationMs;
  final int velocity;
  final int channel;
  MidiNotePractices({
    required this.midiPitch,
    required this.startMs,
    required this.durationMs,
    required this.velocity,
    required this.channel
});

  int get endMs => startMs + durationMs;
  double get frequencyHz => 440.0 * pow(2.0, (midiPitch - 69)/12.0);
}