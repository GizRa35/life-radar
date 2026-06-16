import 'package:flutter/material.dart';

import '../core/api_config.dart';
import '../core/i18n.dart';
import '../core/media.dart';

/// Abonelik ekranlarında zorunlu yasal bilgi (App Store 3.1.2):
/// otomatik yenileme açıklaması + Gizlilik Politikası ve Kullanım Şartları
/// (EULA) işlevsel linkleri.
class SubscriptionLegal extends StatelessWidget {
  final Color textColor;
  final Color linkColor;
  const SubscriptionLegal({
    super.key,
    required this.textColor,
    required this.linkColor,
  });

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: linkColor,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('Abonelik otomatik yenilenir; dönem bitiminden en az 24 saat önce iptal edilmezse aynı fiyattan yenilenir. Aboneliği istediğin zaman cihaz ayarlarından yönetebilir veya iptal edebilirsin.'),
          style: TextStyle(color: textColor, fontSize: 11, height: 1.4),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 18,
          runSpacing: 4,
          children: [
            GestureDetector(
              onTap: () => Media.openUrl('${ApiConfig.base}/privacy.html'),
              child: Text(t('Gizlilik Politikası'), style: linkStyle),
            ),
            GestureDetector(
              onTap: () => Media.openUrl('${ApiConfig.base}/terms.html'),
              child: Text(t('Kullanım Şartları'), style: linkStyle),
            ),
          ],
        ),
      ],
    );
  }
}
