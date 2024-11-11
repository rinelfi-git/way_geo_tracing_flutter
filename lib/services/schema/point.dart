class PointSchema {
  static const String TABLE = 'point';
  static const String ID = '_id';
  static const String HISTORY = 'history';
  static const String DATE = 'date';
  static const String LATITUDE = 'latitude';
  static const String LONGITUDE = 'longitude';
  static const List<String> VALUES = [ID, HISTORY, DATE, LATITUDE, LONGITUDE];
}

class Point {
  final int? id;
  final int history;
  final DateTime date;
  final double latitude;
  final double longitude;

  const Point({
    this.id,
    required this.history,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  Point copy({
    int? id,
    int? history,
    DateTime? date,
    double? latitude,
    double? longitude,
  }) {
    return Point(
      id: id ?? this.id,
      history: history ?? this.history,
      date: date ?? this.date,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      PointSchema.ID: id,
      PointSchema.HISTORY: history,
      PointSchema.DATE: date.toIso8601String(),
      PointSchema.LATITUDE: latitude,
      PointSchema.LONGITUDE: longitude
    };
  }

  static Point fromMap(Map<String, Object?> map) {
    return Point(
      id: map[PointSchema.ID] as int?,
      history: map[PointSchema.HISTORY] as int,
      date: DateTime.parse(map[PointSchema.DATE] as String),
      latitude: map[PointSchema.LATITUDE] as double,
      longitude: map[PointSchema.LONGITUDE] as double,
    );
  }
}
