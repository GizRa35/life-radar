import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// iOS/native: gerçek "Sign in with Apple".
/// Başarılıysa Firebase için gereken idToken + rawNonce döner;
/// iptal/başarısızlıkta null.
Future<({String idToken, String rawNonce})?> appleSignIn() async {
  try {
    // Güvenlik için rastgele nonce üret; SHA256 özetini Apple'a gönder,
    // ham (raw) nonce'u Firebase doğrulaması için sakla.
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) return null;
    return (idToken: idToken, rawNonce: rawNonce);
  } catch (_) {
    return null; // kullanıcı iptal etti veya hata
  }
}

String _randomNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(
      length, (_) => charset[random.nextInt(charset.length)]).join();
}
