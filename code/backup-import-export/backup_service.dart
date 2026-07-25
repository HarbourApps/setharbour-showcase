import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../shared/models/exercise.dart';
import '../shared/models/interval_plan.dart';
import '../shared/models/portfolio_backup.dart';
import '../shared/models/workout_plan.dart';
import '../shared/models/workout_session.dart';

/// Raised when an imported document is not a usable SetHarbour backup.
class BackupImportException implements Exception {
  const BackupImportException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Local, offline JSON backup: serialise, validate, merge, share and import.
///
/// The pure methods ([encode], [decode], [merge]) contain the interesting
/// logic and are fully unit-tested. The IO methods ([exportAndShare],
/// [pickAndImport]) wrap the platform plugins and are deliberately thin. No
/// network is involved at any point — the OS share sheet and file picker keep
/// the user in control of where data goes.
class BackupService {
  const BackupService();

  // ── Pure logic ─────────────────────────────────────────────────────────

  /// Serialises a backup to pretty-printed JSON.
  static String encode(PortfolioBackup backup) =>
      const JsonEncoder.withIndent('  ').convert(backup.toJson());

  /// Parses and validates a backup document.
  ///
  /// Throws [BackupImportException] for malformed JSON, a wrong/missing app
  /// marker, a missing version, or an unsupported (newer) schema version.
  static PortfolioBackup decode(String raw) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const BackupImportException(
        'This file is not valid JSON — it may be corrupt.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const BackupImportException(
        'This file does not look like a SetHarbour backup.',
      );
    }

    if (decoded['app'] != PortfolioBackup.appTag) {
      throw const BackupImportException(
        'This file does not appear to be a SetHarbour backup.',
      );
    }

    final Object? version = decoded['version'];
    if (version is! int) {
      throw const BackupImportException(
        'This backup is missing its version and cannot be read.',
      );
    }
    if (version > PortfolioBackup.currentVersion) {
      throw BackupImportException(
        'This backup was made by a newer version of SetHarbour '
        '(v$version). Please update the app to import it.',
      );
    }

    try {
      return PortfolioBackup.fromJson(decoded);
    } catch (_) {
      // Any structural problem inside a field is treated as malformed rather
      // than crashing the caller.
      throw const BackupImportException(
        'This backup is missing required fields or is malformed.',
      );
    }
  }

  /// Merges [incoming] into [base] without losing on-device data.
  ///
  /// Entities are matched by id: existing ones are preserved, genuinely new
  /// ones are appended. This makes import idempotent — importing the same file
  /// twice changes nothing.
  static PortfolioBackup merge(PortfolioBackup base, PortfolioBackup incoming) {
    List<T> mergeById<T>(
      List<T> a,
      List<T> b,
      String Function(T) idOf,
    ) {
      final Set<String> seen = a.map(idOf).toSet();
      return [
        ...a,
        ...b.where((item) => !seen.contains(idOf(item))),
      ];
    }

    return PortfolioBackup(
      version: PortfolioBackup.currentVersion,
      exportedAt: incoming.exportedAt,
      exercises:
          mergeById<Exercise>(base.exercises, incoming.exercises, (e) => e.id),
      folders:
          mergeById<PlanFolder>(base.folders, incoming.folders, (f) => f.id),
      plans: mergeById<WorkoutPlan>(base.plans, incoming.plans, (p) => p.id),
      intervalPlans: mergeById<IntervalPlan>(
          base.intervalPlans, incoming.intervalPlans, (p) => p.id),
      sessions: mergeById<WorkoutSession>(
          base.sessions, incoming.sessions, (s) => s.id),
    );
  }

  // ── IO wrappers ────────────────────────────────────────────────────────

  /// Writes the backup to a temporary file and opens the system share sheet.
  /// No storage permission is required — the OS owns the share flow.
  /// Returns the temporary file path that was shared.
  Future<String> exportAndShare(PortfolioBackup backup) async {
    final String json = encode(backup);
    final Directory dir = await getTemporaryDirectory();
    final String dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final File file = File('${dir.path}/setharbour_export_$dateStr.json');
    await file.writeAsString(json);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'SetHarbour backup — $dateStr',
    );
    return file.path;
  }

  /// Opens the system file picker and imports the chosen JSON backup.
  /// Returns `null` if the user cancels. Throws [BackupImportException] if the
  /// selected file is not a valid backup.
  Future<PortfolioBackup?> pickAndImport() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final String? path = result.files.single.path;
    if (path == null) return null;
    final String raw = await File(path).readAsString();
    return decode(raw);
  }
}
