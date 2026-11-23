class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.techniqueId,
    required this.startedAt,
    required this.durationSeconds,
    required this.completed,
  });

  final String id;
  final String techniqueId;
  final DateTime startedAt;
  final int durationSeconds;

  /// True when the user reached the planned end of the session.
  final bool completed;

  DateTime get day => DateTime(startedAt.year, startedAt.month, startedAt.day);

  Map<String, dynamic> toJson() => {
    'id': id,
    't': techniqueId,
    's': startedAt.millisecondsSinceEpoch,
    'd': durationSeconds,
    'c': completed,
  };

  factory SessionRecord.fromJson(Map<String, dynamic> json) => SessionRecord(
    id: json['id'] as String,
    techniqueId: json['t'] as String,
    startedAt: DateTime.fromMillisecondsSinceEpoch((json['s'] as num).toInt()),
    durationSeconds: (json['d'] as num).toInt(),
    completed: json['c'] as bool? ?? false,
  );
}
