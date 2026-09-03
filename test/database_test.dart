import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dream_journal/database/dream_dao.dart';
import 'package:dream_journal/database/app_database.dart';
import 'package:dream_journal/models/dream_entry.dart';

class MockAppDatabase extends AppDatabase {
  MockAppDatabase() : super();

  Database? _mockDb;

  @override
  Future<Database> get database async {
    if (_mockDb != null) return _mockDb!;
    sqfliteFfiInit();
    _mockDb = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
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
        },
      ),
    );
    return _mockDb!;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppDatabase mockDb;
  late DreamDao dao;

  setUp(() {
    mockDb = MockAppDatabase();
    dao = DreamDao(dbProvider: mockDb);
  });

  test('SQLite relational insertion, search, and co-occurrence graph queries', () async {
    final now = DateTime.now();

    // Dream 1
    final dream1 = DreamEntry(
      id: 'd1',
      date: now.subtract(const Duration(days: 1)),
      title: 'Ocean flight with Alex',
      description: 'Soaring over deep blue water under stars',
      isLucid: true,
      people: ['Alex'],
      symbols: ['Ocean', 'Flying'],
      emotionsDuring: ['Peaceful'],
      emotionsUponWaking: ['Inspired'],
    );
    await dao.insertDream(dream1);

    // Dream 2
    final dream2 = DreamEntry(
      id: 'd2',
      date: now,
      title: 'Clock tower at the shore',
      description: 'Alex pointed at a tower in the ocean',
      isLucid: false,
      people: ['Alex'],
      symbols: ['Ocean', 'Clock Tower'],
      emotionsDuring: ['Confused'],
      emotionsUponWaking: ['Calm'],
    );
    await dao.insertDream(dream2);

    // Test search
    final searchResults = await dao.getDreams(search: 'tower');
    expect(searchResults.length, 1);
    expect(searchResults.first.id, 'd2');

    // Test getGraphNodes
    final nodes = await dao.getGraphNodes();
    expect(nodes.length, 4); // Ocean, Alex, Flying, Clock Tower

    final oceanNode = nodes.firstWhere((n) => n.name == 'Ocean');
    expect(oceanNode.count, 2);
    expect(oceanNode.lucidCount, 1);
    expect(oceanNode.lucidityRate, 0.5);

    final flyingNode = nodes.firstWhere((n) => n.name == 'Flying');
    expect(flyingNode.count, 1);
    expect(flyingNode.lucidCount, 1);
    expect(flyingNode.lucidityRate, 1.0);

    // Test getGraphEdges (co-occurrences)
    final edges = await dao.getGraphEdges();
    expect(edges.isNotEmpty, true);

    // Alex and Ocean appear together in both d1 and d2!
    final alexOceanEdge = edges.firstWhere(
      (e) => (e.sourceId == 'Alex' && e.targetId == 'Ocean') || (e.sourceId == 'Ocean' && e.targetId == 'Alex'),
    );
    expect(alexOceanEdge.weight, 2);

    // Test getDreamsForTag
    final oceanDreams = await dao.getDreams(tagFilter: 'Ocean');
    expect(oceanDreams.length, 2);

    final streak = await dao.getStreak();
    expect(streak, greaterThanOrEqualTo(1));
  });
}
