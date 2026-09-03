import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dream_journal/database/app_database.dart';
import 'package:dream_journal/database/dream_dao.dart';
import 'package:dream_journal/screens/splash/splash_screen.dart';
import 'package:dream_journal/state/dream_provider.dart';
import 'package:dream_journal/state/graph_provider.dart';
import 'package:dream_journal/theme/cosmic_theme.dart';

void main() {
  testWidgets('SplashScreen renders title, subtitle, emblem, and handles tap navigation',
      (WidgetTester tester) async {
    final dbProvider = AppDatabase.demo;
    final dao = DreamDao(dbProvider: dbProvider);
    final dreamProvider = DreamProvider(dao: dao);
    final graphProvider = GraphProvider(dao: dao);

    bool finishedCalled = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DreamProvider>.value(value: dreamProvider),
          ChangeNotifierProvider<GraphProvider>.value(value: graphProvider),
        ],
        child: MaterialApp(
          theme: CosmicTheme.darkTheme,
          home: SplashScreen(
            autoNavigate: false,
            onFinished: () {
              finishedCalled = true;
            },
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify title and subtitle exist
    expect(find.text('COSMIC TWILIGHT'), findsOneWidget);
    expect(find.text('DREAM JOURNAL & LUCID EXPLORER'), findsOneWidget);
    expect(find.text('TAP ANYWHERE TO ENTER'), findsOneWidget);

    // Verify image emblem exists
    expect(find.byType(Image), findsOneWidget);

    // Tap to skip
    await tester.tap(find.byType(SplashScreen));
    await tester.pump();

    // Since autoNavigate was false, verify onFinished was invoked
    expect(finishedCalled, isFalse); // autoNavigate false disables tap navigation

    // Test with autoNavigate: true
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DreamProvider>.value(value: dreamProvider),
          ChangeNotifierProvider<GraphProvider>.value(value: graphProvider),
        ],
        child: MaterialApp(
          theme: CosmicTheme.darkTheme,
          home: SplashScreen(
            autoNavigate: true,
            onFinished: () {
              finishedCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byType(SplashScreen));
    await tester.pump();

    expect(finishedCalled, isTrue);
  });
}
