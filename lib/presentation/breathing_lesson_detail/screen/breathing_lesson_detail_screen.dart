import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/audio_repository.dart';
import 'package:ikara_clone/data/repositories/breaths_repository.dart';
import 'package:ikara_clone/presentation/breathing_lesson_detail/bloc/breathing_lesson_detail_bloc.dart';

const _dialogTitleStyle = TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w700, fontSize: 18);
const _dialogCancelStyle = TextStyle(fontFamily: 'Roboto', color: AppColors.lockText, fontWeight: FontWeight.w500, fontSize: 16);
const _dialogConfirmStyle = TextStyle(fontFamily: 'Roboto', color: AppColors.buttonInsideLesson, fontWeight: FontWeight.w500, fontSize: 16);
const _appBarTitleStyle = TextStyle(fontFamily: 'Roboto', color: AppColors.primaryText, fontWeight: FontWeight.w700, fontSize: 16);
const _timerStyle = TextStyle(fontFamily: 'Roboto', fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primaryText);
const _richTextBaseStyle = TextStyle(fontFamily: 'Roboto', fontSize: 16, color: AppColors.primaryText, fontWeight: FontWeight.w700);
const _richTextAccentStyle = TextStyle(fontFamily: 'Roboto', color: AppColors.progressColor);
const _buttonTextStyle = TextStyle(fontFamily: 'Roboto', color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600);
const _volumeLabelStyle = TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primaryText);

final _buttonStyle = ElevatedButton.styleFrom(
  backgroundColor: AppColors.buttonInsideLesson,
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
);

class BreathingLessonDetailScreen extends StatefulWidget {
  final String id;
  const BreathingLessonDetailScreen({super.key, required this.id});

  @override
  State<BreathingLessonDetailScreen> createState() =>
      _BreathingLessonDetailScreenState();
}

class _BreathingLessonDetailScreenState extends State<BreathingLessonDetailScreen> {
  late final BreathingLessonDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BreathingLessonDetailBloc(
      repository: context.read<BreathsRepository>(),
      audioRepository: context.read<AudioRepository>(),
    )..add(InitBreathing(widget.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: const _LessonDetailView(),
    );
  }
}

class _LessonDetailView extends StatefulWidget {
  const _LessonDetailView();

  @override
  State<_LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<_LessonDetailView> {
  Future<bool> _showExitDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text('Bạn chắc chắn muốn hủy bài không?', style: _dialogTitleStyle),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy', style: _dialogCancelStyle),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xác nhận', style: _dialogConfirmStyle),
              ),
            ],
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BreathingLessonDetailBloc, BreathingLessonDetailState>(
      listener: (context, state) {
        if (state is DetailCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.pushReplacement('/breathing-result', extra: {
              'id': state.id,
              'score': state.score,
              'type': state.type,
              'duration': state.duration,
            });
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: state is DetailLoaded
              ? AnimatedAppBar(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () async {
                  final bloc = context.read<BreathingLessonDetailBloc>();
                  final currentState = bloc.state;
                  if (currentState is DetailLoaded && currentState.isRecording) {
                    final shouldExit = await _showExitDialog();
                    if (shouldExit) {
                      bloc.add(StopBreathing());
                      if (context.mounted) context.go('/breathing');
                    }
                  } else {
                    context.go('/breathing');
                  }
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              title: Text(
                'Tập thở với ${state.breathsPart.type}',
                style: _appBarTitleStyle,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: AppColors.primaryText),
              titleSpacing: 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          )
              : null,
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BreathingLessonDetailState state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.firstMainBackground, AppColors.secMainBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: switch (state) {
        DetailInitial() || DetailLoading() => const Center(child: CircularProgressIndicator()),
        DetailError() => Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
        DetailLoaded() => _buildLoadedUI(context, state),
        DetailCompleted() => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildLoadedUI(BuildContext context, DetailLoaded state) {
    final progress = state.targetDuration > 0
        ? (state.elapsedSeconds / state.targetDuration).clamp(0.0, 1.0)
        : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildInstruction(state),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 318,
                      height: 318,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: progress),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(AppColors.primaryText),
                          );
                        },
                      ),
                    ),
                    _VolumeBars(state: state),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildButton(context, state),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(DetailLoaded state) {
    final type = state.breathsPart.type;
    final duration = state.breathsPart.duration;

    if (state.isRecording) {
      return Text(
        '${state.elapsedSeconds.toInt()}s / ${state.targetDuration.toInt()}s',
        style: _timerStyle,
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: _richTextBaseStyle,
        children: [
          const TextSpan(text: 'Tạo âm "'),
          TextSpan(text: type, style: _richTextAccentStyle),
          const TextSpan(text: '" trong '),
          TextSpan(text: '${duration.inSeconds}s', style: _richTextAccentStyle),
          const TextSpan(text: ' và duy trì\n'),
          const TextSpan(text: 'âm lượng ổn định', style: _richTextAccentStyle),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, DetailLoaded state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: state.isRecording
          ? const SizedBox()
          : SizedBox(
        key: const ValueKey('start_button'),
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: _buttonStyle,
          onPressed: () => context.read<BreathingLessonDetailBloc>().add(StartBreathing()),
          child: const Text('Bắt đầu', style: _buttonTextStyle),
        ),
      ),
    );
  }
}

class _VolumeBars extends StatelessWidget {
  final DetailLoaded state;
  const _VolumeBars({required this.state});

  static const int _maxLevel = 32767;
  static const double _minValid = 32767 / 7;
  static const int _totalBars = 9;
  static const double _barHeight = 16;
  static const double _spacing = 6;

  @override
  Widget build(BuildContext context) {
    final level = state.currentVolumeLevel.clamp(0, _maxLevel);
    final activeBars = (level / _maxLevel * _totalBars).floor();
    final totalHeight = _totalBars * _barHeight + (_totalBars - 1) * _spacing;
    final thresholdRatio = _minValid / _maxLevel;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: totalHeight,
          width: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_totalBars, (index) {
                  final isActive = index < activeBars;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 54,
                    height: _barHeight,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.progressColor : Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }).reversed.toList(),
              ),
              Positioned(
                bottom: thresholdRatio * totalHeight,
                child: Container(width: 54, height: 3, color: AppColors.progressColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('Âm lượng', style: _volumeLabelStyle),
      ],
    );
  }
}