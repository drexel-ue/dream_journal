import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../services/demo_data_service.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init('dream_journal.db');
  static final AppDatabase demo = AppDatabase._init('dream_journal_demo.db', isDemo: true);

  final String dbName;
  final bool isDemo;
  Database? _database;

  AppDatabase._init(this.dbName, {this.isDemo = false});
  AppDatabase({this.dbName = 'dream_journal.db', this.isDemo = false});

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      path = join(docDir.path, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createDB(db, version);
        if (isDemo) {
          await _seedDemoData(db);
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dreams (
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
      CREATE TABLE dream_emotions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dream_id TEXT NOT NULL,
        emotion TEXT NOT NULL,
        phase TEXT NOT NULL,
        FOREIGN KEY (dream_id) REFERENCES dreams (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE dream_signs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dream_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        FOREIGN KEY (dream_id) REFERENCES dreams (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_dreams_date ON dreams(date)');
    await db.execute('CREATE INDEX idx_dreams_lucid ON dreams(is_lucid)');
    await db.execute('CREATE INDEX idx_signs_dream ON dream_signs(dream_id)');
    await db.execute('CREATE INDEX idx_signs_name ON dream_signs(name)');
    await db.execute('CREATE INDEX idx_emotions_dream ON dream_emotions(dream_id)');
  }

  Future<void> _seedDemoData(Database db) async {
    final demoDreams = DemoDataService.getDemoDreams();
    for (final dream in demoDreams) {
      await db.insert('dreams', dream.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

      for (final emotion in dream.emotionsDuring) {
        await db.insert('dream_emotions', {
          'dream_id': dream.id,
          'emotion': emotion,
          'phase': 'during',
        });
      }
      for (final emotion in dream.emotionsUponWaking) {
        await db.insert('dream_emotions', {
          'dream_id': dream.id,
          'emotion': emotion,
          'phase': 'waking',
        });
      }
      for (final person in dream.people) {
        await db.insert('dream_signs', {
          'dream_id': dream.id,
          'name': person,
          'category': 'person',
        });
      }
      for (final symbol in dream.symbols) {
        await db.insert('dream_signs', {
          'dream_id': dream.id,
          'name': symbol,
          'category': 'symbol',
        });
      }
    }
  }

  Future<void> resetDemoDatabase() async {
    if (!isDemo) return;
    final db = await database;
    await db.delete('dreams');
    await db.delete('dream_emotions');
    await db.delete('dream_signs');
    await _seedDemoData(db);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
