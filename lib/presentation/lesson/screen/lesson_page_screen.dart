import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/lessons_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/presentation/lesson/bloc/lesson_bloc.dart';
import 'package:ikara_clone/presentation/lesson/widget/lesson_node.dart';

class LessonPageScreen extends StatelessWidget {
  const LessonPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          LessonBloc(ctx.read<LessonsRepository>(), ctx.read<UserRepository>(), FirebaseAuth.instance.currentUser!.uid)..add(LoadParts()),
      child: const _LessonPageView(),
    );
  }
}

class _LessonPageView extends StatelessWidget {
  const _LessonPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "Bài học",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(child: _LessonList()),
      ),
    );
  }
}

class _LessonList extends StatefulWidget {
  const _LessonList();

  @override
  State<_LessonList> createState() => _LessonListState();
}

class _LessonListState extends State<_LessonList> {
  final ScrollController _scrollController = ScrollController();
  static const double _itemHeight = 300.0;
  static const double _partHeaderWidth = 342.0;
  static const double _partToLessonSpacing = 48.0;
  bool _isTapInProgress = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LessonBloc>().state;
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final topPadding = appBarHeight + 24;
    final bottomPadding = (screenHeight / 2) - 100;

    if (state is LessonLoading || state is LessonInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LessonError) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: AppColors.lockText),
        ),
      );
    }

    if (state is! PartsLoaded) return const SizedBox.shrink();

    final lessonRows =
        <
          ({
            Lesson lesson,
            String partTitle,
            String partId,
            bool isFirstOfPart,
            bool isLastOfPart,
            int globalIndex,
          })
        >[];
    var globalIndex = 0;



    for (final part in state.parts) {
      for (var i = 0; i < part.lessons.length; i++) {
        lessonRows.add((
          lesson: part.lessons[i],
          partTitle: part.title,
          partId: part.indexId,
          isFirstOfPart: i == 0,
          isLastOfPart: i == part.lessons.length - 1,
          globalIndex: globalIndex,
        ));
        globalIndex++;
      }
    }
    final userResult = state.userResults;
    bool isUnlocked(int globalIndex){
      if (globalIndex == 0) return true;
      final prevRow = lessonRows[globalIndex - 1];
      try {
        final prevResult = userResult.firstWhere((r) => r.id == prevRow.lesson.id);
        return prevResult.process == 100;
      } catch (_) {
        return false;
      }
    }

    final currentIndex = state.currentIndex;

    if (lessonRows.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bài học',
          style: TextStyle(color: AppColors.primaryText),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('lesson-list'),
      controller: _scrollController,
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      itemCount: lessonRows.length,
      itemBuilder: (context, index) {
        final row = lessonRows[index];
        final lesson = row.lesson;
        final isCurrent = index == currentIndex;
        final isLastInPart = row.isLastOfPart;
        final unlocked = isUnlocked(index);
        // int lessonProcess = 0;
        // try {
        //   final result = state.userResults.firstWhere((r) => r.id == lesson.id);
        //   lessonProcess = result.process;
        // } catch (_) {}

        return Column(
          children: [
            if (row.isFirstOfPart) ...[
              if (index != 0) const SizedBox(height: 40),
              Center(
                child: Container(
                  width: _partHeaderWidth,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.partColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    row.partTitle,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: AppColors.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: _partToLessonSpacing),
            ],
            GestureDetector(
              onTap: unlocked ? () async {
                if (_isTapInProgress) return;
                _isTapInProgress = true;

                context.read<LessonBloc>().add(LessonPageIndexChanged(index));

                final partId = row.partId;
                final lessonId = lesson.indexId;
                debugPrint(
                  '[LessonPage] Tap lesson: partIndexId=$partId, lessonIndexId=$lessonId, title=${lesson.lessonTitle}',
                );

                try {
                  await _scrollController.animateTo(
                    index * _itemHeight,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );

                  if (!context.mounted) return;
                  _isTapInProgress = false;
                  await context.push('/lessonDetail/$partId/$lessonId');
                  if (context.mounted) {
                    context.read<LessonBloc>().add(LoadParts());
                  }
                } catch (_) {
                } finally {
                  if (mounted) {
                    _isTapInProgress = false;
                  }
                }
              } : null,
              child: LessonNode(
                isCurrent: isCurrent,
                isPrev: false,
                isNext: false,
                child: Stack(

                  children: [
                    Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.lessBorderColor,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blackShadow,
                          blurRadius: isCurrent ? 18 : 6,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/lessons/lesson_${(index % 19) + 1}.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: AppColors.lockText,
                          size: 32,
                        ),
                      ),
                    ),
                    ),
                    if (!unlocked)
                      Positioned.fill(child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black12
                        ),
                        child: Center(child: Icon(Icons.lock, color: AppColors.primaryText, size: 32,)),
                      ),
                      )
                  ]
                ),
              ),
            ),

            const SizedBox(height: 8),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isCurrent ? 1.0 : 0.5,
              child: SizedBox(
                width: isCurrent ? 226 : 172 ,
                child: Text(
                  lesson.lessonTitle.isNotEmpty
                      ? lesson.lessonTitle
                      : 'Bài ${lesson.id}',
                  style: TextStyle(
                    color: unlocked ? AppColors.primaryText : AppColors.hintText,
                    fontSize: isCurrent ? 14 : 12,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            if (!isLastInPart)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: CustomPaint(
                  size: const Size(2, 40),
                  painter: _DashedLinePainter(),
                ),
              )
            else
              const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.primaryText
      ..strokeWidth = 2;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}
