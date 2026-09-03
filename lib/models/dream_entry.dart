class DreamEntry {
  final String id;
  final DateTime date;
  final String title;
  final String description;
  final bool isNoRecall;
  final List<String> emotionsDuring;
  final List<String> people;
  final List<String> symbols;
  final String actionsEvents;
  final String meaningsAssociations;
  final List<String> emotionsUponWaking;
  final bool isLucid;
  final String recallContext;
  final String notes;
  final String? sketchData;
  final DateTime createdAt;

  DreamEntry({
    required this.id,
    required this.date,
    required this.title,
    this.description = '',
    this.isNoRecall = false,
    this.emotionsDuring = const [],
    this.people = const [],
    this.symbols = const [],
    this.actionsEvents = '',
    this.meaningsAssociations = '',
    this.emotionsUponWaking = const [],
    this.isLucid = false,
    this.recallContext = '',
    this.notes = '',
    this.sketchData,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'is_no_recall': isNoRecall ? 1 : 0,
      'actions_events': actionsEvents,
      'meanings_associations': meaningsAssociations,
      'is_lucid': isLucid ? 1 : 0,
      'recall_context': recallContext,
      'notes': notes,
      'sketch_data': sketchData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DreamEntry.fromMap({
    required Map<String, dynamic> map,
    List<String> emotionsDuring = const [],
    List<String> emotionsUponWaking = const [],
    List<String> people = const [],
    List<String> symbols = const [],
  }) {
    return DreamEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      isNoRecall: ((map['is_no_recall'] as int?) ?? 0) == 1,
      actionsEvents: (map['actions_events'] as String?) ?? '',
      meaningsAssociations: (map['meanings_associations'] as String?) ?? '',
      isLucid: ((map['is_lucid'] as int?) ?? 0) == 1,
      recallContext: (map['recall_context'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      sketchData: map['sketch_data'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      emotionsDuring: emotionsDuring,
      emotionsUponWaking: emotionsUponWaking,
      people: people,
      symbols: symbols,
    );
  }

  DreamEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    bool? isNoRecall,
    List<String>? emotionsDuring,
    List<String>? people,
    List<String>? symbols,
    String? actionsEvents,
    String? meaningsAssociations,
    List<String>? emotionsUponWaking,
    bool? isLucid,
    String? recallContext,
    String? notes,
    String? sketchData,
    DateTime? createdAt,
  }) {
    return DreamEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      isNoRecall: isNoRecall ?? this.isNoRecall,
      emotionsDuring: emotionsDuring ?? this.emotionsDuring,
      people: people ?? this.people,
      symbols: symbols ?? this.symbols,
      actionsEvents: actionsEvents ?? this.actionsEvents,
      meaningsAssociations: meaningsAssociations ?? this.meaningsAssociations,
      emotionsUponWaking: emotionsUponWaking ?? this.emotionsUponWaking,
      isLucid: isLucid ?? this.isLucid,
      recallContext: recallContext ?? this.recallContext,
      notes: notes ?? this.notes,
      sketchData: sketchData ?? this.sketchData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
