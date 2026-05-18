import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/lessons/lessons.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/presentation/lesson_question/bloc/lesson_question_bloc.dart';

class LessonQuestionsSheet extends StatefulWidget {
  final String partId;
  final String lessonId;
  final String lessonRealId;
  final String title;

  const LessonQuestionsSheet({
    super.key,
    required this.partId,
    required this.lessonId,
    required this.lessonRealId,
    required this.title,
  });

  @override
  State<LessonQuestionsSheet> createState() => _LessonQuestionsSheetState();
}

class _LessonQuestionsSheetState extends State<LessonQuestionsSheet> {
  Future<void> _showExitDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        alignment: Alignment.center,
        content: const Text(
          'Bạn chắc chắn muốn hủy bài không?',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => ctx.pop(false),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.lockText,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ctx.pop(true),
                child: Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.buttonInsideLesson,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.pop();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LessonQuestionBloc(context.read<LessonsRepository>(), context.read<UserRepository>(), FirebaseAuth.instance.currentUser!.uid)
        ..add(LoadLessonQuestion(widget.partId, widget.lessonId,widget.lessonRealId ,widget.title)),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<LessonQuestionBloc, LessonQuestionState>(
      listenWhen: (prev, curr) =>
      curr is LessonQuestionLoaded &&
          prev is LessonQuestionLoaded &&
          !prev.isCompleted &&
          curr.isCompleted,
      listener: (context, state) {
        if (state is LessonQuestionLoaded &&
            state.isCompleted &&
            state.lessonResult != null) {
          Navigator.of(context).pop();
          context.pushReplacement('/lesson-result', extra: state.lessonResult);
        }
      },
      builder: (context, state) {
        if (state is LessonQuestionLoading || state is LessonQuestionInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.progressColor),
          );
        }

        if (state is LessonQuestionError) {
          return Center(child: Text(state.message));
        }

        if (state is LessonQuestionLoaded) {
          final q = state.questions[state.currentIndex];

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildQuestionIndex(state),
                      const SizedBox(height: 20),
                      _buildQuestionCard(context, state, q),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildBottomButton(state, context),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.primaryText,
                size: 18,
              ),
              onPressed: () => _showExitDialog(context),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionIndex(LessonQuestionLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(state.questions.length, (i) {
        final isActive = i == state.currentIndex;
        return Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.finishQuest : AppColors.unfinishQuest,
            border: Border.all(color: AppColors.questIndexColor),
          ),
          child: Text(
            '${i + 1}',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 12,
              color: AppColors.primaryText,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuestionCard(
      BuildContext context,
      LessonQuestionLoaded state,
      Question question,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.unfinishQuest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (i) {
            final isSelected = state.userAnswer[state.currentIndex] == i;
            return GestureDetector(
              onTap: () {
                context.read<LessonQuestionBloc>().add(SelectAnswer(i));
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.backgroundOptions,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.selectedOption
                        : AppColors.unSelectedOption,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${String.fromCharCode(65 + i)}. ${question.options[i]}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomButton(LessonQuestionLoaded state, BuildContext context) {
    final hasSelected = state.userAnswer[state.currentIndex] != null;
    final isLast = state.currentIndex == state.questions.length - 1;

    if (!hasSelected) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        if (isLast && state.isAllAnswered) {
          context.read<LessonQuestionBloc>().add(SubmitQuiz());
        } else {
          context.read<LessonQuestionBloc>().add(NextQuestion());
        }
      },
      child: _buttonWidget(
        isLast && state.isAllAnswered ? 'Hoàn thành' : 'Câu hỏi tiếp',
      ),
    );
  }

  Widget _buttonWidget(String label) {
    return Container(
      width: double.infinity,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.buttonInsideLesson,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.primaryText,
        ),
      ),
    );
  }
}