import 'package:flutter/material.dart';
import 'package:soulfood_front/core/theme/classic_brand_palette.dart';

/// 经典主题品牌图形：暖色碗 + 筷子（与经典 App 图标同系）。
class ClassicBrandMark extends StatelessWidget {
  const ClassicBrandMark({
    super.key,
    this.size = 88,
    this.showPlate = true,
    this.glow = true,
  });

  final double size;
  final bool showPlate;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ClassicBrandPainter(showPlate: showPlate, glow: glow),
      ),
    );
  }
}

class _ClassicBrandPainter extends CustomPainter {
  _ClassicBrandPainter({required this.showPlate, required this.glow});

  final bool showPlate;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 88;

    if (glow) {
      final glowPaint = Paint()
        ..color = ClassicBrandPalette.accent.withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 * scale);
      canvas.drawCircle(center, size.width * 0.42, glowPaint);
    }

    if (showPlate) {
      final plateR = size.width * 0.38;
      final platePaint = Paint()..color = ClassicBrandPalette.plate.withValues(alpha: 0.92);
      canvas.drawCircle(center.translate(0, size.height * 0.04), plateR, platePaint);
    }

    // bowl
    final bowlW = size.width * 0.5;
    final bowlH = size.height * 0.22;
    final bowlLeft = center.dx - bowlW / 2;
    final bowlTop = center.dy - bowlH * 0.15;
    final bowlRect = Rect.fromLTWH(bowlLeft, bowlTop, bowlW, bowlH * 1.6);
    final bowlPaint = Paint()..color = ClassicBrandPalette.bowl;
    canvas.drawArc(bowlRect, 0, 3.14159, false, bowlPaint..strokeWidth = 3 * scale..style = PaintingStyle.stroke);
    final bowlFill = Paint()..color = ClassicBrandPalette.bowl;
    canvas.drawArc(
      Rect.fromLTWH(bowlLeft, bowlTop + bowlH * 0.35, bowlW, bowlH),
      0,
      3.14159,
      true,
      bowlFill,
    );

    // chopsticks
    final stickPaint = Paint()
      ..color = ClassicBrandPalette.chopstick
      ..strokeWidth = 2.8 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.18),
      Offset(size.width * 0.4, size.height * 0.46),
      stickPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.78, size.height * 0.18),
      Offset(size.width * 0.6, size.height * 0.46),
      stickPaint,
    );

    // steam
    final steamPaint = Paint()..color = ClassicBrandPalette.steam.withValues(alpha: 0.85);
    for (final dx in [-0.08, 0.0, 0.08]) {
      canvas.drawCircle(
        Offset(center.dx + size.width * dx, size.height * 0.28),
        2.2 * scale,
        steamPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
