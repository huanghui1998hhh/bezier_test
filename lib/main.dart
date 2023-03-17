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
  late final A painter;

  @override
  void initState() {
    super.initState();
    painter = A();
  }

  @override
  void dispose() {
    painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) => painter.update(details.delta),
        child: CustomPaint(
        painter: _ChessboardPainter(),
        foregroundPainter: painter,
        size: Size.infinite,
      ),
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

class A extends ChangeNotifier implements CustomPainter {
  A();
  final Offset _startPoint = Offset(0, 0);
  final List<PointCupple> _points = [PointCupple(Offset(50,300), Offset(1000,-0))];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(0, size.height / 2);
    var paint1 = Paint()
    ..color = Colors.red;

    var paint2 = Paint()
    ..color = Colors.blue;

    var path = Path();

    // _path.moveTo(size.width, 0);
    // _path.lineTo(0, 0);
    // _path.lineTo(0, 50);
    // _path.quadraticBezierTo(x1, y1, x2, y2)

    path.moveTo(_startPoint.dx, _startPoint.dy);
    for (var e in _points) { 
      path.quadraticBezierTo(e.controlPoint.dx, e.controlPoint.dy,e.endPoint.dx, e.endPoint.dy);
    }
    path.lineTo(1000, -100);
    path.lineTo(0, -100);
    path.close();

    canvas.drawPath(path, paint1);
    
    canvas.drawPath(Path.combine(PathOperation.difference, Path()..addRect(Rect.fromPoints(Offset(0,-100), Offset(1000,300))), path), paint2);

    // canvas.drawLine(_startPoint, _points[0].endPoint    , paint);
  }

  void update(Offset delta) {
    _points[0].controlPoint +=  delta;
    notifyListeners();
  }

  @override
  bool shouldRepaint(A oldDelegate) => true;
  
  @override
  bool? hitTest(Offset? position) => true;
  
  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) => false;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;
}

class _ChessboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5;

    const cellSize = 10.0;

    final x = size.height ~/ 10;
    final y = size.width ~/ 10;

    // Draw horizontal lines
    for (var i = 0; i <= x; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }

    // Draw vertical lines
    for (var i = 0; i <= y; i++) {
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
