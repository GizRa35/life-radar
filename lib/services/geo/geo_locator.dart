/// Platforma göre tarayıcı GPS köprüsü.
/// Web'de gerçek tarayıcı konumu, diğer platformlarda null döner.
export 'geo_stub.dart' if (dart.library.html) 'geo_web.dart';
