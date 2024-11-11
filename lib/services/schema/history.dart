class HistorySchema {
  static const String TABLE = 'history';
  static const String ID = '_id';
  static const String DEPARTURE = 'departure';
  static const String ARRIVAL = 'arrival';
  static const String FINISHED_LINE = 'finished_line';
  static const List<String> VALUES = [ID, DEPARTURE, ARRIVAL, FINISHED_LINE];
}

class History {
  final int? id;
  final String departure;
  final String? arrival;
  final bool? finishedLine;

  const History({
    this.id,
    required this.departure,
    this.arrival,
    this.finishedLine,
  });

  History copy({
    int? id,
    String? departure,
    String? arrival,
    bool? finishedLine,
  }) {
    return History(
      id: id ?? this.id,
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      finishedLine: finishedLine ?? this.finishedLine,
    );
  }

  Map<String, dynamic> toMap({String? device}) {
    final json = {
      HistorySchema.ID: id,
      HistorySchema.DEPARTURE: departure,
      HistorySchema.ARRIVAL: arrival,
      HistorySchema.FINISHED_LINE: (finishedLine ?? false) ? 1 : 0
    };
    if (device != null) json['device'] = device;
    return json;
  }

  static History fromMap(Map<String, Object?> map) {
    return History(
      id: map[HistorySchema.ID] as int?,
      departure: map[HistorySchema.DEPARTURE] as String,
      arrival: map[HistorySchema.ARRIVAL] as String?,
      finishedLine: map[HistorySchema.FINISHED_LINE] as int == 1,
    );
  }
}
