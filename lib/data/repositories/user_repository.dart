import 'dart:io';

import '../model/user/app_user.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String uid);
  Future<void> updateUser(AppUser user);
  Future<String?> uploadAvatar(String uid, File image);
}