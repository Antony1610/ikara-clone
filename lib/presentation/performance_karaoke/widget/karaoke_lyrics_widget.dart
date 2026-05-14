import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/performances/lyrics_token.dart';

class KaraokeLyricsWidget extends StatefulWidget {
  final List<LyricsToken> tokens;
  final int currentMs;

  const KaraokeLyricsWidget({
    super.key,
    required this.tokens,
    required this.currentMs,
  });

  @override
  State<KaraokeLyricsWidget> createState() => _KaraokeLyricsWidgetState();
}

class _KaraokeLyricsWidgetState extends State<KaraokeLyricsWidget> {
  // Tìm index của từ đang hát dựa trên thời gian thực tế
  int _activeIndex() {
    if (widget.tokens.isEmpty) return -1;
    int result = -1;
    for (int i = 0; i < widget.tokens.length; i++) {
      if (widget.tokens[i].startMs <= widget.currentMs) {
        result = i;
      } else {
        break;
      }
    }
    return result;
  }

  // Chia danh sách tokens thành các dòng dựa trên isNewLine hoặc isNewVerse
  List<_LyricLine> _buildLines() {
    final List<_LyricLine> lines = [];
    _LyricLine current = _LyricLine();
    for (int i = 0; i < widget.tokens.length; i++) {
      final t = widget.tokens[i];
      // Nếu gặp ký hiệu xuống dòng và dòng hiện tại đã có chữ, thì ngắt dòng
      if ((t.isNewVerse || t.isNewLine) && current.tokens.isNotEmpty) {
        lines.add(current);
        current = _LyricLine();
      }
      current.tokens.add(MapEntry(i, t));
    }
    if (current.tokens.isNotEmpty) lines.add(current);
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tokens.isEmpty) return const SizedBox.shrink();

    final activeIdx = _activeIndex();
    final lines = _buildLines();

    // Tìm dòng hiện tại chứa từ đang hát
    int activeLineIdx = 0;
    for (int l = 0; l < lines.length; l++) {
      if (lines[l].tokens.any((e) => e.key == activeIdx)) {
        activeLineIdx = l;
        break;
      }
    }

    // Luôn hiển thị 2 dòng: Dòng hiện tại và dòng tiếp theo
    final line1 = activeLineIdx < lines.length ? lines[activeLineIdx] : null;
    final line2 = activeLineIdx + 1 < lines.length ? lines[activeLineIdx + 1] : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (line1 != null)
          _buildLineWidget(line1, activeIdx, isCurrentLine: true),
        const SizedBox(height: 12),
        if (line2 != null)
          _buildLineWidget(line2, activeIdx, isCurrentLine: false),
      ],
    );
  }

  Widget _buildLineWidget(
      _LyricLine line,
      int activeIdx, {
        required bool isCurrentLine,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4, // Khoảng cách giữa các từ
        children: line.tokens.map((entry) {
          final tokenIdx = entry.key;
          final token = entry.value;

          // Logic màu sắc
          Color textColor;
          if (!isCurrentLine) {
            // Dòng tiếp theo: Hiện màu trắng mờ để chuẩn bị
            textColor = AppColors.primaryText;
          } else {
            if (tokenIdx <= activeIdx) {
              // Từ đã hát qua hoặc đang hát: Màu nổi bật (Vàng/Cam)
              textColor = AppColors.karaokeText;
            } else {
              // Từ sắp tới trong dòng hiện tại: Màu trắng
              textColor = AppColors.primaryText;
            }
          }

          return AnimatedDefaultTextStyle(
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1))
                ],
              ),
            ),
            duration: const Duration(milliseconds: 200),
            child: Text(token.text),
          );
        }).toList(),
      ),
    );
  }
}

class _LyricLine {
  final List<MapEntry<int, LyricsToken>> tokens = [];
}