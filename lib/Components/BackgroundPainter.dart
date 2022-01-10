import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  @override
  void paint(canvas, size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Color(0xFFD2DAEA);
    paint.shader = LinearGradient(
      colors: [
        Colors.blue[900].withOpacity(0.6),
        Colors.cyan.withOpacity(0.2),
      ],
    ).createShader(Offset.zero & size);
    canvas.drawPath(mainBackground, paint);

    Path cornerPath3 = Path();
    cornerPath3.moveTo(width * 0.15, 0);
    cornerPath3.quadraticBezierTo(
        width * 0.25, height * 0.21, width * 0.60, height * 0.29);
    cornerPath3.quadraticBezierTo(
        width * 0.9, height * 0.35, width, height * 0.6);
    cornerPath3.lineTo(width, 0);
    paint.color = Colors.blue.withOpacity(0.7);

    canvas.drawPath(cornerPath3, paint);

    Path cornerPath2 = Path();
    cornerPath2.moveTo(width * 0.2, 0);
    cornerPath2.quadraticBezierTo(
        width * 0.34, height * 0.2, width * 0.6, height * 0.2);
    cornerPath2.quadraticBezierTo(
        width * 0.85, height * 0.2, width, height * 0.35);
    cornerPath2.lineTo(width, 0);
    paint.color = Color(0xFFD2DAEA).withOpacity(0.8);
    canvas.drawPath(cornerPath2, paint);

    Path cornerPath = Path();
    cornerPath.moveTo(width * 0.27, 0);
    cornerPath.quadraticBezierTo(
        width * 0.37, height * 0.09, width * 0.65, height * 0.09);
    cornerPath.quadraticBezierTo(
        width * 0.97, height * 0.1, width, height * 0.25);
    cornerPath.lineTo(width, 0);
    paint.color = Colors.blue.withOpacity(0.9);
    canvas.drawPath(cornerPath, paint);

    Path ovalPath = Path();
    ovalPath.moveTo(0, height * 0.5);
    ovalPath.quadraticBezierTo(
        width * 0.15, height * 0.95, width * 0.65, height);
    ovalPath.lineTo(0, height);
    ovalPath.close();
    paint.color = Colors.blue.withOpacity(0.3);
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class BackgroundPainterDark extends CustomPainter {
  @override
  void paint(canvas, size) {
    final height = size.height;
    final width = size.width;
    Paint paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, width, height));
    paint.color = Color(0xFF2B3A58);
    paint.shader = LinearGradient(
      colors: [
        Colors.blue[900].withOpacity(0.5),
        Colors.cyan[200].withOpacity(0.5),
      ],
    ).createShader(Offset.zero & size);
    canvas.drawPath(mainBackground, paint);

    Path cornerPath3 = Path();
    cornerPath3.moveTo(width * 0.15, 0);
    cornerPath3.quadraticBezierTo(
        width * 0.25, height * 0.21, width * 0.60, height * 0.29);
    cornerPath3.quadraticBezierTo(
        width * 0.9, height * 0.35, width, height * 0.6);
    cornerPath3.lineTo(width, 0);
    paint.color = Color(0xFFC6D1DA).withOpacity(0.6);
    canvas.drawPath(cornerPath3, paint);

    Path cornerPath2 = Path();
    cornerPath2.moveTo(width * 0.2, 0);
    cornerPath2.quadraticBezierTo(
        width * 0.34, height * 0.2, width * 0.6, height * 0.2);
    cornerPath2.quadraticBezierTo(
        width * 0.85, height * 0.2, width, height * 0.35);
    cornerPath2.lineTo(width, 0);
    paint.color = Color(0xFFC6D1DA).withOpacity(0.8);
    canvas.drawPath(cornerPath2, paint);

    Path cornerPath = Path();
    cornerPath.moveTo(width * 0.27, 0);
    cornerPath.quadraticBezierTo(
        width * 0.37, height * 0.09, width * 0.65, height * 0.09);
    cornerPath.quadraticBezierTo(
        width * 0.97, height * 0.1, width, height * 0.25);
    cornerPath.lineTo(width, 0);
    paint.color = Color(0xFFC6D1DA);
    canvas.drawPath(cornerPath, paint);

    Path ovalPath = Path();
    ovalPath.moveTo(0, height * 0.5);
    ovalPath.quadraticBezierTo(
        width * 0.15, height * 0.95, width * 0.65, height);
    ovalPath.lineTo(0, height);
    ovalPath.close();
    paint.color = Color(0xFFC6D1DA).withOpacity(0.6);
    canvas.drawPath(ovalPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
