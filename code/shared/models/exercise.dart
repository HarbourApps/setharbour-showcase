/// A single exercise in the library. Preset exercises ship with the app;
/// custom exercises are created by the user.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.isPreset = true,
  });

  final String id;
  final String name;

  /// One of [MuscleGroups] — kept as a plain string so custom exercises can use
  /// any label without a schema migration.
  final String muscleGroup;

  final bool isPreset;

  bool get isCustom => !isPreset;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'isPreset': isPreset,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        muscleGroup: json['muscleGroup'] as String? ?? MuscleGroups.other,
        isPreset: json['isPreset'] as bool? ?? true,
      );

  Exercise copyWith({String? name, String? muscleGroup, bool? isPreset}) =>
      Exercise(
        id: id,
        name: name ?? this.name,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        isPreset: isPreset ?? this.isPreset,
      );
}

/// Canonical muscle-group labels used by preset data and progress aggregation.
class MuscleGroups {
  MuscleGroups._();

  static const String legs = 'Legs';
  static const String back = 'Back';
  static const String chest = 'Chest';
  static const String shoulders = 'Shoulders';
  static const String arms = 'Arms';
  static const String calves = 'Calves';
  static const String glutes = 'Glutes';
  static const String core = 'Core';
  static const String other = 'Other';

  static const List<String> all = [
    legs,
    back,
    chest,
    shoulders,
    arms,
    calves,
    glutes,
    core,
    other,
  ];
}
