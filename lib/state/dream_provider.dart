import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/dream_dao.dart';
import '../models/dream_entry.dart';

class DreamProvider extends ChangeNotifier {
  DreamDao _dao;
  final _uuid = const Uuid();

  bool _isDemoMode = false;
  List<DreamEntry> _dreams = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _lucidFilter = false;
  String? _tagFilter;
  int _streak = 0;
  DateTime _selectedDate = DateTime.now();

  DreamProvider({DreamDao? dao}) : _dao = dao ?? DreamDao() {
    refresh();
  }

  bool get isDemoMode => _isDemoMode;
  List<DreamEntry> get dreams => _dreams;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get lucidFilter => _lucidFilter;
  String? get tagFilter => _tagFilter;
  int get streak => _streak;
  DateTime get selectedDate => _selectedDate;

  List<DreamEntry> get dreamsForSelectedDate {
    return _dreams.where((d) {
      return d.date.year == _selectedDate.year &&
          d.date.month == _selectedDate.month &&
          d.date.day == _selectedDate.day;
    }).toList();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dreams = await _dao.getDreams(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        lucidOnly: _lucidFilter ? true : null,
        tagFilter: _tagFilter,
      );
      _streak = await _dao.getStreak();
    } catch (e) {
      debugPrint('Error loading dreams: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDemoMode(bool isDemo) async {
    if (_isDemoMode == isDemo) return;
    _isDemoMode = isDemo;
    if (isDemo) {
      final demoDb = AppDatabase.demo;
      await demoDb.resetDemoDatabase();
      _dao = DreamDao(dbProvider: demoDb);
    } else {
      _dao = DreamDao(dbProvider: AppDatabase.instance);
    }
    await refresh();
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      refresh();
    }
  }

  void toggleLucidFilter() {
    _lucidFilter = !_lucidFilter;
    refresh();
  }

  void setTagFilter(String? tag) {
    _tagFilter = tag;
    refresh();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<DreamEntry> logNoRecall() async {
    final now = DateTime.now();
    final entry = DreamEntry(
      id: _uuid.v4(),
      date: DateTime(now.year, now.month, now.day, now.hour, now.minute),
      title: 'No Recall',
      description: 'Awoke with no conscious dream memory. Logged to preserve awareness habit and consistency.',
      isNoRecall: true,
      actionsEvents: '',
      meaningsAssociations: '',
      emotionsUponWaking: ['Calm'],
      isLucid: false,
      recallContext: 'Upon waking immediately',
      notes: 'Habit maintained: dreams matter.',
    );

    await _dao.insertDream(entry);
    await refresh();
    return entry;
  }

  Future<void> saveDream(DreamEntry dream) async {
    final existing = await _dao.getDreamById(dream.id);
    if (existing == null) {
      await _dao.insertDream(dream);
    } else {
      await _dao.updateDream(dream);
    }
    await refresh();
  }

  Future<void> deleteDream(String id) async {
    await _dao.deleteDream(id);
    await refresh();
  }

  Future<List<DreamEntry>> getDreamsForTag(String tag) async {
    return await _dao.getDreams(tagFilter: tag);
  }
}
