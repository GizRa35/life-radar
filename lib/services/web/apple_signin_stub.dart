/// Web ve Android: Apple ile giriş yok — her zaman null döner.
/// (Apple ile giriş yalnızca iOS/native'de desteklenir.)
Future<({String idToken, String rawNonce})?> appleSignIn() async => null;
