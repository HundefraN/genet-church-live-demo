import 'dart:math';
import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final DateTime dateTime;

  ClockPainter({required this.dateTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 4;

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center, radius + 4, glowPaint);

    final backgroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, backgroundPaint);

    final outlineBrush = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, outlineBrush);

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final isMainHour = i % 3 == 0;
      final markerLength = isMainHour ? 15 : 8;
      final markerWidth = isMainHour ? 3 : 2;

      final p1 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - markerLength) * cos(angle),
        center.dy + (radius - markerLength) * sin(angle),
      );

      final markerPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = markerWidth as double
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, markerPaint);
    }

    final secondHandLength = radius * 0.8;
    final minuteHandLength = radius * 0.65;
    final hourHandLength = radius * 0.45;

    final hour = dateTime.hour % 12;
    final minute = dateTime.minute;
    final second = dateTime.second;

    final hourHandAngle = (hour * 30 + minute * 0.5 - 90) * pi / 180;
    final minuteHandAngle = (minute * 6 - 90) * pi / 180;
    final secondHandAngle = (second * 6 - 90) * pi / 180;

    _drawHandWithShadow(
      canvas,
      center,
      hourHandLength,
      hourHandAngle,
      5,
      Colors.white,
    );

    _drawHandWithShadow(
      canvas,
      center,
      minuteHandLength,
      minuteHandAngle,
      4,
      Colors.white,
    );

    final secondHandPaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final secondHandGlow = Paint()
      ..color = Colors.redAccent.withOpacity(0.5)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final secondHandEnd = Offset(
      center.dx + secondHandLength * cos(secondHandAngle),
      center.dy + secondHandLength * sin(secondHandAngle),
    );

    canvas.drawLine(center, secondHandEnd, secondHandGlow);
    canvas.drawLine(center, secondHandEnd, secondHandPaint);

    final centerDotPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.grey.shade300],
      ).createShader(Rect.fromCircle(center: center, radius: 8));

    canvas.drawCircle(center, 8, centerDotPaint);

    final centerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 8, centerBorderPaint);
  }

  void _drawHandWithShadow(
      Canvas canvas,
      Offset center,
      double length,
      double angle,
      double width,
      Color color,
      ) {
    final handEnd = Offset(
      center.dx + length * cos(angle),
      center.dy + length * sin(angle),
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = width + 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx + 2, center.dy + 2),
      Offset(handEnd.dx + 2, handEnd.dy + 2),
      shadowPaint,
    );

    final handPaint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, handEnd, handPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}