/// Platforma göre Google ile giriş köprüsü (web'de GIS popup).
export 'web/google_signin_stub.dart'
    if (dart.library.html) 'web/google_signin_web.dart';
