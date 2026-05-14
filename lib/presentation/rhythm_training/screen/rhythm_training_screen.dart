import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikara_clone/constants/app_colors.dart';
import 'package:ikara_clone/data/model/rhythms/rhythms.dart';
import 'package:ikara_clone/data/repositories/rhythms_repository.dart';
import 'package:ikara_clone/presentation/rhythm_training/bloc/rhythm_training_bloc.dart';

class RhythmTrainingScreen extends StatefulWidget {
  const RhythmTrainingScreen({super.key});

  @override
  State<RhythmTrainingScreen> createState() => _RhythmTrainingScreenState();
}

class _RhythmTrainingScreenState extends State<RhythmTrainingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          RhythmTrainingBloc(ctx.read<RhythmsRepository>())..add(RhythmLoad()),
      child: const _RhythmPageView(),
    );
  }
}


class _RhythmPageView extends StatelessWidget {
  const _RhythmPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Luyện nhịp',
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
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
        child: SafeArea(child: const _RhythmLessonList()),
      ),
    );
  }
}



class _RhythmLessonList extends StatefulWidget {
  const _RhythmLessonList();

  @override
  State<_RhythmLessonList> createState() => _RhythmLessonListState();
}

class _RhythmLessonListState extends State<_RhythmLessonList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RhythmTrainingBloc, RhythmTrainingState>(
      builder: (context, state) {
        return switch (state) {
          RhythmInitial() || RhythmLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.progressColor),
          ),
          RhythmError(:final message) => Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          RhythmLoaded(:final parts) => _RhythmListView(parts),
        };
      },
    );
  }
}



class _RhythmListView extends StatelessWidget {
  final List<RhythmsPart> parts;
  const _RhythmListView(this.parts);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: const PageStorageKey('rhythm-list'),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      itemCount: parts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _RhythmPartCard(
        part: parts[index],
        isLocked: index > 0,
        stars: 0, // TODO: user progress
      ),
    );
  }
}


class _RhythmPartCard extends StatelessWidget {
  final RhythmsPart part;
  final bool isLocked;
  final int stars;

  const _RhythmPartCard({
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
          color: isLocked
              ? AppColors.buttonLesson
              : AppColors.lessonFocusColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? AppColors.lockText : AppColors.lessBorderColor,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Text(
              part.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isLocked ? AppColors.lockText : AppColors.primaryText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

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

            Text(
              isLocked
                  ? 'Hoàn thành bài trước để mở khoá'
                  : (stars == 0 ? 'Hãy bắt đầu nào!' : 'Tiếp tục luyện tập!'),
              style: const TextStyle(fontSize: 10, color: AppColors.lockText),
            ),
            const SizedBox(height: 14),

            isLocked ? const _LockedButton() : _StartButton(part: part),
          ],
        ),
      ),
    );
  }
}


class _StartButton extends StatelessWidget {
  final RhythmsPart part;
  const _StartButton({required this.part});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          context.push('/rhythm/${part.id}');
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
          style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w600),
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
            style: GoogleFonts.roboto(
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
