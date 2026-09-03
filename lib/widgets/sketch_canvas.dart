import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawnLine({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  Map<String, dynamic> toMap() {
    return {
      'points': points.map((p) => [p.dx, p.dy]).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
    };
  }

  factory DrawnLine.fromMap(Map<String, dynamic> map) {
    final rawPoints = (map['points'] as List<dynamic>?) ?? [];
    final points = rawPoints.map((pt) {
      final list = pt as List<dynamic>;
      return Offset((list[0] as num).toDouble(), (list[1] as num).toDouble());
    }).toList();

    return DrawnLine(
      points: points,
      color: Color((map['color'] as num?)?.toInt() ?? 0xFFFFFFFF),
      strokeWidth: ((map['strokeWidth'] as num?)?.toDouble()) ?? 2.5,
    );
  }

  static String serializeList(List<DrawnLine> lines) {
    return jsonEncode(lines.map((l) => l.toMap()).toList());
  }

  static List<DrawnLine> deserializeList(String jsonStr) {
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((m) => DrawnLine.fromMap(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

class SketchCanvas extends StatefulWidget {
  final String? initialData;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final double height;

  const SketchCanvas({
    super.key,
    this.initialData,
    this.onChanged,
    this.readOnly = false,
    this.height = 240,
  });

  @override
  State<SketchCanvas> createState() => _SketchCanvasState();
}

class _SketchCanvasState extends State<SketchCanvas> {
  List<DrawnLine> _lines = [];
  DrawnLine? _currentLine;

  Color _selectedColor = CosmicColors.starlightGold;
  double _selectedStrokeWidth = 2.5;

  final List<Color> _palette = const [
    CosmicColors.starlightGold,
    CosmicColors.celestialCyan,
    CosmicColors.lucidPurple,
    CosmicColors.auraPink,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _lines = DrawnLine.deserializeList(widget.initialData!);
    }
  }

  @override
  void didUpdateWidget(covariant SketchCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData && widget.initialData != null) {
      _lines = DrawnLine.deserializeList(widget.initialData!);
    }
  }

  void _notifyChange() {
    if (widget.onChanged != null) {
      final serialized = DrawnLine.serializeList(_lines);
      widget.onChanged!(serialized);
    }
  }

  void _undo() {
    if (_lines.isNotEmpty) {
      setState(() {
        _lines.removeLast();
      });
      _notifyChange();
    }
  }

  void _clear() {
    if (_lines.isNotEmpty) {
      setState(() {
        _lines.clear();
      });
      _notifyChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.readOnly) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: CosmicColors.cardSurface.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: CosmicColors.borderSubtle),
            ),
            child: Row(
              children: [
                // Color circles
                Row(
                  children: _palette.map((c) {
                    final isSelected = _selectedColor.value == c.value;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: c.withOpacity(0.6),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                // Stroke size selector
                PopupMenuButton<double>(
                  tooltip: 'Stroke Size',
                  icon: const Icon(Icons.line_weight, size: 18, color: CosmicColors.textSecondary),
                  onSelected: (size) => setState(() => _selectedStrokeWidth = size),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 1.5, child: Text('Fine (1.5pt)')),
                    const PopupMenuItem(value: 2.5, child: Text('Medium (2.5pt)')),
                    const PopupMenuItem(value: 5.0, child: Text('Bold (5.0pt)')),
                  ],
                ),
                // Undo
                IconButton(
                  tooltip: 'Undo',
                  icon: const Icon(Icons.undo, size: 18, color: CosmicColors.textSecondary),
                  onPressed: _lines.isNotEmpty ? _undo : null,
                ),
                // Clear
                IconButton(
                  tooltip: 'Clear Canvas',
                  icon: const Icon(Icons.delete_outline, size: 18, color: CosmicColors.cosmicRed),
                  onPressed: _lines.isNotEmpty ? _clear : null,
                ),
              ],
            ),
          ),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFF070814),
            borderRadius: widget.readOnly
                ? BorderRadius.circular(12)
                : const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border.all(color: CosmicColors.borderSubtle),
          ),
          child: ClipRRect(
            borderRadius: widget.readOnly
                ? BorderRadius.circular(12)
                : const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Stack(
              children: [
                // Subtle constellation grid watermark in the sketch canvas
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SketchBackgroundPainter(),
                  ),
                ),
                // Drawing layer
                Positioned.fill(
                  child: widget.readOnly
                      ? CustomPaint(
                          painter: _CanvasPainter(lines: _lines),
                        )
                      : GestureDetector(
                          onPanStart: (details) {
                            final box = context.findRenderObject() as RenderBox?;
                            if (box == null) return;
                            final local = box.globalToLocal(details.globalPosition);
                            // offset by controls height if any
                            final adjusted = Offset(local.dx, (local.dy - 40).clamp(0, widget.height));
                            setState(() {
                              _currentLine = DrawnLine(
                                points: [adjusted],
                                color: _selectedColor,
                                strokeWidth: _selectedStrokeWidth,
                              );
                            });
                          },
                          onPanUpdate: (details) {
                            final box = context.findRenderObject() as RenderBox?;
                            if (box == null || _currentLine == null) return;
                            final local = box.globalToLocal(details.globalPosition);
                            final adjusted = Offset(local.dx, (local.dy - 40).clamp(0, widget.height));
                            setState(() {
                              _currentLine!.points.add(adjusted);
                            });
                          },
                          onPanEnd: (details) {
                            if (_currentLine != null) {
                              setState(() {
                                _lines.add(_currentLine!);
                                _currentLine = null;
                              });
                              _notifyChange();
                            }
                          },
                          child: CustomPaint(
                            painter: _CanvasPainter(
                              lines: _lines,
                              currentLine: _currentLine,
                            ),
                          ),
                        ),
                ),
                if (_lines.isEmpty && !widget.readOnly)
                  Center(
                    child: Text(
                      'Draw symbols, maps, or figures from your dream here...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CosmicColors.textMuted.withOpacity(0.5),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  _CanvasPainter({required this.lines, this.currentLine});

  @override
  void paint(Canvas canvas, Size size) {
    for (final line in lines) {
      _drawLine(canvas, line);
    }
    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    if (line.points.isEmpty) return;

    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (line.points.length == 1) {
      canvas.drawCircle(line.points.first, line.strokeWidth / 2, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path();
    path.moveTo(line.points[0].dx, line.points[0].dy);

    for (int i = 1; i < line.points.length; i++) {
      path.lineTo(line.points[i].dx, line.points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}

class _SketchBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0x15FFFFFF);
    const spacing = 28.0;
    for (double x = 14; x < size.width; x += spacing) {
      for (double y = 14; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
