import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';
import 'package:ikara_clone/data/repositories/performance_repository.dart';
import 'package:ikara_clone/presentation/performances/bloc/performances_bloc.dart';

import '../../../constants/constants.dart';

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          PerformancesBloc(ctx.read<PerformanceRepository>())
            ..add(LoadPerformances()),
      child: const _PerformancesPageView(),
    );
  }
}

class _PerformancesPageView extends StatefulWidget {
  const _PerformancesPageView();

  @override
  State<_PerformancesPageView> createState() => _PerformancesPageViewState();
}

class _PerformancesPageViewState extends State<_PerformancesPageView> {

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository>().currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Trình diễn',
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          Padding(padding: EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => context.go('/setting'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: user?.image != null ? NetworkImage(user!.image!) : null,
              child: user?.image == null ? Icon(Icons.person) : null,
            ),
          ),)
        ],
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
        child: SafeArea(child: _PerformanceList()) ,
      ),
    );
  }
}

class _PerformanceList extends StatelessWidget {
  const _PerformanceList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PerformancesBloc, PerformancesState>(
      builder: (context, state) {
        return switch (state) {
          PerformancesInitial() || PerformancesLoading() => const Center(
            child: CircularProgressIndicator(),
          ),

          PerformancesError(message: final msg) => Center(
            child: Text(
              msg,
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          PerformancesLoaded(performances: final items) => GridView.builder(
            key: const PageStorageKey('performance-list'),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 280,
            ),
            itemBuilder: (context, index) {
              return _PerformanceItem(lesson: items[index]);
            },
          ),
        };
      },
    );
  }
}

class _PerformanceItem extends StatelessWidget {
  final PerformanceLesson lesson;
  const _PerformanceItem({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/performanceDetail/${lesson.id}');
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 184,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 184,
                height: 184,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(20),
                    ),
                    color: Colors.white10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.network(
                      lesson.thumbnailLink,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.music_note,
                              color: Colors.white54,
                              size: 40,
                            ),
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                lesson.songTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lesson.singerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.roboto(
                  textStyle: TextStyle(
                    color: AppColors.lockText,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
