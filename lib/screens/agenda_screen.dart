import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';

/// SAYFA 2 — GÜNDEM
/// 9 kategori sekmesi: Dünya·Türkiye·Sağlık·Ekonomi·Teknoloji·Enerji·Güvenlik·İklim·Afetler
class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = EventCategory.values;

    return DefaultTabController(
      length: categories.length,
      child: Column(
        children: [
          Material(
            color: LifeRadarColors.background,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: LifeRadarColors.navy,
              unselectedLabelColor: LifeRadarColors.textSecondary,
              indicatorColor: LifeRadarColors.turquoise,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: [
                for (final c in categories)
                  Tab(
                    child: Row(
                      children: [
                        Icon(c.icon, size: 16),
                        const SizedBox(width: 6),
                        Text(c.label),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final c in categories) _CategoryFeed(category: c),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryFeed extends StatelessWidget {
  final EventCategory category;
  const _CategoryFeed({required this.category});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<AppState>().eventsByCategory(category);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 48, color: LifeRadarColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              '${category.label} kategorisinde\nşu an gelişme yok.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: LifeRadarColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: events.map((e) => EventCard(event: e)).toList(),
    );
  }
}
