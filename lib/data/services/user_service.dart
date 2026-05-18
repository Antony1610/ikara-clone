import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<Map<String, dynamic>?> fetchUser(String uid) async {
    final snapshot = await _db.ref('users/$uid').get();
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Future<void> createUserIfNotExists(User user) async {
    final ref = _db.ref('users/${user.uid}');
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'image': user.photoURL ?? '',
        'gender': null,
        'birthDay': null,
        'country': null,
        'deletedAt': null,
        'status': null,
        'voiceRange': null,
        'lastNameChangedAt': null,
      });
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final deletedAtRaw = data['deletedAt'];

    if (deletedAtRaw != null) {
      final deletedAt =
      DateTime.fromMillisecondsSinceEpoch(deletedAtRaw as int);
      final diff = DateTime.now().difference(deletedAt).inDays;

      if (diff < 30) {
        await cancelAccountDeletion(user.uid);
      } else {
        await _db.ref('users/${user.uid}').remove();
        await user.delete();
        throw Exception('account_permanently_deleted');
      }
    }
  }

  Future<bool> isAccountPendingDeletion(String uid) async {
    final snapshot = await _db.ref('users/$uid/deletedAt').get();
    if (!snapshot.exists || snapshot.value == null) return false;

    final deletedAt =
    DateTime.fromMillisecondsSinceEpoch(snapshot.value as int);
    return DateTime.now().difference(deletedAt).inDays < 30;
  }

  Future<void> cancelAccountDeletion(String uid) async {
    await _db.ref('users/$uid').update({'deletedAt': null});
  }

  Future<void> softDeleteAccount(String uid) async {
    await _db.ref('users/$uid').update({
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> updateAtPath(String path, Map<String, dynamic> data) async {
    await _db.ref(path).update(data);
  }


}