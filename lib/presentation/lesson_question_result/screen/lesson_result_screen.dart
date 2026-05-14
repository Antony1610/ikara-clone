import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/lessons/question_result.dart';
import 'package:ikara_clone/data/model/model.dart';

class LessonResultScreen extends StatelessWidget {
  final LessonResult result;
  const LessonResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          result.lessonTitle,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
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
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => context.pop(),
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
