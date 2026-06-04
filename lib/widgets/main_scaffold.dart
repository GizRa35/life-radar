import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../screens/agenda_screen.dart';
import '../screens/ai_assistant_screen.dart';
import '../screens/guide_screen.dart';
import '../screens/home_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/radar_screen.dart';
import '../screens/search_screen.dart';
import '../state/app_state.dart';

/// Uygulamanın ana kabuğu: 5 sekmeli alt navigasyon, üst barda bildirim zili,
/// her ekranda erişilebilen AI Asistanı yüzen butonu.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const _titles = ['Ana Sayfa', 'Gündem', 'Radar', 'Rehber', 'Profil'];

  final _screens = const [
    HomeScreen(),
    AgendaScreen(),
    RadarScreen(),
    GuideScreen(),
    ProfileScreen(),
  ];

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  void _openAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final unread = state.unreadNotificationCount;
    final index = state.navIndex;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.radar, color: LifeRadarColors.turquoise),
            const SizedBox(width: 8),
            Text(_titles[index]),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ara',
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Bildirimler',
                onPressed: _openNotifications,
                icon: const Icon(Icons.notifications_outlined),
              ),
              if (unread > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: LifeRadarColors.riskHigh,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$unread',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAssistant,
        backgroundColor: LifeRadarColors.turquoise,
        tooltip: 'Life Radar Asistan',
        child: const Icon(Icons.auto_awesome, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => context.read<AppState>().goToTab(i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Gündem',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radar_outlined),
            activeIcon: Icon(Icons.radar),
            label: 'Radar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Rehber',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
