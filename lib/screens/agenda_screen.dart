import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n.dart';
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
    // İlk sekme "Senin İçin" (kişisel akış), ardından kategoriler.
    _ensureController(categories.length + 1);

    // Ana Sayfa'dan "Devamını Görüntüle" ile gelinen kategoriye geç.
    final pending = state.agendaCategory;
    if (pending != null) {
      // +1: "Senin İçin" sekmesi başa eklendiği için kategori indeksi kayar.
      final idx = categories.indexOf(pending) + 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (idx >= 1 && _controller != null && _controller!.index != idx) {
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
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16),
                    const SizedBox(width: 6),
                    Text(t('Senin İçin')),
                  ],
                ),
              ),
              for (final c in categories)
                Tab(
                  child: Row(
                    children: [
                      Icon(c.icon, size: 16),
                      const SizedBox(width: 6),
                      Text(t(c.label)),
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
              const _ForYouFeed(),
              for (final c in categories) _CategoryFeed(category: c),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Senin İçin" akışı — takip edilen konular + önem sırasına göre kişisel akış.
class _ForYouFeed extends StatelessWidget {
  const _ForYouFeed();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final events = state.forYouEvents;
    final followed = state.followedTopics.isNotEmpty;

    if (events.isEmpty) {
      if (state.loadingFeeds) {
        return const Center(
          child: CircularProgressIndicator(color: LifeRadarColors.turquoise),
        );
      }
      return EmptyState(
        icon: Icons.auto_awesome,
        color: LifeRadarColors.turquoise,
        title: t('Senin için akış hazırlanıyor'),
        subtitle: t('Profil > Takip Edilen Konular\'dan ilgi alanı seçersen akışın kişiselleşir.'),
        action: TextButton.icon(
          onPressed: () => context.read<AppState>().loadFeeds(),
          icon: const Icon(Icons.refresh),
          label: Text(t('Yenile')),
        ),
      );
    }

    return RefreshIndicator(
      color: LifeRadarColors.turquoise,
      onRefresh: () => context.read<AppState>().loadFeeds(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 90),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              followed
                  ? t('Takip ettiğin konulara göre seçildi')
                  : t('Bugünün en önemli gelişmeleri'),
              style: const TextStyle(
                color: LifeRadarColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          ...events.map((e) => EventCard(event: e)),
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
    final state = context.watch<AppState>();
    final events = state.eventsByCategory(category);

    if (events.isEmpty) {
      if (state.loadingFeeds) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                  color: LifeRadarColors.turquoise),
              const SizedBox(height: 12),
              Text(t('Güncel haberler yükleniyor...'),
                  style: const TextStyle(color: LifeRadarColors.textSecondary)),
            ],
          ),
        );
      }
      return EmptyState(
        icon: category.icon,
        color: category.color,
        title: '${t(category.label)} ${t('kategorisinde gelişme yok')}',
        subtitle: t('Aşağı çekerek veya aşağıdaki düğmeyle yenileyebilirsin.'),
        action: TextButton.icon(
          onPressed: () => context.read<AppState>().loadFeeds(),
          icon: const Icon(Icons.refresh),
          label: Text(t('Yenile')),
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
