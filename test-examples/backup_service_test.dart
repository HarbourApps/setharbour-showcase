import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import '../code/backup-import-export/demo_dataset.dart';
import '../code/backup-import-export/backup_service.dart';
import '../code/shared/models/exercise.dart';
import '../code/shared/models/portfolio_backup.dart';

PortfolioBackup _tiny({List<Exercise> exercises = const []}) => PortfolioBackup(
      exportedAt: DateTime(2026, 7, 25),
      exercises: exercises,
      folders: const [],
      plans: const [],
      intervalPlans: const [],
      sessions: const [],
    );

void main() {
  group('encode / decode round trip', () {
    test('the demo dataset survives export then import', () {
      final PortfolioBackup original = DemoDataset.build();
      final String json = BackupService.encode(original);
      final PortfolioBackup back = BackupService.decode(json);
      expect(back.sessions.length, original.sessions.length);
      expect(back.plans.length, original.plans.length);
    });

    test('synthetic demo data loads successfully via decode', () {
      final String json = BackupService.encode(DemoDataset.build());
      expect(() => BackupService.decode(json), returnsNormally);
    });
  });

  group('validation', () {
    test('malformed JSON is rejected', () {
      expect(() => BackupService.decode('{ not json '),
          throwsA(isA<BackupImportException>()));
    });

    test('a non-SetHarbour file is rejected', () {
      final String json = jsonEncode({'app': 'SomethingElse', 'version': 1});
      expect(() => BackupService.decode(json),
          throwsA(isA<BackupImportException>()));
    });

    test('a missing version is rejected', () {
      final String json = jsonEncode({'app': 'SetHarbour'});
      expect(() => BackupService.decode(json),
          throwsA(isA<BackupImportException>()));
    });

    test('an unsupported (newer) version is rejected', () {
      final String json = jsonEncode({'app': 'SetHarbour', 'version': 999});
      expect(() => BackupService.decode(json),
          throwsA(isA<BackupImportException>()));
    });

    test('unknown optional fields are ignored', () {
      final Map<String, dynamic> map = DemoDataset.build().toJson();
      map['someFutureField'] = {'nested': true};
      final String json = jsonEncode(map);
      expect(() => BackupService.decode(json), returnsNormally);
    });
  });

  group('merge', () {
    test('duplicate ids are not added twice (idempotent import)', () {
      const a = Exercise(id: 'ex1', name: 'Squat', muscleGroup: 'Legs');
      final PortfolioBackup base = _tiny(exercises: const [a]);
      final PortfolioBackup incoming = _tiny(exercises: const [a]);
      final PortfolioBackup merged = BackupService.merge(base, incoming);
      expect(merged.exercises.length, 1);
    });

    test('genuinely new entities are appended', () {
      const a = Exercise(id: 'ex1', name: 'Squat', muscleGroup: 'Legs');
      const b = Exercise(id: 'ex2', name: 'Bench', muscleGroup: 'Chest');
      final PortfolioBackup merged = BackupService.merge(
        _tiny(exercises: const [a]),
        _tiny(exercises: const [b]),
      );
      expect(merged.exercises.map((e) => e.id), containsAll(['ex1', 'ex2']));
      expect(merged.exercises.length, 2);
    });
  });
}
