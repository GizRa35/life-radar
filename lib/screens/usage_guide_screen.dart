import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Kullanım Kılavuzu — uygulamanın nasıl kullanılacağını anlatır.
class UsageGuideScreen extends StatelessWidget {
  const UsageGuideScreen({super.key});

  static const List<({IconData icon, Color color, String title, String body})>
      _steps = [
    (
      icon: Icons.home_outlined,
      color: LifeRadarColors.turquoise,
      title: 'Ana Sayfa',
      body: 'Günün özeti, hava durumu, döviz/altın kurları ve "Bugün Öne '
          'Çıkanlar" tek bakışta. Aşağı çekerek yenileyebilirsin.',
    ),
    (
      icon: Icons.article_outlined,
      color: Color(0xFF2980B9),
      title: 'Gündem',
      body: '"Senin İçin" akışı ve kategorilere göre haberler. Bir habere '
          'dokun → detayını, sana etkisini ve "Ne yapmalıyım?" önerilerini gör.',
    ),
    (
      icon: Icons.radar,
      color: Color(0xFFC0392B),
      title: 'Radar',
      body: 'Konumuna ve profiline göre kişisel risk puanın. Sağlık, ekonomi, '
          'afet, seyahat risklerini incele. Memleketini de "şehir takibi"ne ekle.',
    ),
    (
      icon: Icons.auto_awesome,
      color: Color(0xFF8E44AD),
      title: 'Life Radar Asistan',
      body: 'Sağ alttaki ✨ butonu. Merak ettiğini sor (yazarak veya mikrofonla); '
          'sana özel, sade bir analiz alırsın.',
    ),
    (
      icon: Icons.menu_book_outlined,
      color: Color(0xFFE67E22),
      title: 'Rehber',
      body: 'Acil durum çantanı hazırla, 112\'yi tek dokunuşla ara, aile acil '
          'planını oluştur ve deprem/sel/yangın rehberlerini incele.',
    ),
    (
      icon: Icons.person_outline,
      color: LifeRadarColors.navy,
      title: 'Profil',
      body: 'Kişisel bilgilerini gir (analizler kişiselleşir), haber dili ve '
          'kaynakları seç, bildirim/gizlilik ayarlarını yönet.',
    ),
    (
      icon: Icons.workspace_premium_outlined,
      color: Color(0xFFC9A227),
      title: 'Premium & VIP',
      body: 'Sınırsız asistan, kişisel risk analizi, aile koruma merkezi ve '
          'reklamsız kullanım. VIP en üst düzey koruma sunar.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nasıl Kullanılır?')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [LifeRadarColors.navy, Color(0xFF123A63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.radar, color: LifeRadarColors.turquoise, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Life Radar 3 soruyu yanıtlar: Ne oluyor? Beni etkiler mi? '
                    'Ne yapmalıyım?',
                    style: TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _steps.length; i++) _stepCard(i + 1, _steps[i]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LifeRadarColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'İpucu: Bilgiler cihazında saklanır ve sadece sana özel analiz için '
              'kullanılır. İstediğin an Profil > Gizlilik\'ten yönetebilirsin.',
              style: TextStyle(
                  fontSize: 12, color: LifeRadarColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _stepCard(
      int n, ({IconData icon, Color color, String title, String body}) s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: s.color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: s.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(s.icon, color: s.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: LifeRadarColors.navy)),
                const SizedBox(height: 4),
                Text(s.body,
                    style: const TextStyle(
                        color: LifeRadarColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
