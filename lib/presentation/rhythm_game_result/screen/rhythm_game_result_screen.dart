import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/presentation/rhythm_game_result/bloc/rhythm_game_result_bloc.dart';

class RhythmGameResultScreen extends StatelessWidget {
  final RhythmsResult result;
  const RhythmGameResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RhythmGameResultBloc()..add(LoadResultEvent(result)),
      child: const _RhythmResultView(),
    );
  }
}

class _RhythmResultView extends StatelessWidget {
  const _RhythmResultView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.firstMainBackground, AppColors.secMainBackground],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AnimatedAppBar(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go('/rhythm'),
              icon: const Icon(Icons.arrow_back_ios),
            ),
            title: Text(
              'Luyện nhịp điệu cơ bản',
              style: GoogleFonts.roboto(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            iconTheme: const IconThemeData(color: AppColors.primaryText),
            titleSpacing: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<RhythmGameResultBloc, RhythmGameResultState>(
            builder: (context, state) {
              if (state is RhythmGameResultInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is RhythmGameResultLoaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      Text(
                        state.feedbackMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          color: AppColors.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          bool isEarned = index < state.starCount;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Icon(
                              Icons.star,
                              size: 64,
                              color: isEarned
                                  ? AppColors.starColor
                                  : AppColors.lockText,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 50),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(
                            value: state.result.perfect.toString(),
                            label: 'Đúng nhịp',
                            color: AppColors.partColor,
                          ),
                          _buildStatItem(
                            value: state.result.miss.toString(),
                            label: 'Lỡ nhịp',
                            color: AppColors.primaryText,
                          ),
                          _buildStatItem(
                            value: state.result.late.toString(),
                            label: 'Chậm nhịp',
                            color: AppColors.primaryText,
                          ),
                          _buildStatItem(
                            value: state.result.early.toString(),
                            label: 'Sớm nhịp',
                            color: AppColors.primaryText,
                          ),
                        ],
                      ),

                      const Spacer(),

                      if (state.isPassed) ...[
                        if (state.result.nextId != null) ...[
                          _buildButton(
                            text: 'Bài tập tiếp theo',
                            backgroundColor: AppColors.buttonInsideLesson,
                            textColor: Colors.white,
                            onPressed: () => context.pushReplacement('/rhythm/${state.result.nextId}'),
                          ),
                          const SizedBox(height: 16),
                        ],
                        _buildButton(
                          text: 'Thử lại',
                          backgroundColor: AppColors.tryAgainButton,
                          textColor: AppColors.primaryText,
                          onPressed: () => context.pushReplacement('/rhythm/${state.result.rhythmId}'),
                        ),
                      ] else ...[
                        _buildButton(
                          text: 'Thử lại',
                          backgroundColor: AppColors.tryAgainButton,
                          textColor: Colors.white,
                          onPressed: () => context.pushReplacement('/rhythm/${state.result.rhythmId}'),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.roboto(
            color: AppColors.primaryText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.roboto(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
