// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:bezier_test/model.dart';
import 'package:flutter/material.dart';

import 'dart:ui';

import 'package:flutter/services.dart';

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
        primarySwatch: Colors.blue,
      ),
      home: const Board(),
    );
  }
}

class _Offset {
  _Offset(this.dx, this.dy);

  double dx;
  double dy;

  Offset get uiOffset => Offset(dx, dy);
  JsonOffset get jsonOffset => JsonOffset(x: dx, y: dy);
}

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  late final _topHeightController = TextEditingController(text: '100');
  late final _bottomHeightController = TextEditingController(text: '100');
  late final _targetWidthController = TextEditingController(text: '1700');
  late final _inputDataController = TextEditingController();
  late final BezierGetter _painter = BezierGetter(_topHeight, _bottomHeight, 1700);

  double get _topHeight => double.tryParse(_topHeightController.text) ?? 100;
  double get _bottomHeight => double.tryParse(_bottomHeightController.text) ?? 100;
  double get _targetWidth => double.tryParse(_targetWidthController.text) ?? 1700;

  @override
  void dispose() {
    _painter.dispose();
    _topHeightController.dispose();
    _bottomHeightController.dispose();
    _targetWidthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              children: [
                const SizedBox(width: 44),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _topHeightController,
                    decoration: const InputDecoration(labelText: '上高'),
                    onSubmitted: (value) => _painter.topHeight = _topHeight,
                  ),
                ),
                const SizedBox(width: 44),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _bottomHeightController,
                    decoration: const InputDecoration(labelText: '下高'),
                    onSubmitted: (value) => _painter.bottomHeight = _bottomHeight,
                  ),
                ),
                const SizedBox(width: 44),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _targetWidthController,
                    decoration: const InputDecoration(labelText: '预览宽'),
                    onSubmitted: (value) => _painter.targetWidth = _targetWidth,
                  ),
                ),
                const SizedBox(width: 44),
                ElevatedButton(onPressed: _painter.tooglePointIndicator, child: const Text('显示/隐藏控制点提示')),
                const SizedBox(width: 44),
                ElevatedButton(onPressed: _painter.addPoint, child: const Text('在后面加一段')),
                const SizedBox(width: 44),
                ElevatedButton(onPressed: _painter.removePoint, child: const Text('去掉最后一段')),
                const SizedBox(width: 44),
                Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        final data = _painter.generateData().toString();
                        final mScaffold = ScaffoldMessenger.of(context);
                        await Clipboard.setData(ClipboardData(text: data));
                        mScaffold.showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                      },
                      child: const Text('生成数据'),
                    );
                  },
                ),
                const SizedBox(width: 44),
                Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        final data = _painter.generateCodeString();
                        final mScaffold = ScaffoldMessenger.of(context);
                        await Clipboard.setData(ClipboardData(text: data));
                        mScaffold.showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                      },
                      child: const Text('生成代码'),
                    );
                  },
                ),
                const SizedBox(width: 44),
                Expanded(child: TextField(controller: _inputDataController)),
                Builder(builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      final result = _painter.inputData(_inputDataController.text);
                      final mScaffold = ScaffoldMessenger.of(context);
                      mScaffold.showSnackBar(SnackBar(content: Text(result ? '导入成功' : '导入失败')));
                    },
                    child: const Text('导入数据'),
                  );
                }),
                const SizedBox(width: 44),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanDown: _painter.onPanDown,
              onPanUpdate: (details) => _painter.update(details.delta),
              onPanEnd: _painter.onPanEnd,
              child: CustomPaint(
                painter: _ChessboardPainter(),
                foregroundPainter: _painter,
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPointCupple {
  MyPointCupple(this.controlPoint, this.endPoint);

  _Offset controlPoint;
  _Offset endPoint;
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class BezierGetter extends ChangeNotifier implements CustomPainter {
  BezierGetter(this.topHeight, this.bottomHeight, this._targetWidth);

  final _Offset _startPoint = _Offset(0, 0);
  late List<MyPointCupple> _points = [MyPointCupple(_Offset(511, -155), _Offset(targetWidth, -0))];

   bool _hidePointIndicator = false;

  double topHeight;
  double bottomHeight;
  double _targetWidth;
  double get targetWidth => _targetWidth;
  set targetWidth(double value) {
    if (_targetWidth == value) return;
    _targetWidth = value;
    final flag = _targetWidth / _points.last.endPoint.dx;
    xScale(flag, handleEnd: true);
    notifyListeners();
  }

  _Offset? _selectedOffset;

  double _lastPaintOffset = 0;

  @override
  void paint(Canvas canvas, Size size) {
    _lastPaintOffset = size.height / 2;
    canvas.translate(0, size.height / 2);
    var paint1 = Paint()..color = Colors.red;
    var paint2 = Paint()..color = Colors.blue;

    var path = Path();
    path.moveTo(_startPoint.dx, _startPoint.dy);
    for (var e in _points) {
      path.quadraticBezierTo(e.controlPoint.dx, e.controlPoint.dy, e.endPoint.dx, e.endPoint.dy);
    }
    path.lineTo(targetWidth, -topHeight);
    path.lineTo(0, -topHeight);
    path.close();

    canvas.drawPath(path, paint1);

    canvas.drawPath(
      Path.combine(PathOperation.difference,
          Path()..addRect(Rect.fromPoints(Offset(0, -topHeight), Offset(targetWidth, bottomHeight))), path),
      paint2,
    );

    if(!_hidePointIndicator) {
      _paintPoints(canvas);
    }

    if (_selectedOffset != null) {
      canvas.drawCircle(
        _selectedOffset!.uiOffset,
        15,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Colors.green,
      );
    }
  }

  void addPoint() {
    final flag = _points.length / (_points.length + 1);
    xScale(flag);
    _points.add(MyPointCupple(_Offset((0.5 + flag / 2) * targetWidth, 0), _Offset(targetWidth, 0)));
    notifyListeners();
  }

  void removePoint() {
    if (_points.length < 2) return;
    final flag = targetWidth / _points[_points.length - 2].endPoint.dx;
    _points.removeLast();
    xScale(flag, handleEnd: true);
    notifyListeners();
  }

  void xScale(double flag, {bool handleEnd = false}) {
    for (var i = 0; i < _points.length; i++) {
      final e = _points[i];
      e.controlPoint.dx *= flag;
      if (i == _points.length - 1 && handleEnd) {
        e.endPoint.dx = targetWidth;
      } else {
        e.endPoint.dx *= flag;
      }
    }
  }

  void tooglePointIndicator() {
    _hidePointIndicator = !_hidePointIndicator;
    notifyListeners();
  }

  void _paintPoints(Canvas canvas) {
    final endpointPaint = Paint()..color = Colors.black;
    final controlpointPaint = Paint()..color = Colors.purple;
    canvas.drawCircle(_startPoint.uiOffset, 5, endpointPaint);

    for (var point in _points) {
      canvas.drawCircle(point.controlPoint.uiOffset, 5, controlpointPaint);
      canvas.drawCircle(point.endPoint.uiOffset, 5, endpointPaint);
    }
  }

  void update(Offset delta) {
    if (_selectedOffset == null) return;
    if (_selectedOffset != _points.last.endPoint) {
      _selectedOffset!.dx += delta.dx;
    }
    _selectedOffset!.dy += delta.dy;
    notifyListeners();
  }

  void onPanDown(DragDownDetails details) {
    if (_hidePointIndicator) return;
    
    final rPosition = details.localPosition - Offset(0, _lastPaintOffset);

    _Offset? temp;

    for (var e in _points) {
      if (_judgeCircleArea(rPosition, e.controlPoint, 33)) {
        temp = e.controlPoint;
        break;
      }
      if (_judgeCircleArea(rPosition, e.endPoint, 33)) {
        temp = e.endPoint;
        break;
      }
    }

    if (temp == _selectedOffset) return;

    _selectedOffset = temp;
    if (_selectedOffset != _points.last.endPoint) {
      temp?.dx = rPosition.dx;
    }
    temp?.dy = rPosition.dy;
    notifyListeners();
  }

  void onPanEnd(DragEndDetails details) {
    if (_selectedOffset == null) return;
    _selectedOffset = null;
    notifyListeners();
  }

  bool _judgeCircleArea(Offset tapPoint, _Offset point, double r) => (tapPoint - point.uiOffset).distance <= r;

  LFBezierData generateData() => LFBezierData(
        topHeight: topHeight,
        bottomHeight: bottomHeight,
        targetWidth: targetWidth,
        points: _points
            .map((e) => PointCupple(controlPoint: e.controlPoint.jsonOffset, endPoint: e.endPoint.jsonOffset))
            .toList(),
      );

  String generateCodeString() {
    var result = '''static const name = LFBezierData(
  topHeight: $topHeight,
  bottomHeight: $bottomHeight,
  targetWidth: $targetWidth,
  points: [
''';
    for (var e in _points) {
      result +=
          '    PointCupple(controlPoint: Offset(${e.controlPoint.dx}, ${e.controlPoint.dy}), endPoint: Offset(${e.endPoint.dx}, ${e.endPoint.dy})),\n';
    }
    result += '''  ],
);''';
    return result;
  }

  bool inputData(String data) {
    LFBezierData? temp;
    try {
      temp = LFBezierData.fromJson(jsonDecode(data));
    } catch (e) {
      print('json解析失败');
    }
    if (temp == null) return false;
    topHeight = temp.topHeight;
    bottomHeight = temp.bottomHeight;
    _targetWidth = temp.targetWidth;
    _points = temp.points
        .map((e) => MyPointCupple(_Offset(e.controlPoint.x, e.controlPoint.y), _Offset(e.endPoint.x, e.endPoint.y)))
        .toList();
    notifyListeners();
    return true;
  }

  @override
  bool shouldRepaint(BezierGetter oldDelegate) => true;

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
      ..strokeWidth = 0.2;

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
