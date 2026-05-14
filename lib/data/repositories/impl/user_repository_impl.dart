import 'dart:io';

import 'package:ikara_clone/data/model/user/app_user.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
import 'package:ikara_clone/data/services/user_service.dart';
import 'package:ikara_clone/data/services/storage_service.dart';

class UserRepositoryImpl implements UserRepository{

  final UserService _userService;
  final StorageService _storageService;

  UserRepositoryImpl(this._userService, this._storageService);
  @override
  Future<AppUser?> getUser(String uid) async {
    final data = await _userService.fetchUser(uid);
    if (data == null) return null;
    return AppUser.fromJson(uid, data);
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _userService.updateUser(user.id, user.toJson());
  }

  @override
  Future<String?> uploadAvatar(String uid, File image) async {
    return await _storageService.uploadAvatar(uid, image);
  }
}