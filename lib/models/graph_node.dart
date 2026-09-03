import 'package:flutter/material.dart';

class GraphNode {
  final String id;
  final String name;
  final String category; // 'symbol', 'person', 'place', 'theme'
  final int count;
  final int lucidCount;
  final DateTime firstSeen;
  final DateTime lastSeen;
  final List<String> dreamIds;

  double x;
  double y;
  double vx;
  double vy;
  bool isPinned;

  GraphNode({
    required this.id,
    required this.name,
    required this.category,
    required this.count,
    required this.lucidCount,
    required this.firstSeen,
    required this.lastSeen,
    this.dreamIds = const [],
    this.x = 0,
    this.y = 0,
    this.vx = 0,
    this.vy = 0,
    this.isPinned = false,
  });

  double get lucidityRate => count > 0 ? lucidCount / count : 0.0;

  double get radius => (16.0 + (count * 3.5)).clamp(16.0, 48.0);

  Color get categoryColor {
    switch (category.toLowerCase()) {
      case 'person':
        return const Color(0xFFEC4899); // Pink / Rose
      case 'place':
        return const Color(0xFF10B981); // Emerald / Aurora Green
      case 'theme':
        return const Color(0xFFF59E0B); // Amber / Starlight Gold
      case 'symbol':
      default:
        return const Color(0xFF06B6D4); // Cyan / Celestial Blue
    }
  }

  Color get glowColor {
    if (lucidityRate > 0.4) {
      return const Color(0xFFA855F7); // High Lucidity Purple Glow
    }
    return categoryColor;
  }
}

class GraphEdge {
  final String sourceId;
  final String targetId;
  final int weight;
  final DateTime firstCoOccurrence;

  GraphEdge({
    required this.sourceId,
    required this.targetId,
    required this.weight,
    required this.firstCoOccurrence,
  });

  double get strokeWidth => (1.0 + (weight * 0.8)).clamp(1.0, 6.0);
}
