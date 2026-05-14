import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/data/model/user/app_user.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository>().currentUser;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
        ),
        backgroundColor: Colors.transparent,
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
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 50),
            _buildHeader(context, user),
            _buildMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppUser? user) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.avatarColor,
                backgroundImage:
                user?.image != null ? NetworkImage(user!.image!) : null,
                child: user?.image == null
                    ? Icon(
                  Icons.person_outline_sharp,
                  size: 60,
                  color: Colors.white24,
                )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(6),
                child: SvgPicture.asset(
                  'assets/icons/edit.svg',
                  width: 14,
                  height: 17,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user?.name ?? "User Name",
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        if ((user?.status ?? "").isNotEmpty)
          Text(
            user!.status!,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryText,
            ),
          ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            height: 66,
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.avatarColor,
            ),
            child: Row(
              children: [
                Text(
                  'Đo quảng giọng',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.primaryText,
                    fontFamily: 'Roboto',
                  ),
                ),
                Spacer(),
                if ((user?.voiceRange ?? "").isNotEmpty)
                  Text(
                    user!.voiceRange!,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primaryText,
                      fontFamily: 'Roboto',
                    ),
                  ),
                Icon(Icons.chevron_right, color: AppColors.primaryText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          _MenuItem(
            icon: Icons.error_outline,
            title: "Báo cáo lỗi",
            onTap: () => context.push('/report-bug'),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.description_outlined,
            title: "Chính sách",
            onTap: () => context.push('/policy'),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.cancel_outlined,
            title: "Hủy tài khoản",
            onTap: () => context.push('/delete-account'),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.support_agent_outlined,
            title: "Hỗ trợ",
            onTap: () => context.push('/support'),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.exit_to_app_outlined,
            title: "Đăng xuất",
            onTap: () => _showSignOutDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(
          'Bạn chắc chắn muốn đăng xuất không?',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () => ctx.pop(false),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.lockText,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => ctx.pop(true),
                child: Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: AppColors.buttonInsideLesson,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final auth = context.read<AuthRepository>();
      await auth.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primaryText),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: AppColors.primaryText),
          onTap: onTap,
        ),
        Divider(
          color: Colors.white24,
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}