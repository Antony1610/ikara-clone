import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/model/user/app_user.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _statusController = TextEditingController();
  File? _imagePicker;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _statusController = TextEditingController(text: widget.user.status ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null && mounted) {
      final file = File(picked.path);
      context.read<ProfileBloc>().add(ProfileImagePicked(file));
    }
  }

  Future<void> _showExitDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        alignment: Alignment.center,
        content: Text(
          'Bạn chắc chắn muốn thoát không?',
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
      context.pop();
    }
  }

  void _save() {
    context.read<ProfileBloc>().add(
      ProfileSaved(_nameController.text.trim(), _statusController.text.trim()),
    );
  }

  String _getNameChangeHint(AppUser? user) {
    if (user?.lastNameChangedAt == null) {
      return 'Mỗi lần đổi tên cách nhau 30 ngày';
    }

    final daysLeft =
        30 - DateTime.now().difference(user!.lastNameChangedAt!).inDays;

    if (daysLeft <= 0) {
      return 'Bạn có thể đổi tên ngay bây giờ';
    }

    return 'Bạn có thể đổi tên sau $daysLeft ngày nữa';
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Center(
                child: Text(
                  'Chụp ảnh',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImage(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: Center(
                child: Text(
                  'Chọn ảnh từ thư viện',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImage(ImageSource.gallery);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: Center(
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) context.pop();
        if (state is ProfileImageUpdate) {
          setState(() {
            _imagePicker = state.image;
          });
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => _showExitDialog(context),
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _save,
                child: Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start ,
            children: [
              const SizedBox(height: 50),
              Center(
                child: GestureDetector(
                  onTap: _showImagePicker,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.avatarColor,
                        backgroundImage: _imagePicker != null
                            ? FileImage(_imagePicker!)
                            : user.image != null
                            ? NetworkImage(user.image!) as ImageProvider
                            : null,
                        child: (user.image == null && _imagePicker == null)
                            ? Icon(
                                Icons.person_outline_sharp,
                                size: 60,
                                color: Colors.white24,
                              )
                            : null,
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
                            'assets/icons/camera.svg',
                            width: 14,
                            height: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Tên hiển thị',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                enabled: user.canChangeName == true,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: AppColors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: (user.name).isEmpty ? 'Nhập tên' : null,
                  hintStyle: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: AppColors.whiteBackground.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getNameChangeHint(user),
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: AppColors.hintText,
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Trạng thái',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _statusController,
                maxLines: 3,
                maxLength: 80,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: AppColors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: (user.status ?? '').isEmpty ? 'Nhập trạng thái...' : null,
                  hintStyle: TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                  filled: true,
                  fillColor: AppColors.whiteBackground.withValues(alpha: 0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
