import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/presentation/lesson_detail/bloc/lesson_detail_bloc.dart';
import 'package:ikara_clone/presentation/lesson_detail/widget/video_player_widget.dart';
import 'package:ikara_clone/presentation/lesson_question/screen/lesson_questions_sheet.dart';

class LessonDetailPageScreen extends StatefulWidget {
  final String partId;
  final String lessonId;

  const LessonDetailPageScreen({
    super.key,
    required this.lessonId,
    required this.partId,
  });

  @override
  State<LessonDetailPageScreen> createState() => _LessonDetailPageScreenState();
}

class _LessonDetailPageScreenState extends State<LessonDetailPageScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      LessonDetailBloc(context.read<LessonsRepository>())
        ..add(LoadLessonDetail(widget.partId, widget.lessonId)),
      child: myBody(),
    );
  }

  Widget myBody() {
    return BlocBuilder<LessonDetailBloc, LessonDetailState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: state is LessonDetailLoaded
              ? AnimatedAppBar(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 60,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  height: 40,
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
                          onPressed: () => context.pop(),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          state.lesson.lessonTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: 'Roboto',
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              : null,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LessonDetailState state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.firstMainBackground, AppColors.secMainBackground],
        ),
      ),
      child: SafeArea(
        child: switch (state) {
          LessonDetailInitial() || LessonDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          LessonDetailError() => Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          LessonDetailLoaded() => AnimatedContent(
            key: ValueKey('lesson-detail-${state.lesson.id}'),
            child: _VideoSection(state: state),
          ),
        },
      ),
    );
  }
}

class _VideoSection extends StatelessWidget {
  final LessonDetailLoaded state;

  const _VideoSection({required this.state});


  void _openQuizSheet(BuildContext context) {
    final bloc = context.read<LessonDetailBloc>();
    bloc.add(QuizSheetOpened());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {

        return DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 1,
          maxChildSize: 1,
          expand: true,
          builder: (ctx, scrollController) {
            return BlocProvider.value(
              value: bloc,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.firstMainBackground,
                ),
                child: LessonQuestionsSheet(
                  partId: state.partId,
                  lessonId: state.lesson.indexId,
                  lessonRealId: state.lesson.id,
                  title: state.lesson.lessonTitle,
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      bloc.add(QuizSheetClosed());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                VideoPlayerWidget(videoUrl: state.lesson.videoUrl),
                const SizedBox(height: 16),
                _myFocus(state),
              ],
            ),
          ),
        ),
        _toQuiz(context, state),
      ],
    );
  }

  Widget _myFocus(LessonDetailLoaded state) {
    if (state.lesson.lessonFocus.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lessonFocusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Điểm tập trung cho buổi học này:',
            style: TextStyle(fontFamily: 'Roboto',
              color: AppColors.primaryText,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          ...state.lesson.lessonFocus.map(
                (focus) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $focus',
                style: TextStyle(fontFamily: 'Roboto',
                  color: AppColors.primaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toQuiz(BuildContext context, LessonDetailLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _openQuizSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.progressColor,
            foregroundColor: AppColors.primaryText,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            'Trả lời câu hỏi',
            style: TextStyle(fontFamily: 'Roboto',
              fontSize: 18,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}