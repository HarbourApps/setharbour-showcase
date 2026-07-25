/// A timed interval (HIIT / Tabata style) plan.
///
/// The timer runs: an optional prepare/get-ready countdown, then [rounds]
/// repetitions of [workSeconds] work followed by [restSeconds] rest. One
/// "interval" is one work block, so the number of intervals equals [rounds].
class IntervalPlan {
  const IntervalPlan({
    required this.id,
    required this.name,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    this.prepareSeconds = 10,
    this.isPreset = true,
  });

  final String id;
  final String name;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final int prepareSeconds;
  final bool isPreset;

  bool get isCustom => !isPreset;

  /// Number of work blocks (== rounds).
  int get intervals => rounds;

  /// Total active time excluding the prepare countdown.
  int get bodySeconds => rounds * (workSeconds + restSeconds);

  /// Whole-plan length, rounded to whole minutes for display (`4 min`).
  int get displayMinutes => (bodySeconds / 60).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'workSeconds': workSeconds,
        'restSeconds': restSeconds,
        'rounds': rounds,
        'prepareSeconds': prepareSeconds,
        'isPreset': isPreset,
      };

  factory IntervalPlan.fromJson(Map<String, dynamic> json) => IntervalPlan(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        workSeconds: json['workSeconds'] as int? ?? 0,
        restSeconds: json['restSeconds'] as int? ?? 0,
        rounds: json['rounds'] as int? ?? 0,
        prepareSeconds: json['prepareSeconds'] as int? ?? 10,
        isPreset: json['isPreset'] as bool? ?? true,
      );
}
