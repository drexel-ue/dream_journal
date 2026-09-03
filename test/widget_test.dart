import 'package:flutter_test/flutter_test.dart';
import 'package:dream_journal/models/dream_entry.dart';
import 'package:dream_journal/models/graph_node.dart';
import 'package:dream_journal/widgets/sketch_canvas.dart';
import 'package:flutter/material.dart';

void main() {
  group('DreamJournal Models and Logic Tests', () {
    test('DreamEntry serialization and copyWith', () {
      final entry = DreamEntry(
        id: 'test-1',
        date: DateTime(2026, 9, 2, 8, 30),
        title: 'Lucid Flight over Ocean',
        description: 'I became aware I was dreaming and flew over glowing waves.',
        isLucid: true,
        emotionsDuring: ['Peaceful', 'Excited'],
        people: ['Alex'],
        symbols: ['Ocean', 'Flying'],
        actionsEvents: 'Looked at hands, gained awareness, flew',
        meaningsAssociations: 'Desire for freedom',
        emotionsUponWaking: ['Inspired', 'Calm'],
      );

      final map = entry.toMap();
      expect(map['id'], 'test-1');
      expect(map['is_lucid'], 1);
      expect(map['title'], 'Lucid Flight over Ocean');

      final reconstructed = DreamEntry.fromMap(
        map: map,
        emotionsDuring: ['Peaceful', 'Excited'],
        people: ['Alex'],
        symbols: ['Ocean', 'Flying'],
      );

      expect(reconstructed.id, entry.id);
      expect(reconstructed.isLucid, true);
      expect(reconstructed.emotionsDuring.length, 2);
      expect(reconstructed.symbols.contains('Flying'), true);
    });

    test('GraphNode lucidity rate and category styling', () {
      final node = GraphNode(
        id: 'Flying',
        name: 'Flying',
        category: 'symbol',
        count: 5,
        lucidCount: 4,
        firstSeen: DateTime(2026, 8, 20),
        lastSeen: DateTime(2026, 9, 2),
      );

      expect(node.lucidityRate, 0.8);
      expect(node.radius, greaterThan(20.0));
      expect(node.categoryColor, const Color(0xFF06B6D4)); // Cyan
    });

    test('SketchCanvas DrawnLine path serialization', () {
      final lines = [
        DrawnLine(
          points: [const Offset(10, 10), const Offset(20, 20), const Offset(30, 25)],
          color: const Color(0xFFF59E0B),
          strokeWidth: 2.5,
        ),
      ];

      final serialized = DrawnLine.serializeList(lines);
      expect(serialized.isNotEmpty, true);

      final deserialized = DrawnLine.deserializeList(serialized);
      expect(deserialized.length, 1);
      expect(deserialized.first.points.length, 3);
      expect(deserialized.first.strokeWidth, 2.5);
    });
  });
}
