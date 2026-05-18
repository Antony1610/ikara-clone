import 'dart:io';

// import 'package:ikara_clone/data/model/user/lesson_user_result.dart';


import '../model/user/app_user.dart';
import '../model/user/lesson_user_result.dart';

abstract class UserRepository {
  Future<AppUser?> getUser(String uid);
  Future<void> updateUser(AppUser user);
  Future<String?> uploadAvatar(String uid, File image);
  Future<void> updateUserLesson(String uid, LessonUserResult result);
  Future<LessonUserResult?> getUserLesson(String uid, LessonUserResult userResult);
  Future<List<LessonUserResult>> getListLessonResult(String uid);
}