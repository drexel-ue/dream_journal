import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

class ScreenshotDatabase extends AppDatabase {
  ScreenshotDatabase() : super();

  Database? _db;

  @override
  Future<Database> get database async {
    if (_db != null) return _db!;
    sqfliteFfiInit();
    _db = await databaseFactoryFfi.openDatabase(
      'file:mem_screenshot?mode=memory&cache=shared',
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS dreams (
              id TEXT PRIMARY KEY,
              date TEXT NOT NULL,
              title TEXT NOT NULL,
              description TEXT,
              is_no_recall INTEGER DEFAULT 0,
              actions_events TEXT,
              meanings_associations TEXT,
              is_lucid INTEGER DEFAULT 0,
              recall_context TEXT,
              notes TEXT,
              sketch_data TEXT,
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS dream_emotions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              dream_id TEXT NOT NULL,
              emotion TEXT NOT NULL,
              phase TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS dream_signs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              dream_id TEXT NOT NULL,
              name TEXT NOT NULL,
              category TEXT NOT NULL
            )
          ''');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_dreams_date ON dreams(date)');
          await db.execute('CREATE INDEX IF NOT EXISTS idx_signs_dream ON dream_signs(dream_id)');
        },
      ),
    );

    // Populate with demo dreams
    final demoDreams = DemoDataService.getDemoDreams();
    for (final d in demoDreams) {
      await _db!.insert('dreams', d.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      for (final s in d.symbols) {
        await _db!.insert('dream_signs', {'dream_id': d.id, 'name': s, 'category': 'symbol'});
      }
      for (final p in d.people) {
        await _db!.insert('dream_signs', {'dream_id': d.id, 'name': p, 'category': 'person'});
      }
      for (final e in d.emotionsDuring) {
        await _db!.insert('dream_emotions', {'dream_id': d.id, 'emotion': e, 'phase': 'during'});
      }
      for (final e in d.emotionsUponWaking) {
        await _db!.insert('dream_emotions', {'dream_id': d.id, 'emotion': e, 'phase': 'waking'});
      }
    }

    return _db!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScreenshotDatabase screenshotDb;
  late DreamDao dao;
  late DreamProvider dreamProvider;
  late GraphProvider graphProvider;

  setUp(() async {
    screenshotDb = ScreenshotDatabase();
    await screenshotDb.database;
    dao = DreamDao(dbProvider: screenshotDb);
    dreamProvider = DreamProvider(dao: dao);
    graphProvider = GraphProvider(dao: dao);
    await dreamProvider.refresh();
    await graphProvider.loadGraph();
  });

  GlobalKey boundaryKey = GlobalKey();

  Widget buildTestScreen(Widget child) {
    boundaryKey = GlobalKey();
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
          body: RepaintBoundary(key: boundaryKey, child: child),
        ),
      ),
    );
  }

  Future<void> captureScreen(WidgetTester tester, String filename) async {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() async {
      final RenderRepaintBoundary? boundary =
          boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final File file = File('screenshots/$filename.png');
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(byteData.buffer.asUint8List());
          // ignore: avoid_print
          print('📸 Saved screenshot: screenshots/$filename.png (${byteData.lengthInBytes} bytes)');
        }
      }
    });
  }

  testWidgets('Capture high-res screenshots of all Cosmic Dream Journal screens', (tester) async {
    tester.view.physicalSize = const Size(828, 1792);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. NEW ENTRY (PART 1: DETAILS)
    final demoDreams = DemoDataService.getDemoDreams();
    final sampleDream = demoDreams.firstWhere((d) => d.isLucid);

    await tester.pumpWidget(buildTestScreen(NewEntryScreen(existingDream: sampleDream)));
    await tester.pump(const Duration(milliseconds: 300));
    await captureScreen(tester, '01_new_entry_details');

    // 2. NEW ENTRY (PART 2: REFLECTION & SKETCH)
    await tester.tap(find.text('2. Reflection & Sketch'));
    await tester.pump(const Duration(milliseconds: 350));
    await captureScreen(tester, '02_new_entry_reflection');

    // 3. DREAM CHRONICLE (FEED)
    await tester.pumpWidget(buildTestScreen(const DreamListScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await captureScreen(tester, '03_dream_chronicle_feed');

    // 4. DREAM DETAIL SCREEN
    await tester.pumpWidget(buildTestScreen(DreamDetailScreen(dream: sampleDream)));
    await tester.pump(const Duration(milliseconds: 300));
    await captureScreen(tester, '04_dream_detail_view');

    // 5. DREAM CALENDAR SCREEN
    await tester.pumpWidget(buildTestScreen(const DreamCalendarScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await captureScreen(tester, '05_dream_calendar');

    // 6. COSMIC CONSTELLATION GRAPH SCREEN
    await tester.pumpWidget(buildTestScreen(const CosmicGraphScreen()));
    await tester.pump(const Duration(milliseconds: 400));
    await captureScreen(tester, '06_cosmic_constellation_graph');

    // 7. NODE DETAIL MODAL SHEET (Tapped "Flying" node)
    final flyingNode = graphProvider.visibleNodes.firstWhere(
      (n) => n.name == 'Flying',
      orElse: () => graphProvider.visibleNodes.first,
    );
    final connectedDreams = await dao.getDreams(tagFilter: flyingNode.name);

    await tester.pumpWidget(
      buildTestScreen(
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
    await tester.pump(const Duration(milliseconds: 300));
    await captureScreen(tester, '07_node_detail_sheet');

    // 8. BEDTIME AFFIRMATIONS SCREEN
    await tester.pumpWidget(buildTestScreen(const BedtimeAffirmationScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await captureScreen(tester, '08_bedtime_affirmations');

    // 9. MAIN SHELL WITH DEMO MODE BANNER
    await dreamProvider.setDemoMode(true);
    await graphProvider.setDemoMode(true);

    await tester.pumpWidget(buildTestScreen(const MainNavigationShell()));
    await tester.pump(const Duration(milliseconds: 300));
    await captureScreen(tester, '09_demo_mode_shell');
  });
}
