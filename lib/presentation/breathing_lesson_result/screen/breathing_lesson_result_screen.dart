import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';

class BreathingLessonResultScreen extends StatelessWidget {
  final String id;
  final int score;
  final String type;
  final double duration;
  const BreathingLessonResultScreen({
    super.key,
    required this.id,
    required this.score,
    required this.type,
    required this.duration,
  });

  int get _startsCount {
    if (score >= 90) return 3;
    if (score >= 60) return 2;
    if (score >= 30) return 1;
    return 0;
  }


  bool get canGoNext => score >= 30;

  @override
  Widget build(BuildContext context) {
    final int starts = _startsCount;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AnimatedAppBar(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/breathing'),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(
            'Tập thở với "$type"',
            style: TextStyle(fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.primaryText,
            ),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          iconTheme: IconThemeData(color: AppColors.primaryText),
          titleSpacing: 0,
          elevation: 0,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.firstMainBackground,
              AppColors.secMainBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Text(
                'Bạn đã hoàn thành bài tập thở\nvới "$type" trong ${duration.toInt()}s',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Roboto',
                    color: AppColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final bool isActive = index < starts;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      Icons.star_rounded,
                      size: 80,
                      color: isActive
                          ? AppColors.starColor
                          : AppColors.unfinishQuest,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              // Vòng tròn hiển thị điểm
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        value: (score / 100).clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.starColor,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score/100',
                          style: TextStyle(fontFamily: 'Roboto',
                            color: AppColors.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (canGoNext) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonInsideLesson,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => context.pop(),
                    child: Text(
                      'Bài tập tiếp theo',
                      style: TextStyle(fontFamily: 'Roboto',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canGoNext
                        ? AppColors.lockText
                        : AppColors.buttonInsideLesson,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () => context.go('/breathingDetail/$id'),
                  child: Text(
                    'Thử lại',
                    style: TextStyle(fontFamily: 'Roboto',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
              SizedBox(height: 20,)
            ],
          ),
        ),
      ),
    );
  }
}
