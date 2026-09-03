import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/graph_node.dart';
import '../../theme/cosmic_theme.dart';

class CosmicGraphCanvas extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Function(GraphNode, Offset) onDragNode;
  final Function(GraphNode) onReleaseNode;
  final Function(GraphNode) onSelectNode;
  final TransformationController transformationController;

  const CosmicGraphCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    required this.onDragNode,
    required this.onReleaseNode,
    required this.onSelectNode,
    required this.transformationController,
  });

  @override
  State<CosmicGraphCanvas> createState() => _CosmicGraphCanvasState();
}

class _CosmicGraphCanvasState extends State<CosmicGraphCanvas> {
  GraphNode? _draggedNode;
  Offset? _lastFocalPoint;

  static const double _worldSize = 2400.0;
  static const Offset _worldCenter = Offset(_worldSize / 2, _worldSize / 2);

  GraphNode? _findNodeAt(Offset localWorldPos) {
    // Check in reverse order so top-drawn nodes get hit first
    for (final node in widget.nodes.reversed) {
      final nodePos = _worldCenter + Offset(node.x, node.y);
      final dist = (localWorldPos - nodePos).distance;
      if (dist <= node.radius + 12) {
        return node;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InteractiveViewer(
          transformationController: widget.transformationController,
          boundaryMargin: const EdgeInsets.all(1200),
          minScale: 0.2,
          maxScale: 3.5,
          constrained: false,
          panEnabled: true,
          scaleEnabled: true,
          trackpadScrollCausesScale: true,
          child: SizedBox(
            width: _worldSize,
            height: _worldSize,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTapUp: (details) {
                final node = _findNodeAt(details.localPosition);
                if (node != null) {
                  widget.onSelectNode(node);
                }
              },
              onPanStart: (details) {
                final node = _findNodeAt(details.localPosition);
                if (node != null) {
                  _draggedNode = node;
                  _lastFocalPoint = details.localPosition;
                }
              },
              onPanUpdate: (details) {
                if (_draggedNode != null && _lastFocalPoint != null) {
                  final delta = details.localPosition - _lastFocalPoint!;
                  _lastFocalPoint = details.localPosition;
                  widget.onDragNode(_draggedNode!, delta);
                }
              },
              onPanEnd: (_) {
                if (_draggedNode != null) {
                  widget.onReleaseNode(_draggedNode!);
                  _draggedNode = null;
                  _lastFocalPoint = null;
                }
              },
              child: CustomPaint(
                size: const Size(_worldSize, _worldSize),
                painter: _CosmicPainter(
                  nodes: widget.nodes,
                  edges: widget.edges,
                  center: _worldCenter,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CosmicPainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final Offset center;

  @override
  bool? hitTest(Offset position) {
    for (final node in nodes) {
      final nodePos = center + Offset(node.x, node.y);
      if ((position - nodePos).distance <= node.radius + 14) {
        return true;
      }
    }
    return false;
  }

  // Cache static ambient background stars
  static final List<Offset> _ambientStars = _generateStars();

  static List<Offset> _generateStars() {
    final rand = Random(1337);
    final list = <Offset>[];
    for (int i = 0; i < 240; i++) {
      list.add(Offset(rand.nextDouble() * 2400.0, rand.nextDouble() * 2400.0));
    }
    return list;
  }

  _CosmicPainter({
    required this.nodes,
    required this.edges,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw ambient cosmic starfield
    final starPaint = Paint()..color = const Color(0x35FFFFFF);
    for (final star in _ambientStars) {
      canvas.drawCircle(star, 1.2, starPaint);
    }

    final nodeMap = {for (final n in nodes) n.id: n};

    // 2. Draw connecting constellation edges
    for (final edge in edges) {
      final n1 = nodeMap[edge.sourceId];
      final n2 = nodeMap[edge.targetId];
      if (n1 == null || n2 == null) continue;

      final p1 = center + Offset(n1.x, n1.y);
      final p2 = center + Offset(n2.x, n2.y);

      // Ethereal line
      final linePaint = Paint()
        ..color = CosmicColors.astralViolet.withOpacity(0.35 + (edge.weight * 0.1).clamp(0.0, 0.45))
        ..strokeWidth = edge.strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p1, p2, linePaint);

      // Subtle mid-point glow dot on edge
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      canvas.drawCircle(
        mid,
        1.5,
        Paint()..color = CosmicColors.celestialCyan.withOpacity(0.4),
      );
    }

    // 3. Draw nodes
    for (final node in nodes) {
      final pos = center + Offset(node.x, node.y);
      final r = node.radius;

      // Outer ethereal glow
      final glowPaint = Paint()
        ..color = node.glowColor.withOpacity(0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawCircle(pos, r + 8, glowPaint);

      // Inner sphere gradient
      final spherePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            node.categoryColor.withOpacity(0.9),
            CosmicColors.cardSurface,
          ],
          stops: const [0.3, 1.0],
        ).createShader(Rect.fromCircle(center: pos, radius: r));

      canvas.drawCircle(pos, r, spherePaint);

      // Border ring
      final borderPaint = Paint()
        ..color = node.categoryColor
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, r, borderPaint);

      // Lucidity indicator star if lucid
      if (node.lucidCount > 0) {
        final starPaint = Paint()..color = CosmicColors.starlightGold;
        canvas.drawCircle(Offset(pos.dx + r * 0.7, pos.dy - r * 0.7), 4.5, starPaint);
      }

      // Draw label below node
      final textSpan = TextSpan(
        text: node.name,
        style: TextStyle(
          color: Colors.white,
          fontSize: (11.0 + (node.count * 0.5)).clamp(11.0, 15.0),
          fontWeight: FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(pos.dx - (tp.width / 2), pos.dy + r + 5));
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicPainter oldDelegate) => true;
}
