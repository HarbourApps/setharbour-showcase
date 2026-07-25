/// Broad training category used by the plan browser's category filter.
enum PlanCategory {
  fullBody,
  push,
  pull,
  legs,
  upper,
  lower,
  other;

  String get label {
    switch (this) {
      case PlanCategory.fullBody:
        return 'Full Body';
      case PlanCategory.push:
        return 'Push';
      case PlanCategory.pull:
        return 'Pull';
      case PlanCategory.legs:
        return 'Legs';
      case PlanCategory.upper:
        return 'Upper';
      case PlanCategory.lower:
        return 'Lower';
      case PlanCategory.other:
        return 'Other';
    }
  }

  static PlanCategory fromKey(String? key) {
    return PlanCategory.values.firstWhere(
      (c) => c.name == key,
      orElse: () => PlanCategory.other,
    );
  }
}

/// Difficulty used by the plan browser's difficulty filter.
enum Difficulty {
  beginner,
  intermediate,
  advanced;

  String get label {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }

  static Difficulty fromKey(String? key) {
    return Difficulty.values.firstWhere(
      (d) => d.name == key,
      orElse: () => Difficulty.beginner,
    );
  }
}

/// One exercise slot within a plan (the prescription, not the logged result).
class PlanItem {
  const PlanItem({
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
  });

  final String exerciseId;
  final int targetSets;
  final int targetReps;

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'targetSets': targetSets,
        'targetReps': targetReps,
      };

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
        exerciseId: json['exerciseId'] as String? ?? '',
        targetSets: json['targetSets'] as int? ?? 0,
        targetReps: json['targetReps'] as int? ?? 0,
      );
}

/// A strength workout plan.
///
/// A plan carries an optional [folderId]. The same plan collection is rendered
/// two ways in the browser: grouped by [folderId] (folder view) or flat (list
/// view). Folders are a *presentation* of the plans, never a duplicate copy.
class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.items,
    this.folderId,
    this.isPreset = true,
    this.estimatedMinutes = 0,
  });

  final String id;
  final String name;
  final PlanCategory category;
  final Difficulty difficulty;
  final List<PlanItem> items;

  /// Which folder this plan belongs to in folder view (`null` = ungrouped).
  final String? folderId;
  final bool isPreset;
  final int estimatedMinutes;

  int get exerciseCount => items.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'difficulty': difficulty.name,
        'folderId': folderId,
        'isPreset': isPreset,
        'estimatedMinutes': estimatedMinutes,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => WorkoutPlan(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        category: PlanCategory.fromKey(json['category'] as String?),
        difficulty: Difficulty.fromKey(json['difficulty'] as String?),
        folderId: json['folderId'] as String?,
        isPreset: json['isPreset'] as bool? ?? true,
        estimatedMinutes: json['estimatedMinutes'] as int? ?? 0,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((i) => PlanItem.fromJson(Map<String, dynamic>.from(i as Map)))
            .toList(),
      );
}

/// A named folder that groups strength plans in folder view.
class PlanFolder {
  const PlanFolder({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory PlanFolder.fromJson(Map<String, dynamic> json) => PlanFolder(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
      );
}
