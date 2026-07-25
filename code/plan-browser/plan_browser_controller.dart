import 'package:flutter/foundation.dart';

import 'preferences_service.dart';
import '../shared/models/workout_plan.dart';

/// The two presentations of the single plan collection.
enum PlanViewMode {
  folders,
  list;

  static PlanViewMode fromKey(String? key) =>
      key == 'list' ? PlanViewMode.list : PlanViewMode.folders;
}

/// Drives the dual-view plan browser.
///
/// Crucially, both the folder view and the list view read from the *same*
/// [_allPlans] collection — folders are produced by grouping on `folderId`, not
/// by holding a second copy of the data. Filters apply identically in both
/// views. The preferred view is persisted so it survives a restart.
class PlanBrowserController extends ChangeNotifier {
  PlanBrowserController({
    required List<WorkoutPlan> plans,
    required List<PlanFolder> folders,
    PreferencesService preferences = const PreferencesService(),
  })  : _allPlans = List.unmodifiable(plans),
        _folders = List.unmodifiable(folders),
        _preferences = preferences;

  final List<WorkoutPlan> _allPlans;
  final List<PlanFolder> _folders;
  final PreferencesService _preferences;

  PlanViewMode _viewMode = PlanViewMode.folders;
  PlanCategory? _category;
  Difficulty? _difficulty;

  PlanViewMode get viewMode => _viewMode;
  PlanCategory? get category => _category;
  Difficulty? get difficulty => _difficulty;
  List<PlanFolder> get folders => _folders;
  List<WorkoutPlan> get allPlans => _allPlans;

  bool get hasActiveFilters => _category != null || _difficulty != null;

  /// The plans matching the current filters (shared by both views).
  List<WorkoutPlan> get filteredPlans => _allPlans.where((p) {
        final bool categoryOk = _category == null || p.category == _category;
        final bool difficultyOk =
            _difficulty == null || p.difficulty == _difficulty;
        return categoryOk && difficultyOk;
      }).toList();

  /// Filtered plans that belong to [folderId].
  List<WorkoutPlan> plansInFolder(String folderId) =>
      filteredPlans.where((p) => p.folderId == folderId).toList();

  /// Total plans in a folder, ignoring filters (shown as the folder count).
  int totalPlansInFolder(String folderId) =>
      _allPlans.where((p) => p.folderId == folderId).length;

  /// Loads the persisted preferred view. Safe to call once at startup.
  Future<void> loadPreferredView() async {
    final String? stored = await _preferences.getPreferredPlanView();
    if (stored != null) {
      _viewMode = PlanViewMode.fromKey(stored);
      notifyListeners();
    }
  }

  void setViewMode(PlanViewMode mode) {
    if (_viewMode == mode) return;
    _viewMode = mode;
    notifyListeners();
  }

  /// Sets the view and persists it as the default (long-press action).
  Future<void> setPreferredView(PlanViewMode mode) async {
    setViewMode(mode);
    await _preferences.setPreferredPlanView(mode.name);
  }

  void setCategory(PlanCategory? category) {
    _category = category;
    notifyListeners();
  }

  void setDifficulty(Difficulty? difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  void clearFilters() {
    _category = null;
    _difficulty = null;
    notifyListeners();
  }
}
