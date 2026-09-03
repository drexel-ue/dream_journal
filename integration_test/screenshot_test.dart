import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:dream_journal/database/app_database.dart';
import 'package:dream_journal/database/dream_dao.dart';
import 'package:dream_journal/screens/affirmations/bedtime_affirmation_screen.dart';
import 'package:dream_journal/screens/calendar/dream_calendar_screen.dart';
import 'package:dream_journal/screens/entry/new_entry_screen.dart';
import 'package:dream_journal/screens/graph/cosmic_graph_screen.dart';
import 'package:dream_journal/screens/graph/node_detail_sheet.dart';
import 'package:dream_journal/screens/list/dream_detail_screen.dart';
import 'package:dream_journal/screens/list/dream_list_screen.dart';
import 'package:dream_journal/screens/main_navigation_shell.dart';
import 'package:dream_journal/services/demo_data_service.dart';
import 'package:dream_journal/state/dream_provider.dart';
import 'package:dream_journal/state/graph_provider.dart';
import 'package:dream_journal/theme/cosmic_theme.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Capture high-res and scrolling screenshots on iOS Simulator', (WidgetTester tester) async {
    // Initialize demo database
    final dbProvider = AppDatabase.demo;
    await dbProvider.resetDemoDatabase();
    final dao = DreamDao(dbProvider: dbProvider);

    final dreamProvider = DreamProvider(dao: dao);
    final graphProvider = GraphProvider(dao: dao);
    await dreamProvider.refresh();
    await graphProvider.loadGraph();

    Widget buildAppWrapper(Widget child) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<DreamProvider>.value(value: dreamProvider),
          ChangeNotifierProvider<GraphProvider>.value(value: graphProvider),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: CosmicTheme.darkTheme,
          home: Scaffold(
            backgroundColor: CosmicColors.background,
            body: child,
          ),
        ),
      );
    }

    Future<void> takeAppScreenshot(String name) async {
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await binding.takeScreenshot(name);
    }

    Future<void> takeScrollingScreenshots(
      String baseName, {
      double dragDistance = 600.0,
      Offset dragStart = const Offset(15, 650),
    }) async {
      await takeAppScreenshot(baseName);
      await tester.dragFrom(dragStart, Offset(0, -dragDistance));
      await tester.pump(const Duration(milliseconds: 500));
      await takeAppScreenshot('${baseName}_scrolled');
    }

    final demoDreams = DemoDataService.getDemoDreams();
    final sampleDream = demoDreams.firstWhere((d) => d.isLucid);

    // 01 MORNING CAPTURE (PART 1: DETAILS - Top & Scrolled)
    await tester.pumpWidget(buildAppWrapper(NewEntryScreen(existingDream: sampleDream)));
    await takeScrollingScreenshots('01_new_entry_details', dragDistance: 550.0);

    // 02 MORNING CAPTURE (PART 2: REFLECTION & SKETCH - Top & Scrolled)
    await tester.tap(find.text('2. Reflection & Sketch'));
    await tester.pump(const Duration(milliseconds: 400));
    await takeScrollingScreenshots('02_new_entry_reflection', dragDistance: 780.0);

    // 03 DREAM CHRONICLE (FEED - Top & Scrolled)
    await tester.pumpWidget(buildAppWrapper(const DreamListScreen()));
    await takeScrollingScreenshots('03_dream_chronicle_feed', dragDistance: 450.0, dragStart: const Offset(200, 650));

    // 04 DREAM DETAIL VIEW (Top & Scrolled)
    await tester.pumpWidget(buildAppWrapper(DreamDetailScreen(dream: sampleDream)));
    await takeScrollingScreenshots('04_dream_detail_view', dragDistance: 850.0);

    // 05 DREAM CALENDAR (Top & Scrolled)
    await tester.pumpWidget(buildAppWrapper(const DreamCalendarScreen()));
    await takeScrollingScreenshots('05_dream_calendar', dragDistance: 280.0, dragStart: const Offset(200, 650));

    // 06 COSMIC CONSTELLATION GRAPH
    await tester.pumpWidget(buildAppWrapper(const CosmicGraphScreen()));
    await takeAppScreenshot('06_cosmic_constellation_graph');

    // 07 NODE DETAIL SHEET (Flying Node)
    final flyingNode = graphProvider.visibleNodes.firstWhere(
      (n) => n.name == 'Flying',
      orElse: () => graphProvider.visibleNodes.first,
    );
    final connectedDreams = await dao.getDreams(tagFilter: flyingNode.name);
    await tester.pumpWidget(
      buildAppWrapper(
        Scaffold(
          backgroundColor: Colors.black54,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: NodeDetailSheet(
              node: flyingNode,
              connectedDreams: connectedDreams,
            ),
          ),
        ),
      ),
    );
    await takeAppScreenshot('07_node_detail_sheet');

    // 08 BEDTIME AFFIRMATIONS
    await tester.pumpWidget(buildAppWrapper(const BedtimeAffirmationScreen()));
    await takeAppScreenshot('08_bedtime_affirmations');

    // 09 MAIN NAVIGATION SHELL WITH DEMO BANNER
    await dreamProvider.setDemoMode(true);
    await graphProvider.setDemoMode(true);
    await tester.pumpWidget(buildAppWrapper(const MainNavigationShell()));
    await takeAppScreenshot('09_demo_mode_shell');
  });
}
