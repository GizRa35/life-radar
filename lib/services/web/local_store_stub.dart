import 'package:shared_preferences/shared_preferences.dart';

/// Web dışı (Android/iOS/masaüstü): shared_preferences ile KALICI depolama.
///
/// API senkron olduğundan, açılışta tüm anahtarlar belleğe yüklenir (lsInit),
/// sonra okuma bellekten, yazma hem belleğe hem diske (write-through) yapılır.
SharedPreferences? _prefs;
final Map<String, String> _cache = {};

Future<void> lsInit() async {
  _prefs = await SharedPreferences.getInstance();
  for (final k in _prefs!.getKeys()) {
    final v = _prefs!.get(k);
    if (v is String) _cache[k] = v;
  }
}

String? lsGet(String key) => _cache[key];

void lsSet(String key, String value) {
  _cache[key] = value;
  _prefs?.setString(key, value);
}

void lsRemove(String key) {
  _cache.remove(key);
  _prefs?.remove(key);
}
