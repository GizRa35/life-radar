/// Tüm proxy/servis çağrılarının tek merkezden yönetildiği temel adres.
///
/// Geliştirme (lokal PowerShell sunucusu): varsayılan `http://localhost:5151`.
/// Production (bulut backend): derleme sırasında geçilir, örn:
///   flutter build web --dart-define=API_BASE=https://api.liferadar.app
class ApiConfig {
  ApiConfig._();

  /// Backend temel adresi. `--dart-define=API_BASE=...` ile override edilir.
  static const String base =
      String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:5151');
}
