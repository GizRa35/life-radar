import 'dart:html' as html;

/// Tarayıcının hassas GPS konumunu ister (izin penceresi çıkar).
/// [lat, lng] döner; reddedilir/başarısız olursa null.
Future<List<double>?> getBrowserCoords() async {
  try {
    final pos = await html.window.navigator.geolocation.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 15),
    );
    final lat = pos.coords?.latitude;
    final lng = pos.coords?.longitude;
    if (lat == null || lng == null) return null;
    return [lat.toDouble(), lng.toDouble()];
  } catch (_) {
    return null;
  }
}
