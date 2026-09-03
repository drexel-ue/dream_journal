import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'database/app_database.dart';
import 'screens/splash/splash_screen.dart';
import 'state/dream_provider.dart';
import 'state/graph_provider.dart';
import 'theme/cosmic_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CosmicColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize SQLite database instance
  try {
    await AppDatabase.instance.database;
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  runApp(const DreamJournalApp());
}

class DreamJournalApp extends StatelessWidget {
  const DreamJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DreamProvider()),
        ChangeNotifierProvider(create: (_) => GraphProvider()),
      ],
      child: MaterialApp(
        title: 'Cosmic Dream Journal',
        debugShowCheckedModeBanner: false,
        theme: CosmicTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
