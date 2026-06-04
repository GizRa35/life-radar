import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/event_category.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/event_card.dart';

/// SAYFA 2 — GÜNDEM
/// 9 kategori sekmesi: Dünya·Türkiye·Sağlık·Ekonomi·Teknoloji·Enerji·Güvenlik·İklim·Afetler
class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  int _length = 0;

  void _ensureController(int length) {
    if (_controller == null || _length != length) {
      _controller?.dispose();
      _controller = TabController(length: length, vsync: this);
      _length = length;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = state.activeTopics;
    _ensureController(categories.length);

    // Ana Sayfa'dan "Devamını Görüntüle" ile gelinen kategoriye geç.
    final pending = state.agendaCategory;
    if (pending != null) {
      final idx = categories.indexOf(pending);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (idx >= 0 && _controller != null && _controller!.index != idx) {
          _controller!.animateTo(idx);
        }
        context.read<AppState>().clearAgendaCategory();
      });
    }

    return Column(
      children: [
        Material(
          color: LifeRadarColors.background,
          child: TabBar(
            controller: _controller,
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
            controller: _controller,
            children: [
              for (final c in categories) _CategoryFeed(category: c),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryFeed extends StatelessWidget {
  final EventCategory category;
  const _CategoryFeed({required this.category});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final events = state.eventsByCategory(category);

    if (events.isEmpty) {
      if (state.loadingFeeds) {
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: LifeRadarColors.turquoise),
              SizedBox(height: 12),
              Text('Güncel haberler yükleniyor...',
                  style: TextStyle(color: LifeRadarColors.textSecondary)),
            ],
          ),
        );
      }
      return EmptyState(
        icon: category.icon,
        color: category.color,
        title: '${category.label} kategorisinde gelişme yok',
        subtitle: 'Aşağı çekerek veya aşağıdaki düğmeyle yenileyebilirsin.',
        action: TextButton.icon(
          onPressed: () => context.read<AppState>().loadFeeds(),
          icon: const Icon(Icons.refresh),
          label: const Text('Yenile'),
        ),
      );
    }

    return RefreshIndicator(
      color: LifeRadarColors.turquoise,
      onRefresh: () => context.read<AppState>().loadFeeds(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 90),
        children: events.map((e) => EventCard(event: e)).toList(),
      ),
    );
  }
}
