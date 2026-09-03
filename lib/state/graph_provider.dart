import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/dream_dao.dart';
import '../models/graph_node.dart';
import '../models/dream_entry.dart';

class GraphProvider extends ChangeNotifier {
  DreamDao _dao;

  List<GraphNode> _allNodes = [];
  List<GraphEdge> _allEdges = [];

  List<GraphNode> _visibleNodes = [];
  List<GraphEdge> _visibleEdges = [];

  DateTime? _minDate;
  DateTime? _maxDate;
  double _timelineProgress = 1.0;
  bool _isPlaying = false;
  Timer? _playTimer;

  GraphNode? _selectedNode;
  List<DreamEntry> _selectedNodeDreams = [];
  bool _isLoadingSheet = false;

  bool _isLoading = false;
  Timer? _physicsTimer;

  GraphProvider({DreamDao? dao}) : _dao = dao ?? DreamDao() {
    loadGraph();
  }

  Future<void> setDemoMode(bool isDemo) async {
    if (isDemo) {
      _dao = DreamDao(dbProvider: AppDatabase.demo);
    } else {
      _dao = DreamDao(dbProvider: AppDatabase.instance);
    }
    _timelineProgress = 1.0;
    await loadGraph();
  }

  List<GraphNode> get visibleNodes => _visibleNodes;
  List<GraphEdge> get visibleEdges => _visibleEdges;
  double get timelineProgress => _timelineProgress;
  bool get isPlaying => _isPlaying;
  DateTime? get minDate => _minDate;
  DateTime? get maxDate => _maxDate;
  DateTime? get activeCutoffDate => _computeActiveDate();
  GraphNode? get selectedNode => _selectedNode;
  List<DreamEntry> get selectedNodeDreams => _selectedNodeDreams;
  bool get isLoadingSheet => _isLoadingSheet;
  bool get isLoading => _isLoading;
  bool get hasData => _allNodes.isNotEmpty;

  Future<void> loadGraph() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allNodes = await _dao.getGraphNodes();
      _allEdges = await _dao.getGraphEdges();

      final dateRange = await _dao.getDateRange();
      _minDate = dateRange['min'];
      _maxDate = dateRange['max'];

      _initializePositions();
      _filterByTimeline();
      _startPhysics();
    } catch (e) {
      debugPrint('Error loading graph: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializePositions() {
    final random = Random(42);
    const radius = 180.0;
    final count = _allNodes.length;

    for (int i = 0; i < count; i++) {
      final node = _allNodes[i];
      if (node.x == 0 && node.y == 0) {
        final angle = (2 * pi * i) / (count > 0 ? count : 1);
        final r = radius + (random.nextDouble() * 60 - 30);
        node.x = cos(angle) * r;
        node.y = sin(angle) * r;
      }
    }
  }

  DateTime? _computeActiveDate() {
    if (_minDate == null || _maxDate == null) return null;
    if (_minDate == _maxDate) return _maxDate;

    final totalMs = _maxDate!.difference(_minDate!).inMilliseconds;
    final currentMs = (totalMs * _timelineProgress).round();
    return _minDate!.add(Duration(milliseconds: currentMs));
  }

  void _filterByTimeline() {
    final cutoff = _computeActiveDate();
    if (cutoff == null) {
      _visibleNodes = List.from(_allNodes);
      _visibleEdges = List.from(_allEdges);
      return;
    }

    _visibleNodes = _allNodes.where((n) {
      return n.firstSeen.isBefore(cutoff) || n.firstSeen.isAtSameMomentAs(cutoff);
    }).toList();

    final visibleIds = _visibleNodes.map((n) => n.id).toSet();

    _visibleEdges = _allEdges.where((e) {
      final inTime = e.firstCoOccurrence.isBefore(cutoff) || e.firstCoOccurrence.isAtSameMomentAs(cutoff);
      return inTime && visibleIds.contains(e.sourceId) && visibleIds.contains(e.targetId);
    }).toList();
  }

  void setScrubberProgress(double progress) {
    _timelineProgress = progress.clamp(0.0, 1.0);
    _filterByTimeline();
    notifyListeners();
  }

  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    _isPlaying = true;
    if (_timelineProgress >= 1.0) {
      _timelineProgress = 0.0;
    }
    _playTimer?.cancel();
    _playTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _timelineProgress += 0.007;
      if (_timelineProgress >= 1.0) {
        _timelineProgress = 1.0;
        pause();
      }
      _filterByTimeline();
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _playTimer?.cancel();
    _playTimer = null;
    notifyListeners();
  }

  void _startPhysics() {
    _physicsTimer?.cancel();
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 24), (_) {
      _stepPhysics();
    });
  }

  void _stepPhysics() {
    if (_visibleNodes.length < 2) return;

    const repulsionK = 6500.0;
    const springK = 0.045;
    const restLength = 120.0;
    const centerGravity = 0.012;
    const damping = 0.86;

    final nodeMap = {for (final n in _visibleNodes) n.id: n};

    // 1. Repulsion between all pairs
    for (int i = 0; i < _visibleNodes.length; i++) {
      final n1 = _visibleNodes[i];
      for (int j = i + 1; j < _visibleNodes.length; j++) {
        final n2 = _visibleNodes[j];
        final dx = n2.x - n1.x;
        final dy = n2.y - n1.y;
        double dist = sqrt(dx * dx + dy * dy);
        if (dist < 1.0) dist = 1.0;

        final force = repulsionK / (dist * dist);
        final fx = (dx / dist) * force;
        final fy = (dy / dist) * force;

        if (!n1.isPinned) {
          n1.vx -= fx;
          n1.vy -= fy;
        }
        if (!n2.isPinned) {
          n2.vx += fx;
          n2.vy += fy;
        }
      }
    }

    // 2. Spring attraction along edges
    for (final edge in _visibleEdges) {
      final n1 = nodeMap[edge.sourceId];
      final n2 = nodeMap[edge.targetId];
      if (n1 == null || n2 == null) continue;

      final dx = n2.x - n1.x;
      final dy = n2.y - n1.y;
      double dist = sqrt(dx * dx + dy * dy);
      if (dist < 1.0) dist = 1.0;

      final displacement = dist - restLength;
      final force = springK * displacement * (1 + (edge.weight * 0.3));
      final fx = (dx / dist) * force;
      final fy = (dy / dist) * force;

      if (!n1.isPinned) {
        n1.vx += fx;
        n1.vy += fy;
      }
      if (!n2.isPinned) {
        n2.vx -= fx;
        n2.vy -= fy;
      }
    }

    // 3. Center gravity and update position
    for (final n in _visibleNodes) {
      if (n.isPinned) continue;

      n.vx -= n.x * centerGravity;
      n.vy -= n.y * centerGravity;

      n.vx *= damping;
      n.vy *= damping;

      n.x += n.vx;
      n.y += n.vy;
    }

    notifyListeners();
  }

  void dragNode(GraphNode node, Offset localDelta) {
    node.isPinned = true;
    node.x += localDelta.dx;
    node.y += localDelta.dy;
    node.vx = 0;
    node.vy = 0;
    notifyListeners();
  }

  void releaseNode(GraphNode node) {
    node.isPinned = false;
    notifyListeners();
  }

  Future<void> selectNode(GraphNode? node) async {
    _selectedNode = node;
    _selectedNodeDreams = [];
    notifyListeners();

    if (node != null) {
      _isLoadingSheet = true;
      notifyListeners();
      try {
        _selectedNodeDreams = await _dao.getDreams(tagFilter: node.name);
      } finally {
        _isLoadingSheet = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _playTimer?.cancel();
    _physicsTimer?.cancel();
    super.dispose();
  }
}
