import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
import 'package:ikara_clone/presentation/performance_detail/bloc/performance_detail_bloc.dart';

import '../widget/video_player_widget.dart';

class PerformanceDetailScreen extends StatefulWidget {
  final String id;
  const PerformanceDetailScreen({super.key, required this.id});

  @override
  State<PerformanceDetailScreen> createState() =>
      _PerformanceDetailScreenState();
}

class _PerformanceDetailScreenState extends State<PerformanceDetailScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      PerformanceDetailBloc(context.read<PerformanceRepository>())
        ..add(LoadPerformanceDetail(widget.id)),
      child: myBody(),
    );
  }

  Widget myBody() {
    return BlocBuilder<PerformanceDetailBloc, PerformanceDetailState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AnimatedAppBar(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.go('/performance'),
                icon: const Icon(Icons.arrow_back_ios),
              ),
              title: Text(
                'Trình diễn',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              iconTheme: const IconThemeData(color: AppColors.primaryText),
              titleSpacing: 0,
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PerformanceDetailState state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.firstMainBackground, AppColors.secMainBackground],
        ),
      ),
      child: SafeArea(
        child: switch (state) {
          PerformanceDetailInitial() ||
          PerformanceDetailLoading() =>
          const Center(
            child: CircularProgressIndicator(color: AppColors.progressColor),
          ),
          PerformanceDetailError() => Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          PerformanceDetailLoaded() => AnimatedContent(
            key: ValueKey('performance-detail-${state.lesson.id}'),
            child: _VideoSection(state: state),
          ),
        },
      ),
    );
  }
}

class _VideoSection extends StatefulWidget {
  final PerformanceDetailLoaded state;
  const _VideoSection({required this.state});

  @override
  State<_VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<_VideoSection> {
  VoidCallback? _pauseVideo;

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
                VideoPlayerWidget(
                  videoUrl: widget.state.lesson.teachSingLink,
                  onControllerReady: (pause) {
                    _pauseVideo = pause;
                  },
                ),
                const SizedBox(height: 16),
                _title(),
                const SizedBox(height: 20),
                _instruct(),
                const SizedBox(height: 10,)
              ],
            ),
          ),
        ),
        _toSing(context),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16,),
        const SizedBox(height: 10,)
      ],
    );
  }

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.state.lesson.teachSingTitle,
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.state.lesson.singerName,
            style: const TextStyle(
              color: AppColors.lockText,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _instruct() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lessonFocusColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.state.lesson.teachSingInstruct,
        style: GoogleFonts.roboto(
          textStyle: const TextStyle(
            color: AppColors.primaryText,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.24,
          ),
        ),
      ),
    );
  }

  Widget _toSing(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _pauseVideo?.call();
            context.pushReplacement('/karaoke/${widget.state.lesson.id}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.progressColor,
            foregroundColor: AppColors.primaryText,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            'Hát thử',
            style: GoogleFonts.roboto(
              fontSize: 10,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}