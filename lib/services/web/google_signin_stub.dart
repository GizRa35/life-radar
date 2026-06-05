import 'package:google_sign_in/google_sign_in.dart';

/// Web dışı (Android/iOS): Google ile giriş — native hesap seçici açılır,
/// OAuth access_token döner (iptal/başarısızlıkta null).
Future<String?> googleAccessToken() async {
  try {
    final gsi = GoogleSignIn(scopes: const ['email', 'profile']);
    await gsi.signOut(); // her seferinde hesap seçtir
    final account = await gsi.signIn();
    if (account == null) return null; // kullanıcı iptal etti
    final auth = await account.authentication;
    return auth.accessToken;
  } catch (_) {
    return null;
  }
}
