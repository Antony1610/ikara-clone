import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/breaths/breaths.dart';
import 'package:ikara_clone/data/repositories/breaths_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/presentation/breathing_lesson/bloc/breathing_bloc.dart';

class BreathingLessonScreen extends StatefulWidget {
  const BreathingLessonScreen({super.key});

  @override
  State<BreathingLessonScreen> createState() => _BreathingLessonScreenState();
}

class _BreathingLessonScreenState extends State<BreathingLessonScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => BreathingBloc(
        ctx.read<BreathsRepository>(),
        FirebaseAuth.instance.currentUser!.uid,
        ctx.read<UserRepository>(),
      )..add(BreathingPartLoad()),
      child: const _BreathingPageView(),
    );
  }
}

// Page

class _BreathingPageView extends StatelessWidget {
  const _BreathingPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Luyện hơi thở',
          style: TextStyle(
            fontFamily: 'Roboto',

            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        child: SafeArea(child: const _BreathingLessonList()),
      ),
    );
  }
}

class _BreathingLessonList extends StatefulWidget {
  const _BreathingLessonList();

  @override
  State<_BreathingLessonList> createState() => _BreathingLessonListState();
}

class _BreathingLessonListState extends State<_BreathingLessonList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BreathingBloc, BreathingState>(
      builder: (context, state) {
        return switch (state) {
          BreathingInitial() || BreathingLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.progressColor),
          ),
          BreathingError(:final message) => Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          PartsLoaded(:final parts, :final starCount) => _PartListView(
            parts,
            starCount,
          ),
        };
      },
    );
  }
}

class _PartListView extends StatelessWidget {
  final List<BreathsPart> parts;
  final Map<int, int> starCount;
  const _PartListView(this.parts, this.starCount);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const PageStorageKey('breathing-list'),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      itemCount: parts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final isLocked = index > 0 && (starCount[parts[index - 1].id] ?? 0) < 1;
        return _BreathingPartCard(
          part: parts[index],
          isLocked: isLocked,
          stars: starCount[parts[index].id] ?? 0,
        );
      },
    );
  }
}

class _BreathingPartCard extends StatelessWidget {
  final BreathsPart part;
  final bool isLocked;
  final int stars;

  const _BreathingPartCard({
    required this.part,
    required this.isLocked,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLocked ? 0.65 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? AppColors.buttonLesson : AppColors.lessonFocusColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? AppColors.lockText : AppColors.lessBorderColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            // Title
            Text(
              part.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isLocked ? AppColors.lockText : AppColors.primaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final filled = !isLocked && i < stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.star_rounded,
                    size: 30,
                    color: filled ? AppColors.starColor : AppColors.lockText,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),

            // Hint
            Text(
              isLocked
                  ? 'Hoàn thành bài trước để mở khoá'
                  : (stars == 0 ? 'Hãy bắt đầu nào!' : 'Tiếp tục luyện tập!'),
              style: const TextStyle(fontSize: 10, color: AppColors.lockText),
            ),
            const SizedBox(height: 14),

            // Button
            isLocked ? const _LockedButton() : _StartButton(part: part),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final BreathsPart part;
  const _StartButton({required this.part});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          context.go('/breathingDetail/${part.partId}');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonInsideLesson,
          foregroundColor: AppColors.primaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
        ),
        child: Text(
          'Bắt đầu',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LockedButton extends StatelessWidget {
  const _LockedButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.buttonLesson,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.lockText),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 10, color: AppColors.lockText),
          const SizedBox(width: 7),
          Text(
            'Bắt đầu',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.lockText,
            ),
          ),
        ],
      ),
    );
  }
}
