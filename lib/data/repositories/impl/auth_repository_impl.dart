import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final UserService _userService;

  AuthRepositoryImpl(this._authService, this._userService);

  Future<AppUser> _handleLogin(User user) async {
    try {
      await _userService.createUserIfNotExists(user);
      final data = await _userService.fetchUser(user.uid);
      return data != null
          ? AppUser.fromJson(user.uid, data)
          : AppUser.fromFirebase(user);
    } catch (e) {
      return AppUser.fromFirebase(user);
    }
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      try {
        return await _handleLogin(user);
      } catch (e) {
        return AppUser.fromFirebase(user);
      }
    });
  }
  @override
  AppUser? get currentUser {
    final user = _authService.currentUser;
    return user != null ? AppUser.fromFirebase(user) : null;
  }

  @override
  Future<AppUser> loginWithGoogle() async {
    try {
      final credential = await _authService.loginWithGoogle();
      return _handleLogin(credential.user!);
    } catch (e) {
      if (e.toString().contains('account_permanently_deleted')) {
        throw Exception('account_permanently_deleted');
      }
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<AppUser> loginWithFacebook() async {
    try {
      final credential = await _authService.loginWithFacebook();
      return _handleLogin(credential.user!);
    } catch (e) {
      if (e.toString().contains('account_permanently_deleted')) {
        throw Exception('account_permanently_deleted');
      }
      throw Exception('Facebook sign in failed: $e');
    }
  }

  @override
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(PhoneAuthCredential)? onAutoVerified,
  }) async {
    await _authService.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerified: onAutoVerified,
    );
  }

  @override
  Future<AppUser> verifyOTP(String smsCode) async {
    try {
      final credential = await _authService.verifyOTP(smsCode);
      return _handleLogin(credential.user!);
    } catch (e) {
      if (e.toString().contains('account_permanently_deleted')) {
        throw Exception('account_permanently_deleted');
      }
      throw Exception('OTP verification failed: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final uid = _authService.currentUser?.uid;
      if (uid == null) return;
      await _userService.softDeleteAccount(uid);
      await _authService.signOut();
    } catch (e) {
      throw Exception('Delete account failed: $e');
    }
  }

  @override
  Future<bool> isAccountPendingDeletion() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return false;
    return await _userService.isAccountPendingDeletion(uid);
  }

  @override
  Future<void> cancelAccountDeletion() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _userService.cancelAccountDeletion(uid);
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
}
