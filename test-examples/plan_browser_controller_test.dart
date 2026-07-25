import 'package:flutter_test/flutter_test.dart';
import '../code/backup-import-export/demo_dataset.dart';
import '../code/plan-browser/plan_browser_controller.dart';
import '../code/shared/models/portfolio_backup.dart';
import '../code/shared/models/workout_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final PortfolioBackup demo = DemoDataset.build();

  PlanBrowserController make() => PlanBrowserController(
        plans: demo.plans,
        folders: demo.folders,
      );

  test('there are 20 plans across 5 folders', () {
    expect(demo.plans.length, 20);
    expect(demo.folders.length, 5);
  });

  test('folder counts sum to the total plan count', () {
    final PlanBrowserController c = make();
    final int summed = c.folders
        .map((f) => c.totalPlansInFolder(f.id))
        .fold<int>(0, (a, b) => a + b);
    expect(summed, demo.plans.length);
  });

  test('category filter narrows results', () {
    final PlanBrowserController c = make();
    c.setCategory(PlanCategory.legs);
    expect(c.filteredPlans, isNotEmpty);
    expect(
        c.filteredPlans.every((p) => p.category == PlanCategory.legs), isTrue);
  });

  test('difficulty filter narrows results', () {
    final PlanBrowserController c = make();
    c.setDifficulty(Difficulty.advanced);
    expect(c.filteredPlans.every((p) => p.difficulty == Difficulty.advanced),
        isTrue);
  });

  test('multiple filters combine', () {
    final PlanBrowserController c = make();
    c.setCategory(PlanCategory.legs);
    c.setDifficulty(Difficulty.advanced);
    expect(
      c.filteredPlans.every((p) =>
          p.category == PlanCategory.legs &&
          p.difficulty == Difficulty.advanced),
      isTrue,
    );
  });

  test('clearing filters restores all plans', () {
    final PlanBrowserController c = make();
    c.setCategory(PlanCategory.push);
    c.setDifficulty(Difficulty.beginner);
    c.clearFilters();
    expect(c.filteredPlans.length, demo.plans.length);
    expect(c.hasActiveFilters, isFalse);
  });

  test('folder and list views draw from the same collection', () {
    final PlanBrowserController c = make();
    final int viaFolders =
        c.folders.expand((f) => c.plansInFolder(f.id)).length;
    expect(viaFolders, c.filteredPlans.length);
    expect(identical(c.allPlans, c.allPlans), isTrue);
  });

  test('switching views does not change the data or filters', () {
    final PlanBrowserController c = make();
    c.setCategory(PlanCategory.pull);
    final List<WorkoutPlan> before = c.filteredPlans;
    c.setViewMode(PlanViewMode.list);
    c.setViewMode(PlanViewMode.folders);
    expect(c.filteredPlans.map((p) => p.id), before.map((p) => p.id));
  });

  test('preferred view is persisted and reloaded (demo state)', () async {
    SharedPreferences.setMockInitialValues({});
    final PlanBrowserController writer = make();
    await writer.setPreferredView(PlanViewMode.list);

    // A fresh controller should load the persisted preference.
    final PlanBrowserController reader = make();
    await reader.loadPreferredView();
    expect(reader.viewMode, PlanViewMode.list);
  });
}
