import 'package:firebase_auth/firebase_auth.dart';
import 'package:ikara_clone/data/model/user/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> loginWithGoogle();
  Future<AppUser> loginWithFacebook();
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(PhoneAuthCredential)? onAutoVerified,
  });
  Future<AppUser> verifyOTP(String smsCode);
  Future<void> deleteAccount();
  Future<bool> isAccountPendingDeletion();
  Future<void> cancelAccountDeletion();
  Future<void> signOut();
  AppUser? get currentUser;
}