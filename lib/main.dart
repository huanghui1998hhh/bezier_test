import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scrollBehavior: AppScrollBehavior(),
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Board(),
    );
  }
}

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  Offset _startPoint = Offset(0, 0);
  List<PointCupple> _points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: _ChessboardPainter(),
        foregroundPainter: A([]),
        size: Size.infinite,
      ),
    );
  }
}

class PointCupple {
  PointCupple(this.controlPoint, this.endPoint);

  Offset controlPoint;
  Offset endPoint;
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class A extends CustomPainter {
  const A(this.points);
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()..color = Colors.red;
    final _path = Path();

    // _path.moveTo(size.width, 0);
    // _path.lineTo(0, 0);
    // _path.lineTo(0, 50);
    // _path.quadraticBezierTo(x1, y1, x2, y2)

    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(A oldDelegate) => false;
}

class _ChessboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 0.5;

    const cellSize = 10.0;

    final x = size.height ~/ 10;
    final y = size.width ~/ 10;

    // Draw horizontal lines
    for (var i = 0; i <= y; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }

    // Draw vertical lines
    for (var i = 0; i <= x; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ChessboardPainter oldDelegate) => false;
}
