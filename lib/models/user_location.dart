/// IP/konum tespitinden gelen kullanıcı konumu.
class UserLocation {
  final String city;
  final String region;
  final String country;
  final double? lat;
  final double? lng;

  const UserLocation({
    required this.city,
    this.region = '',
    this.country = '',
    this.lat,
    this.lng,
  });

  /// "İzmir, Ege" gibi okunabilir etiket.
  String get label {
    final parts = [city, region].where((s) => s.isNotEmpty).toList();
    return parts.isEmpty ? country : parts.join(', ');
  }
}
