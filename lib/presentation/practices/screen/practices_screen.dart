import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/model.dart';
import 'package:ikara_clone/data/repositories/practices_repository.dart';
import 'package:ikara_clone/presentation/practices/bloc/practices_bloc.dart';

class PracticesScreen extends StatefulWidget {
  const PracticesScreen({super.key});

  @override
  State<PracticesScreen> createState() => _PracticesScreenState();
}

class _PracticesScreenState extends State<PracticesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          PracticesBloc(ctx.read<PracticesRepository>())..add(PracticesLoad()),
      child: const _PracticesPageView(),
    );
  }
}

class _PracticesPageView extends StatelessWidget {
  const _PracticesPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Luyện thanh',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
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
            colors: [
              AppColors.firstMainBackground,
              AppColors.secMainBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: const _PracticesList()),
      ),
    );
  }
}

class _PracticesList extends StatefulWidget {
  const _PracticesList();

  @override
  State<_PracticesList> createState() => _PracticesListState();
}

class _PracticesListState extends State<_PracticesList> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PracticesBloc, PracticesState>(
      builder: (context, state) {
        return switch (state) {
          PracticesInitial() || PracticesLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.progressColor),
          ),
          PracticesError(:final message) => Center(
            child: Text(message, style: TextStyle(color: Colors.redAccent)),
          ),
          PracticesLoaded(:final parts) => _PracticesListView(parts),
        };
      },
    );
  }
}

class _PracticesListView extends StatelessWidget {
  final List<PracticesPart> parts;
  const _PracticesListView(this.parts);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('practices-list'),
      itemBuilder: (context, index) {
        return _PracticesCard(part: parts[index], index: index);
      },
      itemCount: parts.length,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 16,
        left: 16,
        right: 16,
      ),
    );
  }
}

class _PracticesCard extends StatefulWidget {
  final PracticesPart part;
  final int index;
  const _PracticesCard({required this.part, required this.index});

  @override
  State<_PracticesCard> createState() => _PracticesCardState();
}

class _PracticesCardState extends State<_PracticesCard> {
  bool get _isLocked => widget.index > 2;
  int? get star => widget.index < 2 ? 3 : null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 186,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.firstColor, AppColors.secColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.part.name,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),

                const Spacer(),

                _ActionButton(
                  isLocked: _isLocked,
                  onTap: _isLocked ? null : () => _onStart(context),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          _CardRight(isLocked: _isLocked, star: star),
        ],
      ),
    );
  }

  void _onStart(BuildContext context) {
    context.push('/practices/${widget.part.indexId}');
  }
}

class _CardRight extends StatelessWidget {
  final bool isLocked;
  final int? star;

  const _CardRight({required this.isLocked, this.star});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          isLocked
              ? 'assets/practices/practices_lock.svg'
              : 'assets/practices/practices_unlock.svg',
          width: 97,
          height: 100,
        ),

        if (star != null) ...[const SizedBox(height: 8), _StarRow(star: star!)],
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final int star;

  const _StarRow({required this.star});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      width: 86,
      decoration: BoxDecoration(
        color: AppColors.pracColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          final filled = i < star;
          return Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.pracStarColor,
            size: 16,
            shadows: [Shadow(color: AppColors.pracStarColor, blurRadius: 4)],
          );
        }),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isLocked;
  final VoidCallback? onTap;

  const _ActionButton({required this.isLocked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pracColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLocked ? Icons.lock : Icons.play_arrow,
              color: isLocked ? AppColors.lockText : Colors.white ,
              size: 12,
            ),
            const SizedBox(width: 6),
            Text(
              isLocked ? 'Khoá' : 'Bắt đầu',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
