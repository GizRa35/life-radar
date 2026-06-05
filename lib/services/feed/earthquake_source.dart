import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/theme.dart';
import '../../models/event_category.dart';
import '../../models/radar_event.dart';

/// USGS Earthquake API — gerçek zamanlı deprem verisi (anahtarsız, CORS uyumlu).
/// https://earthquake.usgs.gov/fdsnws/event/1/
class EarthquakeSource {
  static final Uri _uri = Uri.parse(
    'https://earthquake.usgs.gov/fdsnws/event/1/query'
    '?format=geojson&orderby=time&minmagnitude=4&limit=15',
  );

  Future<List<RadarEvent>> fetch() async {
    try {
      final res = await http.get(_uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? [];
      final events = <RadarEvent>[];
      for (final f in features) {
        final props = (f as Map)['properties'] as Map?;
        if (props == null) continue;
        final mag = (props['mag'] as num?)?.toDouble() ?? 0;
        final place = props['place']?.toString() ?? 'Bilinmeyen konum';
        final time = props['time'] as int?;
        final url = props['url']?.toString();
        final felt = (props['felt'] as num?)?.toInt();
        final tsunami = (props['tsunami'] as num?)?.toInt() == 1;
        final alert = props['alert']?.toString();
        // Derinlik geometri koordinatlarının 3. değerinde (km).
        final coords = ((f['geometry'] as Map?)?['coordinates'] as List?);
        final lng = coords != null && coords.isNotEmpty
            ? (coords[0] as num?)?.toDouble()
            : null;
        final lat = coords != null && coords.length > 1
            ? (coords[1] as num?)?.toDouble()
            : null;
        final depth = coords != null && coords.length > 2
            ? (coords[2] as num?)?.toDouble()
            : null;
        final when = time != null
            ? DateTime.fromMillisecondsSinceEpoch(time)
            : DateTime.now();
        events.add(RadarEvent(
          id: f['id']?.toString() ?? url ?? place,
          title: 'M${mag.toStringAsFixed(1)} deprem — $place',
          summary: _buildSummary(
            mag: mag,
            place: place,
            depth: depth,
            felt: felt,
            tsunami: tsunami,
            alert: alert,
            when: when,
          ),
          category: EventCategory.disaster,
          source: 'USGS',
          publishedAt: when,
          risk: _riskFromMagnitude(mag),
          url: url,
          imageUrl: (lat != null && lng != null) ? _mapImage(lat, lng) : null,
        ));
      }
      return events;
    } catch (_) {
      return [];
    }
  }

  /// USGS verisinden okunaklı, çok cümleli Türkçe açıklama üretir.
  String _buildSummary({
    required double mag,
    required String place,
    double? depth,
    int? felt,
    bool tsunami = false,
    String? alert,
    required DateTime when,
  }) {
    final buf = StringBuffer();
    final h = when.hour.toString().padLeft(2, '0');
    final m = when.minute.toString().padLeft(2, '0');
    buf.write(
        'USGS (ABD Jeoloji Araştırmaları Kurumu) verilerine göre $place '
        'bölgesinde, yerel saatle yaklaşık $h:$m sıralarında büyüklüğü '
        '${mag.toStringAsFixed(1)} olan bir deprem kaydedildi. ');

    if (depth != null) {
      final d = depth.round();
      final derinlikYorum = d < 70
          ? 'Sığ odaklı (yüzeye yakın) bir deprem olduğu için yüzeydeki '
              'sarsıntı etkisi daha belirgin hissedilebilir.'
          : 'Orta-derin odaklı bir deprem olduğu için yüzeydeki sarsıntı '
              'etkisi göreceli olarak daha sınırlı kalabilir.';
      buf.write('Depremin yer altındaki odak derinliği yaklaşık $d km. '
          '$derinlikYorum ');
    }

    // Büyüklüğe göre genel beklenti.
    if (mag >= 6) {
      buf.write('Bu büyüklükteki depremler, kaynağa yakın yerleşimlerde '
          'hasara ve artçı sarsıntılara yol açabilir. ');
    } else if (mag >= 5) {
      buf.write('Bu büyüklükteki depremler geniş bir alanda hissedilebilir; '
          'yapısal açıdan zayıf binalarda hafif hasar görülebilir. ');
    } else if (mag >= 4) {
      buf.write('Bu büyüklükteki depremler çevrede hissedilebilir ancak '
          'genellikle ciddi hasara yol açmaz. ');
    }

    if (felt != null && felt > 0) {
      buf.write('İlk verilere göre çevredeki $felt kişi depremi hissettiğini '
          'bildirdi. ');
    }
    if (tsunami) {
      buf.write('⚠️ Bu deprem için tsunami değerlendirmesi yapılmaktadır; '
          'kıyı bölgelerindekiler resmi uyarıları takip etmelidir. ');
    }
    if (alert == 'yellow' || alert == 'orange' || alert == 'red') {
      const map = {
        'yellow': 'sarı (sınırlı etki bekleniyor)',
        'orange': 'turuncu (belirgin etki olası)',
        'red': 'kırmızı (ciddi etki olası)',
      };
      buf.write('USGS bu olay için ${map[alert]} düzeyinde bir uyarı seviyesi '
          'belirledi. ');
    }
    buf.write('Resmi güncellemeler için USGS sayfasını takip edebilirsiniz.');
    return buf.toString();
  }

  /// Deprem merkez üssünün açık kaynaklı (anahtarsız) statik harita görseli.
  String _mapImage(double lat, double lng) {
    final la = lat.toStringAsFixed(4);
    final ln = lng.toStringAsFixed(4);
    return 'https://staticmap.openstreetmap.de/staticmap.php'
        '?center=$la,$ln&zoom=6&size=600x320&maptype=mapnik'
        '&markers=$la,$ln,red-pushpin';
  }

  RiskLevel _riskFromMagnitude(double mag) {
    if (mag >= 6) return RiskLevel.critical;
    if (mag >= 5) return RiskLevel.high;
    if (mag >= 4.5) return RiskLevel.medium;
    return RiskLevel.low;
  }

  /// Kullanıcının çevresindeki (300 km, son 30 gün) gerçek depremlerden
  /// 0-100 afet risk skoru üretir. Şehir değiştikçe skor değişir.
  Future<int> nearbyRiskScore(double lat, double lng) async {
    final start = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String()
        .split('T')
        .first;
    final uri = Uri.parse(
      'https://earthquake.usgs.gov/fdsnws/event/1/query'
      '?format=geojson&latitude=$lat&longitude=$lng&maxradiuskm=300'
      '&minmagnitude=2.5&starttime=$start&orderby=magnitude&limit=200',
    );
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return 30;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (data['features'] as List?) ?? [];
      if (features.isEmpty) return 18; // çevrede son 30 günde belirgin deprem yok
      double maxMag = 0;
      for (final f in features) {
        final mag = ((f as Map)['properties']?['mag'] as num?)?.toDouble() ?? 0;
        if (mag > maxMag) maxMag = mag;
      }
      final count = features.length;
      // Maks. büyüklük ağırlıklı (0-70) + sıklık (0-30)
      final magPart = (maxMag / 7.0 * 70).clamp(0, 70);
      final countPart = (count.clamp(0, 60) / 60.0 * 30).clamp(0, 30);
      return (magPart + countPart).round().clamp(0, 100);
    } catch (_) {
      return 30;
    }
  }
}
