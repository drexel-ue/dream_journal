import 'package:sqflite/sqflite.dart';
import '../models/dream_entry.dart';
import '../models/graph_node.dart';
import 'app_database.dart';

class DreamDao {
  final AppDatabase dbProvider;

  DreamDao({AppDatabase? dbProvider})
      : dbProvider = dbProvider ?? AppDatabase.instance;

  Future<void> insertDream(DreamEntry dream) async {
    final db = await dbProvider.database;
    await db.transaction((txn) async {
      await txn.insert(
        'dreams',
        dream.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert emotions during dream
      for (final emotion in dream.emotionsDuring) {
        if (emotion.trim().isNotEmpty) {
          await txn.insert('dream_emotions', {
            'dream_id': dream.id,
            'emotion': emotion.trim(),
            'phase': 'during',
          });
        }
      }

      // Insert emotions upon waking
      for (final emotion in dream.emotionsUponWaking) {
        if (emotion.trim().isNotEmpty) {
          await txn.insert('dream_emotions', {
            'dream_id': dream.id,
            'emotion': emotion.trim(),
            'phase': 'waking',
          });
        }
      }

      // Insert people
      for (final person in dream.people) {
        if (person.trim().isNotEmpty) {
          await txn.insert('dream_signs', {
            'dream_id': dream.id,
            'name': person.trim(),
            'category': 'person',
          });
        }
      }

      // Insert symbols
      for (final symbol in dream.symbols) {
        if (symbol.trim().isNotEmpty) {
          await txn.insert('dream_signs', {
            'dream_id': dream.id,
            'name': symbol.trim(),
            'category': 'symbol',
          });
        }
      }
    });
  }

  Future<void> updateDream(DreamEntry dream) async {
    final db = await dbProvider.database;
    await db.transaction((txn) async {
      await txn.update(
        'dreams',
        dream.toMap(),
        where: 'id = ?',
        whereArgs: [dream.id],
      );

      // Clean old child rows
      await txn.delete('dream_emotions', where: 'dream_id = ?', whereArgs: [dream.id]);
      await txn.delete('dream_signs', where: 'dream_id = ?', whereArgs: [dream.id]);

      // Re-insert emotions
      for (final emotion in dream.emotionsDuring) {
        if (emotion.trim().isNotEmpty) {
          await txn.insert('dream_emotions', {
            'dream_id': dream.id,
            'emotion': emotion.trim(),
            'phase': 'during',
          });
        }
      }
      for (final emotion in dream.emotionsUponWaking) {
        if (emotion.trim().isNotEmpty) {
          await txn.insert('dream_emotions', {
            'dream_id': dream.id,
            'emotion': emotion.trim(),
            'phase': 'waking',
          });
        }
      }

      // Re-insert signs
      for (final person in dream.people) {
        if (person.trim().isNotEmpty) {
          await txn.insert('dream_signs', {
            'dream_id': dream.id,
            'name': person.trim(),
            'category': 'person',
          });
        }
      }
      for (final symbol in dream.symbols) {
        if (symbol.trim().isNotEmpty) {
          await txn.insert('dream_signs', {
            'dream_id': dream.id,
            'name': symbol.trim(),
            'category': 'symbol',
          });
        }
      }
    });
  }

  Future<void> deleteDream(String id) async {
    final db = await dbProvider.database;
    await db.delete('dreams', where: 'id = ?', whereArgs: [id]);
  }

  Future<DreamEntry?> getDreamById(String id) async {
    final db = await dbProvider.database;
    final results = await db.query('dreams', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;

    final emotionsRows = await db.query(
      'dream_emotions',
      where: 'dream_id = ?',
      whereArgs: [id],
    );
    final signsRows = await db.query(
      'dream_signs',
      where: 'dream_id = ?',
      whereArgs: [id],
    );

    final during = emotionsRows
        .where((r) => r['phase'] == 'during')
        .map((r) => r['emotion'] as String)
        .toList();
    final waking = emotionsRows
        .where((r) => r['phase'] == 'waking')
        .map((r) => r['emotion'] as String)
        .toList();
    final people = signsRows
        .where((r) => r['category'] == 'person')
        .map((r) => r['name'] as String)
        .toList();
    final symbols = signsRows
        .where((r) => r['category'] == 'symbol')
        .map((r) => r['name'] as String)
        .toList();

    return DreamEntry.fromMap(
      map: results.first,
      emotionsDuring: during,
      emotionsUponWaking: waking,
      people: people,
      symbols: symbols,
    );
  }

  Future<List<DreamEntry>> getDreams({
    String? search,
    bool? lucidOnly,
    DateTime? upToDate,
    String? tagFilter,
  }) async {
    final db = await dbProvider.database;

    String whereClause = '1=1';
    final List<dynamic> whereArgs = [];

    if (lucidOnly == true) {
      whereClause += ' AND d.is_lucid = 1';
    }

    if (upToDate != null) {
      whereClause += ' AND d.date <= ?';
      whereArgs.add(upToDate.toIso8601String());
    }

    if (search != null && search.trim().isNotEmpty) {
      final term = '%${search.trim()}%';
      whereClause += ''' AND (
        d.title LIKE ? OR 
        d.description LIKE ? OR 
        d.actions_events LIKE ? OR 
        d.meanings_associations LIKE ? OR 
        d.notes LIKE ? OR
        EXISTS (SELECT 1 FROM dream_signs s WHERE s.dream_id = d.id AND s.name LIKE ?)
      )''';
      whereArgs.addAll([term, term, term, term, term, term]);
    }

    if (tagFilter != null && tagFilter.trim().isNotEmpty) {
      whereClause += ' AND EXISTS (SELECT 1 FROM dream_signs s WHERE s.dream_id = d.id AND s.name = ?)';
      whereArgs.add(tagFilter.trim());
    }

    final query = '''
      SELECT d.* FROM dreams d
      WHERE $whereClause
      ORDER BY d.date DESC, d.created_at DESC
    ''';

    final dreamRows = await db.rawQuery(query, whereArgs);
    if (dreamRows.isEmpty) return [];

    final List<DreamEntry> entries = [];
    for (final row in dreamRows) {
      final dreamId = row['id'] as String;

      final emotionsRows = await db.query(
        'dream_emotions',
        where: 'dream_id = ?',
        whereArgs: [dreamId],
      );
      final signsRows = await db.query(
        'dream_signs',
        where: 'dream_id = ?',
        whereArgs: [dreamId],
      );

      final during = emotionsRows
          .where((r) => r['phase'] == 'during')
          .map((r) => r['emotion'] as String)
          .toList();
      final waking = emotionsRows
          .where((r) => r['phase'] == 'waking')
          .map((r) => r['emotion'] as String)
          .toList();
      final people = signsRows
          .where((r) => r['category'] == 'person')
          .map((r) => r['name'] as String)
          .toList();
      final symbols = signsRows
          .where((r) => r['category'] == 'symbol')
          .map((r) => r['name'] as String)
          .toList();

      entries.add(DreamEntry.fromMap(
        map: row,
        emotionsDuring: during,
        emotionsUponWaking: waking,
        people: people,
        symbols: symbols,
      ));
    }

    return entries;
  }

  Future<List<GraphNode>> getGraphNodes({DateTime? upToDate}) async {
    final db = await dbProvider.database;

    String dateFilter = '';
    final List<dynamic> args = [];
    if (upToDate != null) {
      dateFilter = 'AND d.date <= ?';
      args.add(upToDate.toIso8601String());
    }

    final query = '''
      SELECT 
        s.name, 
        s.category, 
        COUNT(DISTINCT d.id) as count, 
        SUM(d.is_lucid) as lucid_count,
        MIN(d.date) as first_seen,
        MAX(d.date) as last_seen,
        GROUP_CONCAT(DISTINCT d.id) as dream_ids
      FROM dream_signs s
      JOIN dreams d ON s.dream_id = d.id
      WHERE d.is_no_recall = 0 $dateFilter
      GROUP BY s.name, s.category
      ORDER BY count DESC
    ''';

    final rows = await db.rawQuery(query, args);

    return rows.map((r) {
      final name = r['name'] as String;
      final category = r['category'] as String;
      final count = (r['count'] as num).toInt();
      final lucidCount = (r['lucid_count'] as num?)?.toInt() ?? 0;
      final firstSeen = DateTime.parse(r['first_seen'] as String);
      final lastSeen = DateTime.parse(r['last_seen'] as String);
      final dreamIdsStr = (r['dream_ids'] as String?) ?? '';
      final dreamIds = dreamIdsStr.split(',').where((s) => s.isNotEmpty).toList();

      return GraphNode(
        id: name,
        name: name,
        category: category,
        count: count,
        lucidCount: lucidCount,
        firstSeen: firstSeen,
        lastSeen: lastSeen,
        dreamIds: dreamIds,
      );
    }).toList();
  }

  Future<List<GraphEdge>> getGraphEdges({DateTime? upToDate}) async {
    final db = await dbProvider.database;

    String dateFilter = '';
    final List<dynamic> args = [];
    if (upToDate != null) {
      dateFilter = 'AND d.date <= ?';
      args.add(upToDate.toIso8601String());
    }

    final query = '''
      SELECT 
        s1.name AS source_id, 
        s2.name AS target_id, 
        COUNT(DISTINCT d.id) AS weight,
        MIN(d.date) AS first_co_occurrence
      FROM dream_signs s1
      JOIN dream_signs s2 ON s1.dream_id = s2.dream_id AND s1.name < s2.name
      JOIN dreams d ON s1.dream_id = d.id
      WHERE d.is_no_recall = 0 $dateFilter
      GROUP BY s1.name, s2.name
      ORDER BY weight DESC
    ''';

    final rows = await db.rawQuery(query, args);

    return rows.map((r) {
      return GraphEdge(
        sourceId: r['source_id'] as String,
        targetId: r['target_id'] as String,
        weight: (r['weight'] as num).toInt(),
        firstCoOccurrence: DateTime.parse(r['first_co_occurrence'] as String),
      );
    }).toList();
  }

  Future<Map<String, DateTime?>> getDateRange() async {
    final db = await dbProvider.database;
    final res = await db.rawQuery('''
      SELECT MIN(date) as min_date, MAX(date) as max_date FROM dreams
    ''');
    if (res.isEmpty || res.first['min_date'] == null) {
      return {'min': null, 'max': null};
    }
    return {
      'min': DateTime.parse(res.first['min_date'] as String),
      'max': DateTime.parse(res.first['max_date'] as String),
    };
  }

  Future<int> getStreak() async {
    final db = await dbProvider.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT substr(date, 1, 10) as day FROM dreams ORDER BY day DESC
    ''');
    if (rows.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);

    final recordedDays = rows.map((r) => r['day'] as String).toSet();

    final todayStr = _formatDay(checkDate);
    final yesterdayStr = _formatDay(checkDate.subtract(const Duration(days: 1)));

    // Check if recorded today or at least yesterday
    if (!recordedDays.contains(todayStr) && !recordedDays.contains(yesterdayStr)) {
      return 0;
    }

    if (!recordedDays.contains(todayStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (recordedDays.contains(_formatDay(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  String _formatDay(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
