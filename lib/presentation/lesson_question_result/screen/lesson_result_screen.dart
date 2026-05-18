import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/lessons/question_result.dart';
import 'package:ikara_clone/data/model/model.dart';

class LessonResultScreen extends StatelessWidget {
  final LessonResult result;
  const LessonResultScreen({super.key, required this.result});

  void _showScoreDialog(BuildContext context) {
    final score = (result.correctCount / result.totalQuestion * 100).round();

    final message = switch (score) {
      100 =>
        "Chúc mừng! Bạn đã đạt điểm tuyệt đối. Kiến thức của bạn thật sự rộng lớn.",
      >= 80 => "Rất tốt! Bạn có kiến thức vững chắc.",
      >= 60 => "Khá tốt! Ôn tập để cải thiện thêm.",
      _ => "Bạn cần luyện tập thêm. Hãy tiếp tục cố gắng!",
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.infinity,
          height: 334,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.firstPopupResult, AppColors.secPopupResult],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 80,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1.5
                          ..color = AppColors.textBorderResult,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.firstScore,
                          AppColors.secScore,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    color: AppColors.hintText,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => ctx.pop(),
                  child: Container(
                    width: 150,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: AppColors.buttonInsideLesson,
                    ),
                    child: Center(
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showScoreDialog(context);
    });
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          result.lessonTitle,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.firstMainBackground,
              AppColors.secMainBackground,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: result.questionResults.length,
                itemBuilder: (context, i) {
                  final qr = result.questionResults[i];
                  return _buildQuestionReview(qr, i);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16,left: 16, right: 16, bottom: 16 + MediaQuery.of(context).padding.bottom),
              child: GestureDetector(
                onTap: () => context.pop(true),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: AppColors.buttonInsideLesson,
                  ),
                  child: Center(
                    child: Text(
                      'Kết thúc',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionReview(QuestionResult qr, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.unfinishQuest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.finishQuest,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  qr.question.question,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(qr.question.options.length, (i) {
            final option = qr.question.options[i];
            final isCorrect = option == qr.question.correctAnswer;
            final isSelected = option == qr.selectedAnswer;
            Color borderColor = AppColors.unSelectedOption;
            if (isCorrect) borderColor = Colors.green;
            if (isSelected && !isCorrect) borderColor = Colors.red;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.backgroundOptions,
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Text(
                '${String.fromCharCode(65 + i)}. $option',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.primaryText,
                  fontSize: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
