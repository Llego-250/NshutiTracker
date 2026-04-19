import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'planner_screen.dart';
import 'find_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _idx = 0;

  final _screens = const [
    DashboardScreen(),
    PlannerScreen(),
    FindScreen(),
    ProfileScreen(),
  ];

  void _openChat() => showModalBottomSheet(
        context: context,
        backgroundColor: bgCard,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        isScrollControlled: true,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        builder: (_) => const ChatScreen(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: _screens[_idx],
      floatingActionButton: GestureDetector(
        onTap: _openChat,
        child: Container(
          width: 56, height: 56,
          decoration: const BoxDecoration(gradient: btnGradient, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: bgCard,
        height: 60,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'HOME', 0),
            _navItem(Icons.calendar_today_outlined, 'PLANNER', 1),
            const SizedBox(width: 56),
            _navItem(Icons.search, 'FIND', 2),
            _navItem(Icons.person_outline, 'PROFILE', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int idx) {
    final active = _idx == idx;
    return GestureDetector(
      onTap: () => setState(() => _idx = idx),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: active ? accentPurple : textSecondary, size: 22),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: active ? accentPurple : textSecondary,
                fontSize: 9,
                fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}
