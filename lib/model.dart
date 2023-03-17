import 'dart:convert';

T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class LFBezierData {
  LFBezierData({
    required this.topHeight,
    required this.bottomHeight,
    required this.targetWidth,
    required this.points,
  });

  factory LFBezierData.fromJson(Map<String, dynamic> json) {
    final List<PointCupple>? points = json['points'] is List ? <PointCupple>[] : null;
    if (points != null) {
      for (final dynamic item in json['points']!) {
        if (item != null) {
          points.add(PointCupple.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }
    return LFBezierData(
      topHeight: asT<double>(json['topHeight'])!,
      bottomHeight: asT<double>(json['bottomHeight'])!,
      targetWidth: asT<double>(json['targetWidth'])!,
      points: points!,
    );
  }

  double topHeight;
  double bottomHeight;
  double targetWidth;
  List<PointCupple> points;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'topHeight': topHeight,
        'bottomHeight': bottomHeight,
        'targetWidth': targetWidth,
        'points': points,
      };
}

class PointCupple {
  PointCupple({
    required this.controlPoint,
    required this.endPoint,
  });

  factory PointCupple.fromJson(Map<String, dynamic> json) => PointCupple(
        controlPoint: JsonOffset.fromJson(asT<Map<String, dynamic>>(json['controlPoint'])!),
        endPoint: JsonOffset.fromJson(asT<Map<String, dynamic>>(json['endPoint'])!),
      );

  JsonOffset controlPoint;
  JsonOffset endPoint;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'controlPoint': controlPoint,
        'endPoint': endPoint,
      };
}

class JsonOffset {
  JsonOffset({
    required this.x,
    required this.y,
  });

  factory JsonOffset.fromJson(Map<String, dynamic> json) => JsonOffset(
        x: asT<double>(json['x'])!,
        y: asT<double>(json['y'])!,
      );

  double x;
  double y;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'x': x,
        'y': y,
      };
}
