import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/app_notification.dart';
import '../state/app_state.dart';
import '../widgets/risk_badge.dart';

/// SAYFA 10 — BİLDİRİMLER (üst bardaki zilden açılan ayrı tam ekran)
/// Kategoriler: Sağlık · Ekonomi · Afet · Dünya · Sistem
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationCategory? _filter; // null = tümü

  @override
  Widget build(BuildContext context) {
    final all = context.watch<AppState>().notifications;
    final items = _filter == null
        ? all
        : all.where((n) => n.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                for (final c in NotificationCategory.values)
                  _FilterChip(
                    label: c.label,
                    selected: _filter == c,
                    onTap: () => setState(() => _filter = c),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: items.map((n) => _NotificationTile(item: n)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: LifeRadarColors.navy,
        labelStyle: TextStyle(
          color: selected ? Colors.white : LifeRadarColors.navy,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: LifeRadarColors.cardBackground,
        side: BorderSide.none,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('d MMM, HH:mm', 'tr').format(item.time);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.risk.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.category.icon, color: item.risk.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: LifeRadarColors.textPrimary,
                          ),
                        ),
                      ),
                      RiskBadge(level: item.risk, compact: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.summary,
                    style: const TextStyle(
                      color: LifeRadarColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.category.label} · $timeStr',
                    style: const TextStyle(
                      color: LifeRadarColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
