import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/presentation/practices_results/bloc/practices_results_bloc.dart';

class PracticesResultsScreen extends StatefulWidget {
  final int score;
  final PracticesPart practicesPart;
  final String status;
  const PracticesResultsScreen({
    super.key,
    required this.score,
    required this.practicesPart,
    required this.status,
  });

  @override
  State<PracticesResultsScreen> createState() => _PracticesResultsScreenState();
}

class _PracticesResultsScreenState extends State<PracticesResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => PracticesResultsBloc()
        ..add(
          LoadPracticesResult(
            widget.score,
            widget.practicesPart,
            widget.status,
          ),
        ),
      child: _ResultScreen(),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.firstBackgroundPractices,
            AppColors.firstBackgroundPractices,
            AppColors.secMainBackground,
            AppColors.thirdBackgroundPractices,
          ],
          stops: [0.0, 0.1, 0.3786, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<PracticesResultsBloc, PracticesResultsState>(
            builder: (context, state) {
              if (state is InitialResult || state is LoadingResult) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.buttonInsideLesson,
                  ),
                );
              }
          
              if (state is ErrorResult) {
                return Center(
                  child: Text(
                    state.message,
                    style: TextStyle(color: Colors.redAccent),
                  ),
                );
              }
          
              if (state is LoadedResult) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20,),
                      Text(
                        'Điểm số của bạn',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        state.feedbackText,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          bool isEarned = index < state.stars;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(
                              Icons.star,
                              size: 36,
                              color: isEarned
                                  ? AppColors.pracStarColor
                                  : AppColors.lockText,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        height: 160,
                        width: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.buttonInsideLesson,
                            width: 6,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${state.score}',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w900,
                              fontSize: 60,
                              color: AppColors.pracScoreColor,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (state.isPass) ...[
                        _buildOutlineButton(
                          text: 'Bắt đầu lại',
                          borderColor: AppColors.buttonInsideLesson,
                          textColor: AppColors.primaryText,
                          onPressed: () => context.pushReplacement(
                            '/practices/${state.practicesPart.indexId}',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildButton(
                          text: 'Kết thúc',
                          backgroundColor: AppColors.buttonInsideLesson,
                          textColor: AppColors.primaryText,
                          onPressed: () => context.go('/practices'),
                        ),
                      ] else ...[
                        _buildButton(
                          text: 'Bắt đầu lại',
                          backgroundColor: AppColors.buttonInsideLesson,
                          textColor: AppColors.primaryText,
                          onPressed: () => context.go(
                            '/practices/${state.practicesPart.indexId}',
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
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
          style: TextStyle(
            fontFamily: 'Roboto',
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: borderColor),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
