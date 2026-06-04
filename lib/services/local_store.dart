/// Platforma göre kalıcı anahtar-değer saklama (web'de localStorage).
export 'web/local_store_stub.dart'
    if (dart.library.html) 'web/local_store_web.dart';
