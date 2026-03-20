import 'package:flutter/material.dart';
import 'manga_quotes_page.dart';
import 'today_poison_page.dart';
import 'trending_quotes_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = [
    TodayPoisonPage(),
    MangaQuotesPage(),
    TrendingQuotesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa_rounded),
            label: '今日毒鸡汤',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_outlined),
            selectedIcon: Icon(Icons.bolt_rounded),
            label: '热血漫画句',
          ),
          NavigationDestination(
            icon: Icon(Icons.whatshot_outlined),
            selectedIcon: Icon(Icons.whatshot_rounded),
            label: '热门网络句子',
          ),
        ],
      ),
    );
  }
}
