import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../models/family_member.dart';
import '../services/report_export.dart';
import '../state/app_state.dart';
import '../widgets/ai_rich_text.dart';
import '../widgets/event_card.dart';
import '../widgets/risk_history_chart.dart';
import 'ai_result_screen.dart';
import 'notification_settings_screen.dart';
import 'personal_info_screen.dart';

const Color _gold = Color(0xFFC9A227);

/// VIP MERKEZİ — VIP özelliklerinin çalışan hali (Groq AI ile).
class VipHubScreen extends StatelessWidget {
  const VipHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = <_VipTool>[
      _VipTool(t('Aile Koruma Merkezi'), Icons.family_restroom,
          t('Aile üyelerini ekle, her birine özel Life Radar Asistan analizi al.'),
          onTap: (c) => _push(c, const _FamilyCenterScreen())),
      _VipTool(t('Akıllı Aksiyon Danışmanı'), Icons.shopping_cart_checkout,
          t('Hane halkına göre MİKTARLI hazırlık önerileri (gıda, su, enerji...).'),
          run: (s) => s.vipSmartActions(), imageQuery: 'grocery shopping pantry'),
      _VipTool(t('Kişisel Life Radar Asistanı'), Icons.psychology,
          t('Bugün sizi etkileyebilecek en önemli gelişmeler.'),
          run: (s) => s.vipDailyAnalyst(), imageQuery: 'data analytics screen'),
      _VipTool(t('Şehir Bazlı Risk Merkezi'), Icons.location_city,
          t('Bulunduğun şehir için deprem/yangın/hava/su/sağlık değerlendirmesi.'),
          run: (s) => s.vipCityRisk(), imageQuery: 'istanbul city skyline'),
      _VipTool(t('Kişisel Acil Durum Planı'), Icons.health_and_safety,
          t('Aile ve konumuna göre hazırlık planı.'),
          run: (s) => s.vipEmergencyPlan(), imageQuery: 'emergency kit preparedness'),
      _VipTool(t('Haber Doğrulama'), Icons.fact_check,
          t('Bir haber linki/metni yapıştır, doğruluk ve manipülasyon analizi al.'),
          onTap: (c) => _push(c, const _NewsVerifyScreen())),
      _VipTool(t('Gelişmiş Risk Skoru'), Icons.speed,
          t('Sağlık, finans, yaşam alanı, aile, seyahat, küresel risk skorları.'),
          run: (s) => s.vipAdvancedScores(), imageQuery: 'dashboard charts data'),
      _VipTool(t('Gelecek Radarı'), Icons.radar,
          t('Yaklaşan riskler ve trendler (kehanet değil, eğilim analizi).'),
          run: (s) => s.vipFutureRadar(), imageQuery: 'futuristic technology city'),
      _VipTool(t('Seyahat Brifingi'), Icons.flight_takeoff,
          t('Gideceğin şehir/ülke için risk + sağlık + güvenlik brifingi.'),
          onTap: (c) => _push(c, const _TravelBriefScreen())),
      _VipTool(t('Risk Geçmişi'), Icons.show_chart,
          t('Kişisel risk puanının zaman içindeki değişimi.'),
          onTap: (c) => _push(c, const _RiskHistoryScreen())),
      _VipTool(t('Akıllı Uyarı'), Icons.notifications_active,
          t('Bildirim türleri, kategoriler, sessiz saatler ve risk eşiği.'),
          onTap: (c) => _push(c, const NotificationSettingsScreen())),
      _VipTool(t('VIP Erken Uyarı Merkezi'), Icons.warning_amber_rounded,
          t('Kritik ve yüksek riskli güncel gelişmeler tek ekranda.'),
          onTap: (c) => _push(c, const _EarlyWarningScreen())),
      _VipTool(t('VIP İstihbarat Raporu'), Icons.description,
          t('Haftalık özet rapor — PDF olarak kaydedebilirsin.'),
          onTap: (c) => _push(c, const _IntelReportScreen())),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t('VIP Merkezi')),
        backgroundColor: LifeRadarColors.navy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF0A2342), Color(0xFF1B1B2F)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold),
            ),
            child: Row(
              children: [
                const Icon(Icons.workspace_premium, color: _gold, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t('VIP araçların Life Radar Asistan ile çalışır. Aşağıdan seç.'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!context.watch<AppState>().hasPersonalInfo)
            Card(
              color: _gold.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.badge_outlined, color: _gold),
                title: Text(t('Daha kişisel analiz için bilgilerini doldur'),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                    t('Yaş, sağlık, ev tipi, aile... → analizler sana özel olur.')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const PersonalInfoScreen())),
              ),
            ),
          ...tools.map((t) => _ToolCard(tool: t)),
        ],
      ),
    );
  }

  static void _push(BuildContext c, Widget w) =>
      Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));
}

class _VipTool {
  final String title;
  final IconData icon;
  final String desc;
  final Future<String> Function(AppState)? run;
  final void Function(BuildContext)? onTap;
  final String? imageQuery;
  _VipTool(this.title, this.icon, this.desc,
      {this.run, this.onTap, this.imageQuery});
}

class _ToolCard extends StatelessWidget {
  final _VipTool tool;
  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _gold.withOpacity(0.15),
          child: Icon(tool.icon, color: _gold),
        ),
        title: Text(tool.title,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(tool.desc),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (tool.onTap != null) {
            tool.onTap!(context);
          } else if (tool.run != null) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AiResultScreen(
                  title: tool.title,
                  run: tool.run!,
                  icon: tool.icon,
                  imageQuery: tool.imageQuery),
            ));
          }
        },
      ),
    );
  }
}

/// Seyahat Brifingi — hedef şehir/ülke gir → AI risk brifingi.
class _TravelBriefScreen extends StatefulWidget {
  const _TravelBriefScreen();
  @override
  State<_TravelBriefScreen> createState() => _TravelBriefScreenState();
}

class _TravelBriefScreenState extends State<_TravelBriefScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go() {
    final dest = _controller.text.trim();
    if (dest.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AiResultScreen(
        title: '$dest — ${t('Seyahat Brifingi')}',
        icon: Icons.flight_takeoff,
        imageQuery: '$dest travel',
        run: (s) => s.vipTravelBrief(dest),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Seyahat Brifingi'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t('Gideceğin şehir veya ülkeyi yaz; Life Radar Asistan güvenlik, sağlık ve afet açısından kısa bir brifing hazırlasın.'),
            style: const TextStyle(color: LifeRadarColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _go(),
            decoration: InputDecoration(
              labelText: t('Şehir / Ülke'),
              prefixIcon: const Icon(Icons.place_outlined),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _go,
            icon: const Icon(Icons.travel_explore),
            label: Text(t('Brifing Al')),
            style:
                ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }
}

/// Risk Geçmişi — kişisel risk puanının zaman çizelgesi.
class _RiskHistoryScreen extends StatelessWidget {
  const _RiskHistoryScreen();

  @override
  Widget build(BuildContext context) {
    final hist = context.watch<AppState>().riskHistory;
    final current = hist.isNotEmpty ? hist.last : 0;
    final maxV = hist.isEmpty ? 0 : hist.reduce((a, b) => a > b ? a : b);
    final minV = hist.isEmpty ? 0 : hist.reduce((a, b) => a < b ? a : b);
    final trend = hist.length >= 2
        ? hist.last - hist[hist.length - 2]
        : 0;

    return Scaffold(
      appBar: AppBar(title: Text(t('Risk Geçmişi'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hist.length < 2)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t('Geçmiş oluşması için uygulamayı birkaç kez aç/yenile. Her açılışta o anki risk puanın kaydedilir.'),
                  style: const TextStyle(color: LifeRadarColors.textSecondary),
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: RiskHistoryChart(data: hist),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(t('Şu an'), '$current', _gold),
              _Stat(t('En yüksek'), '$maxV', LifeRadarColors.riskHigh),
              _Stat(t('En düşük'), '$minV', LifeRadarColors.riskLow),
              _Stat(t('Değişim'), '${trend >= 0 ? '+' : ''}$trend',
                  trend > 0 ? LifeRadarColors.riskHigh : LifeRadarColors.riskLow),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900, color: color)),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: LifeRadarColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

/// VIP Erken Uyarı Merkezi — kritik/yüksek riskli gelişmeler.
class _EarlyWarningScreen extends StatelessWidget {
  const _EarlyWarningScreen();

  @override
  Widget build(BuildContext context) {
    final warnings = context.watch<AppState>().earlyWarnings;
    return Scaffold(
      appBar: AppBar(title: Text(t('VIP Erken Uyarı Merkezi'))),
      body: warnings.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_outlined,
                        size: 48, color: LifeRadarColors.riskLow),
                    const SizedBox(height: 12),
                    Text(
                      t('Şu an kritik veya yüksek riskli bir gelişme görünmüyor.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: LifeRadarColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LifeRadarColors.riskHigh.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: LifeRadarColors.riskHigh),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${warnings.length} ${t('öncelikli uyarı — yüksek/kritik riskli gelişmeler.')}',
                          style: const TextStyle(
                              color: LifeRadarColors.riskHigh,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                ...warnings.map((e) => EventCard(event: e)),
              ],
            ),
    );
  }
}

/// VIP İstihbarat Raporu — AI ile haftalık rapor + PDF indirme.
class _IntelReportScreen extends StatefulWidget {
  const _IntelReportScreen();
  @override
  State<_IntelReportScreen> createState() => _IntelReportScreenState();
}

class _IntelReportScreenState extends State<_IntelReportScreen> {
  Future<String>? _future;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _future = context.read<AppState>().vipIntelReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('VIP İstihbarat Raporu'))),
      body: FutureBuilder<String>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: _gold),
                  const SizedBox(height: 12),
                  Text(t('Rapor hazırlanıyor...'),
                      style: const TextStyle(color: LifeRadarColors.textSecondary)),
                ],
              ),
            );
          }
          final text = snap.data ?? t('Rapor oluşturulamadı.');
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AiRichText(text: text, accent: _gold),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => openHtmlReport(t('VIP İstihbarat Raporu'), text),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(t('PDF olarak indir / yazdır')),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Haber Doğrulama — metin/link girip AI analizi al.
class _NewsVerifyScreen extends StatefulWidget {
  const _NewsVerifyScreen();
  @override
  State<_NewsVerifyScreen> createState() => _NewsVerifyScreenState();
}

class _NewsVerifyScreenState extends State<_NewsVerifyScreen> {
  final _controller = TextEditingController();
  String? _result;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final r = await context.read<AppState>().vipVerifyNews(_controller.text.trim());
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('Haber Doğrulama'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t('Şüphelendiğin haberin linkini veya metnini yapıştır; Life Radar Asistan doğruluk ve manipülasyon riskini değerlendirsin.'),
            style: const TextStyle(color: LifeRadarColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: t('Haber linki veya metni...'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loading ? null : _verify,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.fact_check),
            label: Text(t('Doğrula')),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(_result!,
                    style: const TextStyle(height: 1.5)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Aile Koruma Merkezi — üye ekle/sil + üyeye özel AI analizi.
class _FamilyCenterScreen extends StatefulWidget {
  const _FamilyCenterScreen();
  @override
  State<_FamilyCenterScreen> createState() => _FamilyCenterScreenState();
}

class _FamilyCenterScreenState extends State<_FamilyCenterScreen> {
  void _addDialog() {
    final name = TextEditingController();
    final age = TextEditingController();
    final health = TextEditingController();
    final allergies = TextEditingController();
    final special = TextEditingController();
    final notes = TextEditingController();
    String relation = 'Eş';
    String gender = '';

    InputDecoration dec(String l) => InputDecoration(
        labelText: l, border: const OutlineInputBorder(), isDense: true);

    showDialog(
      context: context,
      builder: (dctx) => StatefulBuilder(
        builder: (_, setSt) => AlertDialog(
          title: Text(t('Aile Üyesi Ekle')),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: name, decoration: dec(t('Ad *'))),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: relation,
                    decoration: dec(t('Yakınlık')),
                    items: const [
                      'Eş', 'Çocuk', 'Anne', 'Baba', 'Kardeş', 'Büyükanne',
                      'Büyükbaba', 'Diğer'
                    ].map((r) => DropdownMenuItem(value: r, child: Text(t(r)))).toList(),
                    onChanged: (v) => setSt(() => relation = v ?? 'Eş'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                            controller: age,
                            keyboardType: TextInputType.number,
                            decoration: dec(t('Yaş'))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: gender.isEmpty ? null : gender,
                          decoration: dec(t('Cinsiyet')),
                          items: const ['Kadın', 'Erkek']
                              .map((g) =>
                                  DropdownMenuItem(value: g, child: Text(t(g))))
                              .toList(),
                          onChanged: (v) => setSt(() => gender = v ?? ''),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                      controller: health,
                      decoration: dec(t('Kronik hastalık / sürekli ilaç')),
                      maxLines: 2),
                  const SizedBox(height: 10),
                  TextField(controller: allergies, decoration: dec(t('Alerjiler'))),
                  const SizedBox(height: 10),
                  TextField(
                      controller: special,
                      decoration:
                          dec(t('Özel durum (hamilelik, engellilik, vb.)'))),
                  const SizedBox(height: 10),
                  TextField(
                      controller: notes,
                      decoration: dec(t('Ek not (ops.)')),
                      maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dctx),
                child: Text(t('Vazgeç'))),
            ElevatedButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;
                context.read<AppState>().addFamilyMember(FamilyMember(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      name: name.text.trim(),
                      relation: relation,
                      age: age.text.trim(),
                      gender: gender,
                      health: health.text.trim(),
                      allergies: allergies.text.trim(),
                      special: special.text.trim(),
                      notes: notes.text.trim(),
                    ));
                Navigator.pop(dctx);
              },
              child: Text(t('Ekle')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final family = context.watch<AppState>().family;
    return Scaffold(
      appBar: AppBar(title: Text(t('Aile Koruma Merkezi'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDialog,
        backgroundColor: _gold,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(t('Üye Ekle'), style: const TextStyle(color: Colors.white)),
      ),
      body: family.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  t('Henüz aile üyesi yok. Sağ alttaki "Üye Ekle" ile başla.\nHer üye için Life Radar Asistan özel risk analizi üretebilir.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: LifeRadarColors.textSecondary),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: family
                  .map((m) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: _gold,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text('${m.name} · ${t(m.relation)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          subtitle: Text([
                            if (m.age.isNotEmpty) '${m.age} ${t('yaş')}',
                            if (m.gender.isNotEmpty) t(m.gender),
                            if (m.health.isNotEmpty) m.health,
                            if (m.special.isNotEmpty) m.special,
                          ].join(' · ')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: t('Life Radar Asistan Analizi'),
                                icon: const Icon(Icons.psychology,
                                    color: _gold),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AiResultScreen(
                                      title: '${m.name} — Life Radar Asistan',
                                      icon: Icons.psychology,
                                      imageQuery: 'family together',
                                      run: (s) => s.vipFamilyAnalysis(m),
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: t('Sil'),
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => context
                                    .read<AppState>()
                                    .removeFamilyMember(m.id),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
