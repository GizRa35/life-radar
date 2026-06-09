import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Önbellekli ağ görseli — akıcı yüklenir, diske önbelleğe alınır
/// (çevrimdışıyken bile görünür), hatada sessizce gizlenir.
/// [url] önceden çözülmüş (gerekiyorsa proxy'li) tam adres olmalıdır.
class CachedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  const CachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        color: LifeRadarColors.background,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: LifeRadarColors.turquoise),
        ),
      ),
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
