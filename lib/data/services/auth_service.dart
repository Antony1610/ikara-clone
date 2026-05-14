import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  String? _verificationId;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> initialize() async {
    // await _googleSignIn.initialize(
    //   serverClientId: '662006036899-u9bu0mrvqbaq0vql0ovq8atql8vanc35.apps.googleusercontent.com'
    // );
  }

  User? get currentUser => _firebaseAuth.currentUser;
  Future<UserCredential> loginWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final GoogleSignInClientAuthorization clientAuth =
          await googleUser.authorizationClient.authorizationForScopes([
            'email',
            'profile',
          ]) ??
              await googleUser.authorizationClient.authorizeScopes([
                'email',
                'profile',
              ]);

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: clientAuth.accessToken,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> loginWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login(
      permissions: ['public_profile', 'email'],
    );

    if (loginResult.accessToken == null) {
      throw Exception('Facebook login cancelled');
    }

    final userData = await FacebookAuth.instance.getUserData(
      fields: "name,email,picture.width(200).height(200)",
    );

    final OAuthCredential facebookAuthCredential =
    FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    final userCredential =
    await _firebaseAuth.signInWithCredential(facebookAuthCredential);

    await userCredential.user?.updateDisplayName(userData['name']);
    await userCredential.user?.updatePhotoURL(
      userData['picture']?['data']?['url'],
    );

    return userCredential;
  }

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    Function(PhoneAuthCredential)? onAutoVerified,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _firebaseAuth.signInWithCredential(credential);
        onAutoVerified?.call(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification Failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<UserCredential> verifyOTP(String smsCode) async {
    if (_verificationId == null) throw Exception('No verification ID found');

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    return await _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}