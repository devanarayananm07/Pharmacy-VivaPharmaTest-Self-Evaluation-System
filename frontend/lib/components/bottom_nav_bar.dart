import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/obsidian_theme.dart';
import '../providers/auth_provider.dart';

class BottomNavBar extends ConsumerWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState.role == 'Admin';

    final List<BottomNavigationBarItem> items;
    final int mappedIndex;
    final Function(int) onTap;

    items = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: isAdmin ? 'Dashboard' : 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.menu_book_outlined),
        activeIcon: Icon(Icons.menu_book),
        label: 'Study',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.leaderboard_outlined),
        activeIcon: Icon(Icons.leaderboard),
        label: 'Score',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    mappedIndex = currentIndex;

    onTap = (index) {
      if (index == currentIndex) return;
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;
        case 1:
          context.go('/study');
          break;
        case 2:
          context.go('/dashboard/scores');
          break;
        case 3:
          context.go('/profile');
          break;
      }
    };

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: ObsidianTheme.outlineVariant, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: ObsidianTheme.surfaceContainerLowest,
        selectedItemColor: ObsidianTheme.primary,
        unselectedItemColor: ObsidianTheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        currentIndex: mappedIndex,
        onTap: onTap,
        items: items,
      ),
    );
  }
}
