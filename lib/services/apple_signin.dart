/// Platforma göre Apple ile giriş köprüsü.
/// iOS/native'de gerçek "Sign in with Apple"; web'de null döner.
export 'web/apple_signin_stub.dart'
    if (dart.library.io) 'apple_signin_io.dart';
