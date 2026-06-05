import 'package:geolocator/geolocator.dart';

/// Web dışı (Android/iOS): cihazın gerçek GPS konumunu ister.
/// İzin verilmez / kapalıysa null döner (IP tahminine düşülür).
Future<List<double>?> getBrowserCoords() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
    return [pos.latitude, pos.longitude];
  } catch (_) {
    return null;
  }
}
