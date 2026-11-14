// Hisaab Kitaab — the official multicolour Google "G" (v7.2).
//
// Drawn with a CustomPainter as the four colour segments of the real
// G — blue #4285F4, red #EA4335, yellow #FBBC05, green #34A853 —
// a ring of four arcs plus the blue horizontal bar, not a generic
// letter. Used (~24px) as the icon of "Continue with Google".

import 'dart:math' as math;

import 'package:flutter/material.dart';

class GoogleGIcon extends StatelessWidget {
  const GoogleGIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.17;
    final radius = size.width / 2 - stroke / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    Paint segment(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    double rad(double degrees) => degrees * math.pi / 180;

    // Angles: 0 deg = east, increasing clockwise (Flutter's
    // y-down canvas). The four arcs meet end to end, 360 deg total.
    canvas.drawArc(rect, rad(-90), rad(140), false, segment(_blue));
    canvas.drawArc(rect, rad(50), rad(50), false, segment(_green));
    canvas.drawArc(rect, rad(100), rad(80), false, segment(_yellow));
    canvas.drawArc(rect, rad(180), rad(90), false, segment(_red));

    // The G's horizontal bar: blue, from the centre to the right edge.
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - stroke / 2, size.width / 2,
          stroke),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
