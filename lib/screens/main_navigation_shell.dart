import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';
import 'affirmations/bedtime_affirmation_screen.dart';
import 'calendar/dream_calendar_screen.dart';
import 'entry/new_entry_screen.dart';
import 'graph/cosmic_graph_screen.dart';
import 'list/dream_list_screen.dart';

import '../widgets/demo_banner.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  // 0 = Capture (New Entry screen opens first as requested!)
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      NewEntryScreen(
        onSaved: () {
          // After recording, gently switch to the list feed or stay
          _navigateToIndex(1);
        },
      ),
      DreamListScreen(
        onGoToCapture: () => _navigateToIndex(0),
      ),
      DreamCalendarScreen(
        onGoToCapture: () => _navigateToIndex(0),
      ),
      CosmicGraphScreen(
        onGoToCapture: () => _navigateToIndex(0),
      ),
      const BedtimeAffirmationScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          const DemoBanner(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: CosmicColors.backgroundSecondary.withOpacity(0.85),
              border: const Border(
                top: BorderSide(color: CosmicColors.borderSubtle, width: 1),
              ),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToIndex,
              indicatorColor: CosmicColors.astralViolet.withOpacity(0.35),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.edit_note, color: CosmicColors.textMuted),
                  selectedIcon: Icon(Icons.edit_note, color: CosmicColors.celestialCyan),
                  label: 'Capture',
                ),
                NavigationDestination(
                  icon: Icon(Icons.view_agenda_outlined, color: CosmicColors.textMuted),
                  selectedIcon: Icon(Icons.view_agenda, color: CosmicColors.lucidPurple),
                  label: 'Feed',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined, color: CosmicColors.textMuted),
                  selectedIcon: Icon(Icons.calendar_month, color: CosmicColors.lucidPurple),
                  label: 'Calendar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.hub_outlined, color: CosmicColors.textMuted),
                  selectedIcon: Icon(Icons.hub, color: CosmicColors.starlightGold),
                  label: 'Constellation',
                ),
                NavigationDestination(
                  icon: Icon(Icons.nights_stay_outlined, color: CosmicColors.textMuted),
                  selectedIcon: Icon(Icons.nights_stay, color: CosmicColors.starlightGold),
                  label: 'Intention',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
