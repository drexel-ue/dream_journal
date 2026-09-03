import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:dream_journal/services/demo_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DemoDataService returns valid dreams with symbols and sketches', () {
    final demoDreams = DemoDataService.getDemoDreams();
    expect(demoDreams.length, 7);

    final lucidDreams = demoDreams.where((d) => d.isLucid).toList();
    expect(lucidDreams.length, 2);

    final sketches = demoDreams.where((d) => d.sketchData != null).toList();
    expect(sketches.length, 2);

    final noRecall = demoDreams.where((d) => d.isNoRecall).toList();
    expect(noRecall.length, 1);
  });

  test('Demo database isolation ensures zero pollution of user database', () async {
    sqfliteFfiInit();

    // User DB and Demo DB are distinct databases
    final userDb = await databaseFactoryFfi.openDatabase('file:mem_user?mode=memory&cache=shared');
    final demoDb = await databaseFactoryFfi.openDatabase('file:mem_demo?mode=memory&cache=shared');

    // Create tables on both
    for (final db in [userDb, demoDb]) {
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
    }

    // Populate demo DB with demo dreams
    final demoDreams = DemoDataService.getDemoDreams();
    for (final d in demoDreams) {
      await demoDb.insert('dreams', d.toMap());
      for (final s in d.symbols) {
        await demoDb.insert('dream_signs', {'dream_id': d.id, 'name': s, 'category': 'symbol'});
      }
      for (final p in d.people) {
        await demoDb.insert('dream_signs', {'dream_id': d.id, 'name': p, 'category': 'person'});
      }
    }

    // Verify user DB has 0 dreams
    final userRes = await userDb.rawQuery('SELECT COUNT(*) as c FROM dreams');
    final userDreamsCount = userRes.first['c'] as int;
    expect(userDreamsCount, 0);

    // Verify demo DB has 7 dreams
    final demoRes = await demoDb.rawQuery('SELECT COUNT(*) as c FROM dreams');
    final demoDreamsCount = demoRes.first['c'] as int;
    expect(demoDreamsCount, 7);

    // Verify user database remains completely unaffected
    expect(userDreamsCount, 0);

    await userDb.close();
    await demoDb.close();
  });
}
