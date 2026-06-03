import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/presentation/performance_results/bloc/performance_results_bloc.dart';

class PerformanceResultsScreen extends StatefulWidget {
  final int score;
  const PerformanceResultsScreen({super.key, required this.score});

  @override
  State<PerformanceResultsScreen> createState() =>
      _PerformanceResultsScreenState();
}

class _PerformanceResultsScreenState extends State<PerformanceResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          PerformanceResultsBloc()..add(LoadPerformanceResult(widget.score)),
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
            AppColors.firstMainBackground,
            AppColors.secMainBackground
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<PerformanceResultsBloc, PerformanceResultsState>(
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
                      const SizedBox(height: 20),
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
                      _buildButton(
                        text: 'Kết thúc',
                        backgroundColor: AppColors.buttonInsideLesson,
                        textColor: AppColors.primaryText,
                        onPressed: () => context.go('/performance'),
                      ),
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
      width: 342,
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
}
