import 'package:flutter/material.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/performances/lyrics_token.dart';

class KaraokeLyricsWidget extends StatelessWidget {
  final List<LyricsToken> tokens;
  final ValueNotifier<int> currentMsNotifier;

  const KaraokeLyricsWidget({
    super.key,
    required this.tokens,
    required this.currentMsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentMsNotifier,
      builder: (context, ms, _) {
        return CustomPaint(
          painter: LyricsPaint(tokens: tokens, currentMs: ms),
          size: const Size(double.infinity, 200),
        );
      },
    );
  }
}

//
// class KaraokeTokenWord extends StatefulWidget {
//   final int tokenIdx;
//   final LyricsToken token;
//   final ValueNotifier<int> activeIdxNotifier;
//   final ValueNotifier<bool> isCurrentLine;
//   const KaraokeTokenWord({
//     super.key,
//     required this.tokenIdx,
//     required this.token,
//     required this.activeIdxNotifier,
//     required this.isCurrentLine,
//   });
//
//   @override
//   State<KaraokeTokenWord> createState() => _KaraokeTokenWordState();
// }
//
// class _KaraokeTokenWordState extends State<KaraokeTokenWord>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<Color?> _colorAim;
//   late bool _isHighLight;
//
//   @override
//   void initState() {
//     super.initState();
//     _isHighLight =
//         widget.isCurrentLine.value &&
//         (widget.tokenIdx <= widget.activeIdxNotifier.value);
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//       value: _isHighLight ? 1.0 : 0.0,
//     );
//     _colorAim = ColorTween(
//       begin: AppColors.primaryText,
//       end: AppColors.karaokeText,
//     ).animate(_controller);
//     widget.activeIdxNotifier.addListener(_onActiveIdxChanged);
//     widget.isCurrentLine.addListener(_onActiveIdxChanged);
//   }
//
//   @override
//   void didUpdateWidget(covariant KaraokeTokenWord old) {
//     super.didUpdateWidget(old);
//     if (old.activeIdxNotifier != widget.activeIdxNotifier) {
//       old.activeIdxNotifier.removeListener(_onActiveIdxChanged);
//       widget.activeIdxNotifier.addListener(_onActiveIdxChanged);
//     }
//     _isHighLight =
//         widget.isCurrentLine.value &&
//         (widget.tokenIdx <= widget.activeIdxNotifier.value);
//   }
//
//   void _onActiveIdxChanged() {
//     final shouldHighLight =
//         widget.isCurrentLine.value &&
//         (widget.tokenIdx <= widget.activeIdxNotifier.value);
//     if (shouldHighLight == _isHighLight) return;
//     _isHighLight = shouldHighLight;
//     shouldHighLight ? _controller.forward() : _controller.stop();
//   }
//
//   @override
//   void dispose() {
//     widget.activeIdxNotifier.removeListener(_onActiveIdxChanged);
//     widget.isCurrentLine.removeListener(_onActiveIdxChanged);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _colorAim,
//       builder: (context, child) => Text(
//         widget.token.text,
//         style: TextStyle(
//           fontFamily: 'OpenSans',
//           fontSize: 18,
//           color: _colorAim.value,
//           fontWeight: FontWeight.w700,
//           shadows: const [
//             Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _LyricLine {
//   final List<MapEntry<int, LyricsToken>> tokens = [];
//   final ValueNotifier<bool> isCurrentLineNotifier = ValueNotifier<bool>(false);
// }

class LyricsPaint extends CustomPainter {
  final List<LyricsToken> tokens;
  final int currentMs;

  final List<List<(int, LyricsToken)>> _lines;
  LyricsPaint({required this.tokens, required this.currentMs})
    : _lines = _groupLine(tokens);

  static List<List<(int, LyricsToken)>> _groupLine(List<LyricsToken> tokens) {
    final list = <List<(int, LyricsToken)>>[];
    var current = <(int, LyricsToken)>[];
    for (int i = 0; i < tokens.length; i++) {
      if ((tokens[i].isNewLine || tokens[i].isNewVerse) && current.isNotEmpty) {
        list.add(current);
        current = [];
      }
      current.add((i, tokens[i]));
    }
    if (current.isNotEmpty) {
      list.add(current);
    }
    return list;
  }

  static final normalLyrics = TextStyle(
    fontSize: 18,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    shadows: const [
      Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
    ],
  );

  static final highlightLyrics = TextStyle(
    fontSize: 18,
    fontFamily: 'OpenSans',
    fontWeight: FontWeight.w700,
    color: AppColors.karaokeText,
    shadows: const [
      Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
    ],
  );
  @override
  void paint(Canvas canvas, Size size) {
    int activeIdx = _findActiveIdx();
    int activeLine = _findActiveLine(activeIdx);
    double lineHeight = 35.0;
    double startY = (size.height / 2) - (lineHeight / 2);
    for (int i = activeLine; i <= activeLine + 1; i++) {
      if (i >= _lines.length) {
        break;
      }
      double y = startY + ((i - activeLine) * lineHeight);
      if (y < -lineHeight || y > size.height) {
        continue;
      }
      double x = 20.0;
      final spans = <InlineSpan>[];
      final currentLine = _lines[i];
      for (final item in currentLine) {
        final tokenIdx = item.$1;
        final token = item.$2;

        bool isActive = tokenIdx <= activeIdx;
        spans.add(
          TextSpan(
            text: "${token.text} ",
            style: isActive ? highlightLyrics : normalLyrics,
          ),
        );
      }
      final textSpan = TextSpan(children: spans);
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      x += (size.width - tp.width) / 2;
      tp.paint(canvas, Offset(x, y));
    }
  }

  int _findActiveIdx() {
    int low = 0;
    int high = tokens.length - 1;
    int best = -1;
    while (low <= high) {
      int mid = (low + high) >> 1;
      if (tokens[mid].startMs <= currentMs) {
        best = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return best;
  }

  int _findActiveLine(int activeIdx) {
    if (activeIdx == -1) return 0;
    int low = 0;
    int high = _lines.length - 1;
    int best = -1;
    while (low <= high) {
      int mid = (low + high) >> 1;
      if (_lines[mid].first.$1 <= activeIdx) {
        best = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return best;
  }

  @override
  bool shouldRepaint(covariant LyricsPaint oldDelegate) =>
      oldDelegate.currentMs != currentMs;
}
