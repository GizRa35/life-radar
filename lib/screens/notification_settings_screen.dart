import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
import '../core/theme.dart';
import '../models/event_category.dart';
import '../state/app_state.dart';
import '../widgets/form_widgets.dart';

/// Bildirim Ayarları — izin durumu, türler, kategoriler ve sessiz saatler.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final enabled = state.alertsEnabled;

    return Scaffold(
      appBar: AppBar(title: Text(t('Bildirim Ayarları'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _PermissionCard(),
          const SizedBox(height: 12),

          // Ana anahtar
          Card(
            child: SwitchListTile(
              value: enabled,
              activeColor: LifeRadarColors.turquoise,
              onChanged: (v) => context.read<AppState>().setAlertsEnabled(v),
              secondary: const Icon(Icons.notifications_active_outlined,
                  color: LifeRadarColors.navy),
              title: Text(t('Bildirimleri aç'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(t(
                  'Risk eşiği aşılınca, kritik gelişmede ve seçtiğin durumlarda tarayıcı bildirimi gönderir.')),
            ),
          ),

          _Disabled(
            disabled: !enabled,
            child: Column(
              children: [
                const SizedBox(height: 8),
                FormSectionHeader(
                    icon: Icons.tune, title: t('Bildirim Türleri')),
                _TypeTile(
                  icon: Icons.crisis_alert,
                  color: LifeRadarColors.riskHigh,
                  title: t('Kritik / acil uyarılar'),
                  subtitle:
                      t('Yüksek ve kritik riskli gelişmeler (deprem, afet…)'),
                  value: state.notifCritical,
                  onChanged: (v) => context.read<AppState>().setNotifCritical(v),
                ),
                _TypeTile(
                  icon: Icons.wb_sunny_outlined,
                  color: LifeRadarColors.riskMedium,
                  title: t('Günlük özet brifingi'),
                  subtitle: t('Günde bir kez günün risk özeti'),
                  value: state.notifDailySummary,
                  onChanged: (v) =>
                      context.read<AppState>().setNotifDailySummary(v),
                ),
                _TypeTile(
                  icon: Icons.bookmark_added_outlined,
                  color: LifeRadarColors.turquoise,
                  title: t('Takip edilen konularda yeni haber'),
                  subtitle: t('Takip ettiğin kategorilerde önemli gelişme olunca'),
                  value: state.notifFollowedNews,
                  onChanged: (v) =>
                      context.read<AppState>().setNotifFollowedNews(v),
                ),
                _TypeTile(
                  icon: Icons.speed_outlined,
                  color: LifeRadarColors.navy,
                  title: t('Risk puanı değişimi'),
                  subtitle: t('Kişisel risk puanın eşiği aşınca uyar'),
                  value: state.notifRiskChange,
                  onChanged: (v) =>
                      context.read<AppState>().setNotifRiskChange(v),
                ),
                if (state.notifRiskChange) const _ThresholdCard(),

                const SizedBox(height: 8),
                FormSectionHeader(
                    icon: Icons.category_outlined, title: t('Kategoriler')),
                const _CategoryCard(),

                const SizedBox(height: 8),
                FormSectionHeader(
                    icon: Icons.bedtime_outlined, title: t('Sessiz Saatler')),
                const _QuietHoursCard(),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok =
                          await context.read<AppState>().sendTestNotification();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? t('Test bildirimi gönderildi.')
                              : t('Bildirim izni verilmedi. Tarayıcı ayarlarından izin ver.')),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_outlined),
                    label: Text(t('Test bildirimi gönder')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Tarayıcı bildirim izni durumu + izin iste.
class _PermissionCard extends StatelessWidget {
  const _PermissionCard();

  @override
  Widget build(BuildContext context) {
    final perm = context.watch<AppState>().notifPermission;
    late final Color c;
    late final IconData icon;
    late final String label;
    switch (perm) {
      case 'granted':
        c = LifeRadarColors.riskLow;
        icon = Icons.check_circle_outline;
        label = t('Bildirim izni verildi');
        break;
      case 'denied':
        c = LifeRadarColors.riskHigh;
        icon = Icons.block_outlined;
        label = t('Bildirim izni reddedildi — tarayıcı ayarlarından aç');
        break;
      case 'unsupported':
        c = LifeRadarColors.textSecondary;
        icon = Icons.desktop_access_disabled_outlined;
        label = t('Bu platformda tarayıcı bildirimi desteklenmiyor');
        break;
      default:
        c = LifeRadarColors.riskMedium;
        icon = Icons.help_outline;
        label = t('Bildirim izni henüz verilmedi');
    }
    return Card(
      color: c.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: c),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(color: c, fontWeight: FontWeight.w600)),
            ),
            if (perm == 'default')
              TextButton(
                onPressed: () =>
                    context.read<AppState>().askNotifyPermission(),
                child: Text(t('İzin ver')),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThresholdCard extends StatelessWidget {
  const _ThresholdCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t('Uyarı eşiği:')} ${state.alertThreshold}/100',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: LifeRadarColors.navy)),
            Slider(
              value: state.alertThreshold.toDouble(),
              min: 30,
              max: 95,
              divisions: 13,
              activeColor: LifeRadarColors.turquoise,
              label: '${state.alertThreshold}',
              onChanged: (v) =>
                  context.read<AppState>().setAlertThreshold(v.round()),
            ),
            Text(t('Kişisel risk puanın bu değeri aşarsa uyarılırsın.'),
                style: const TextStyle(
                    fontSize: 12, color: LifeRadarColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('Hangi kategorilerde bildirim almak istersin?'),
                style: const TextStyle(
                    fontSize: 13, color: LifeRadarColors.textSecondary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: EventCategory.values.map((cat) {
                final on = state.isNotifCategoryOn(cat);
                return FilterChip(
                  avatar: Icon(cat.icon,
                      size: 18, color: on ? Colors.white : cat.color),
                  label: Text(t(cat.label)),
                  selected: on,
                  showCheckmark: false,
                  selectedColor: cat.color,
                  backgroundColor: LifeRadarColors.cardBackground,
                  labelStyle: TextStyle(
                    color: on ? Colors.white : LifeRadarColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide.none,
                  onSelected: (_) =>
                      context.read<AppState>().toggleNotifCategory(cat),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuietHoursCard extends StatelessWidget {
  const _QuietHoursCard();

  String _fmt(int h) => '${h.toString().padLeft(2, '0')}:00';

  Future<void> _pick(BuildContext context, bool isStart) async {
    final state = context.read<AppState>();
    final initial = TimeOfDay(
        hour: isStart ? state.quietStart : state.quietEnd, minute: 0);
    final res = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (res == null) return;
    if (isStart) {
      state.setQuietHours(res.hour, state.quietEnd);
    } else {
      state.setQuietHours(state.quietStart, res.hour);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            value: state.quietEnabled,
            activeColor: LifeRadarColors.turquoise,
            secondary: const Icon(Icons.do_not_disturb_on_outlined,
                color: LifeRadarColors.navy),
            title: Text(t('Rahatsız etme'),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(t('Belirlediğin saatlerde bildirim gönderilmez')),
            onChanged: (v) => context.read<AppState>().setQuietEnabled(v),
          ),
          if (state.quietEnabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _TimeBox(
                      label: t('Başlangıç'),
                      value: _fmt(state.quietStart),
                      onTap: () => _pick(context, true),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward,
                        color: LifeRadarColors.textSecondary),
                  ),
                  Expanded(
                    child: _TimeBox(
                      label: t('Bitiş'),
                      value: _fmt(state.quietEnd),
                      onTap: () => _pick(context, false),
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

class _TimeBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _TimeBox(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: LifeRadarColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: LifeRadarColors.textSecondary)),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.schedule,
                    size: 18, color: LifeRadarColors.navy),
                const SizedBox(width: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: LifeRadarColors.navy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _TypeTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        value: value,
        activeColor: LifeRadarColors.turquoise,
        secondary: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: LifeRadarColors.textSecondary)),
        onChanged: onChanged,
      ),
    );
  }
}


/// Ana anahtar kapalıyken alt bölümleri soluk ve etkisiz gösterir.
class _Disabled extends StatelessWidget {
  final bool disabled;
  final Widget child;
  const _Disabled({required this.disabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(opacity: disabled ? 0.45 : 1, child: child),
    );
  }
}
