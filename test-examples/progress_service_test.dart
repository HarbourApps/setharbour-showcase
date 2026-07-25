import 'package:flutter_test/flutter_test.dart';
import '../code/backup-import-export/demo_dataset.dart';
import '../code/progress-calculations/personal_best_calculator.dart';
import '../code/progress-calculations/progress_service.dart';
import '../code/shared/models/portfolio_backup.dart';

void main() {
  final PortfolioBackup demo = DemoDataset.build();
  const ProgressService service = ProgressService();
  final ProgressStats stats =
      service.compute(demo.sessions, reference: DemoDataset.defaultAnchor);

  test('weekly counts cover eight weeks', () {
    expect(stats.weeklyCounts.length, 8);
    expect(stats.weeklyCounts.last.isCurrent, isTrue);
  });

  test('totals are derived from the sessions', () {
    expect(stats.totalWorkouts, demo.sessions.length);
    expect(stats.totalSets, greaterThan(0));
    expect(stats.totalMinutes, greaterThan(0));
    expect(stats.avgSessionMinutes, greaterThan(0));
  });

  test('personal bests are ranked heaviest-first', () {
    expect(stats.personalBests, isNotEmpty);
    for (int i = 1; i < stats.personalBests.length; i++) {
      expect(
          stats.personalBests[i - 1].weightKg >=
              stats.personalBests[i].weightKg,
          isTrue);
    }
  });

  test('muscle-group totals are aggregated and sorted', () {
    expect(stats.muscleGroups, isNotEmpty);
    for (int i = 1; i < stats.muscleGroups.length; i++) {
      expect(
          stats.muscleGroups[i - 1].sets >= stats.muscleGroups[i].sets, isTrue);
    }
  });

  test('exercise highlights are computed', () {
    expect(stats.highlights.mostPerformed, isNotNull);
    expect(stats.highlights.mostConsistent, isNotNull);
    // Leg Press has the largest programmed weekly increment in the demo data.
    expect(stats.highlights.mostImproved, 'Leg Press');
    expect(stats.highlights.mostImprovedGainKg, greaterThan(0));
  });

  test('most-used plan and consistency rate are derived', () {
    expect(stats.mostUsedPlan, isNotNull);
    expect(stats.consistencyRate, greaterThan(0));
  });

  test('empty history yields an empty, non-crashing result', () {
    final ProgressStats empty = service.compute(const []);
    expect(empty.isEmpty, isTrue);
    expect(empty.personalBests, isEmpty);
    expect(empty.totalSets, 0);
  });

  test('PersonalBestCalculator keeps the heaviest set per exercise', () {
    const calc = PersonalBestCalculator();
    final bests = calc.calculate(demo.sessions);
    final ids = bests.map((b) => b.exerciseId).toList();
    expect(ids.toSet().length, ids.length); // one entry per exercise
  });
}
