import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikara_clone/constants/app_colors.dart';

class AppIcon extends StatelessWidget {
  final String assetPath;
  final String? activePath;
  final bool active;
  final double size;

  const AppIcon({
    super.key,
    required this.assetPath,
    required this.active,
    this.activePath,

    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final path = (active && activePath != null) ? activePath! : assetPath;
    return SvgPicture.asset(
      path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(
        active ? AppColors.selectionColor : AppColors.unSelection,
        BlendMode.srcIn,
      ),
    );
  }
}
