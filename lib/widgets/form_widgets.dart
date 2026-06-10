import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Ortak form tasarım bileşenleri (mockup tasarım dili).
///
/// Tüm form ekranları (kişisel bilgiler, aile planı, acil çanta, hesap,
/// bildirim ayarları, gizlilik, kaynak seçimi...) bu bileşenleri kullanır;
/// böylece görünüm tutarlı ve "premium" kalır.

/// Bölüm başlığı: açık mavi yuvarlatılmış kare içinde ikon + kalın başlık.
class FormSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final EdgeInsets padding;
  const FormSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(4, 18, 4, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE3EDF6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: LifeRadarColors.navy),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: LifeRadarColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bilgilendirme / ipucu kartı: turkuaz tonlu, sol ikon + (opsiyonel başlık) + metin.
class FormTipCard extends StatelessWidget {
  final String text;
  final String title;
  final IconData icon;
  const FormTipCard({
    super.key,
    required this.text,
    this.title = '',
    this.icon = Icons.lightbulb_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LifeRadarColors.turquoise.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LifeRadarColors.turquoise.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LifeRadarColors.turquoise, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: LifeRadarColors.navy,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: LifeRadarColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// İlerleme durumu kartı — sağda dairesel % halkası, solda ikon-kare + başlık.
/// (Acil Çanta gibi sayılabilir ilerleme için.)
class CircularStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double percent; // 0..1
  const CircularStatusCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE6F1)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: LifeRadarColors.turquoise,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: LifeRadarColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: LifeRadarColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 5,
                    backgroundColor: const Color(0xFFD3DEEA),
                    valueColor: const AlwaysStoppedAnimation(
                        LifeRadarColors.turquoise),
                  ),
                ),
                Text(
                  '${(percent * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: LifeRadarColors.navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// İlerleme durumu kartı — çubuk (linear) % + sağda soluk ikon.
/// (Kişisel Bilgiler / profil tamamlama gibi.)
class LinearStatusCard extends StatelessWidget {
  final String overline; // küçük turkuaz üst etiket
  final String title;
  final String subtitle;
  final double percent; // 0..1
  final IconData illustration;
  const LinearStatusCard({
    super.key,
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.percent,
    this.illustration = Icons.fact_check_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE6F1)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -6,
            child: Icon(illustration,
                size: 64, color: LifeRadarColors.navy.withOpacity(0.06)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overline.toUpperCase(),
                style: const TextStyle(
                  color: LifeRadarColors.turquoise,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: LifeRadarColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFD3DEEA),
                  valueColor:
                      const AlwaysStoppedAnimation(LifeRadarColors.turquoise),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: LifeRadarColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Küçük turkuaz üst etiket (alan gruplarının üstünde: ŞEHİR, HABER DİLİ...).
class FormFieldLabel extends StatelessWidget {
  final String text;
  const FormFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: LifeRadarColors.turquoise,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
