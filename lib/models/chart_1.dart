import 'package:flutter/material.dart';

class ChartPainter1 extends CustomPainter {

  final List<double> list;
  final double average;
  final int count;
  final Color color;

  ChartPainter1({
    required this.list,
    required this.average,
    required this.count,
    required this.color
  });

  @override
  void paint(Canvas canvas, Size size) {
    var w = size.width / (count);

    var gridPaint0 = Paint()
      ..color = Colors.grey[400]!.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    var gridPaint1 = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var gridPaint2 = Paint()
      ..color = Colors.grey[600]!.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    var fillPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    var strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    double x0;
    double y0;

    double yg0a = 9.0;
    double xg1 = 0.0;
    double yg1a = size.height;
    double yg1 = size.height - yg0a;
    Offset offsetG0;
    Offset offsetG1;
    Offset offsetG0a;
    Offset offsetG1a;

    //draw grid mini lines
    for (var i = 0; i < count + 1; i++) {
      xg1 = i * w;
      offsetG0 = Offset(xg1, 0.0);
      offsetG0a = Offset(xg1, yg0a);
      offsetG1 = Offset(xg1, yg1);
      offsetG1a = Offset(xg1, yg1a);
      canvas.drawLine(offsetG0, offsetG0a, gridPaint0);
      canvas.drawLine(offsetG1, offsetG1a, gridPaint0);
    }

    //average line
    canvas.drawLine(Offset(0.0, size.height - average),
        Offset(size.width, size.height - average), gridPaint2);

    //rect chart
    Rect rect1;

    for (var i = 0; i < count; i++) {
      x0 = i * w;
      y0 = list[i];
      rect1 = Offset(x0, y0) & Size(w, size.height - y0);
      canvas.drawRect(rect1, fillPaint);
      canvas.drawRect(rect1, strokePaint);
    }

    //draw edge rectangle
    Rect rect = const Offset(0.0, 0.0) & Size(size.width, size.height);
    canvas.drawRect(rect, gridPaint1);
  }

  @override
  bool shouldRepaint(ChartPainter1 oldDelegate) {
    return false;
  }
}