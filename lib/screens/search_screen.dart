import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/radar_event.dart';
import '../state/app_state.dart';
import '../widgets/event_card.dart';

/// Haberlerde arama — başlık, özet ve kaynakta canlı filtreleme.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final List<RadarEvent> results =
        _query.trim().isEmpty ? const [] : state.searchEvents(_query);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Haberlerde ara...',
            border: InputBorder.none,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: _query.trim().isEmpty
          ? const _Hint(
              icon: Icons.search,
              text: 'Bir kelime yaz; başlık, özet ve kaynaklarda ararım.',
            )
          : results.isEmpty
              ? const _Hint(
                  icon: Icons.search_off,
                  text: 'Eşleşen haber bulunamadı. Farklı bir kelime dene.',
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 4),
                      child: Text('${results.length} sonuç',
                          style: const TextStyle(
                              color: LifeRadarColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                    ...results.map((e) => EventCard(event: e)),
                  ],
                ),
    );
  }
}

class _Hint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Hint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: LifeRadarColors.textSecondary),
            const SizedBox(height: 16),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: LifeRadarColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
