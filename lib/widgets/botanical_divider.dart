import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';

class BotanicalDivider extends StatelessWidget {
  final Color? color;
  final double width;

  const BotanicalDivider({
    super.key,
    this.color,
    this.width = 180.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? CosmicColors.astralViolet.withOpacity(0.5);

    return Center(
      child: SizedBox(
        width: width,
        height: 24,
        child: CustomPaint(
          painter: _BotanicalPainter(effectiveColor),
        ),
      ),
    );
  }
}

class _BotanicalPainter extends CustomPainter {
  final Color color;

  _BotanicalPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final centerX = size.width / 2;

    // Center star / diamond
    final pathCenter = Path();
    pathCenter.moveTo(centerX, centerY - 4);
    pathCenter.lineTo(centerX + 3, centerY);
    pathCenter.lineTo(centerX, centerY + 4);
    pathCenter.lineTo(centerX - 3, centerY);
    pathCenter.close();
    canvas.drawPath(pathCenter, fillPaint);

    // Left line
    canvas.drawLine(
      Offset(centerX - 8, centerY),
      Offset(20, centerY),
      paint,
    );

    // Right line
    canvas.drawLine(
      Offset(centerX + 8, centerY),
      Offset(size.width - 20, centerY),
      paint,
    );

    // Left leaves (symmetrical branch)
    _drawLeaves(canvas, centerX - 40, centerY, isLeft: true, paint: paint, fillPaint: fillPaint);
    // Right leaves
    _drawLeaves(canvas, centerX + 40, centerY, isLeft: false, paint: paint, fillPaint: fillPaint);
  }

  void _drawLeaves(Canvas canvas, double x, double y, {required bool isLeft, required Paint paint, required Paint fillPaint}) {
    final sign = isLeft ? -1 : 1;

    // Top leaf
    final topLeaf = Path();
    topLeaf.moveTo(x, y);
    topLeaf.quadraticBezierTo(x + (8 * sign), y - 7, x + (15 * sign), y - 2);
    topLeaf.quadraticBezierTo(x + (8 * sign), y - 1, x, y);
    canvas.drawPath(topLeaf, fillPaint);

    // Bottom leaf
    final bottomLeaf = Path();
    bottomLeaf.moveTo(x, y);
    bottomLeaf.quadraticBezierTo(x + (8 * sign), y + 7, x + (15 * sign), y + 2);
    bottomLeaf.quadraticBezierTo(x + (8 * sign), y + 1, x, y);
    canvas.drawPath(bottomLeaf, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _BotanicalPainter oldDelegate) => oldDelegate.color != color;
}
