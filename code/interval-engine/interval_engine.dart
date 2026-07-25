import 'dart:async';

import 'package:flutter/foundation.dart';

import '../shared/models/interval_plan.dart';
import '../shared/models/workout_session.dart';

/// The phase of an interval workout.
enum IntervalPhase { idle, getReady, work, rest, done }

/// A deterministic interval-timer state machine.
///
/// The clock and the logic are separated: [advance] applies exactly one second
/// of progress and is what the tests drive directly, while a `Timer.periodic`
/// merely calls [advance] once per second in the running app. This keeps the
/// transitions unit-testable without any real waiting, and guarantees the same
/// sequence of states every run.
///
/// Timer safety: only one periodic timer can exist at a time ([start]/[resume]
/// never stack a second one), and [dispose] always cancels it.
class IntervalEngine extends ChangeNotifier {
  IntervalEngine(this.plan, {this.useRealClock = true});

  final IntervalPlan plan;

  /// When false (tests), no real `Timer` is created; call [advance] manually.
  final bool useRealClock;

  Timer? _timer;
  IntervalPhase _phase = IntervalPhase.idle;
  int _currentRound = 0; // 1-based once work begins
  int _secondsRemaining = 0;
  bool _running = false;

  /// Number of real periodic timers created — used by tests to prove that
  /// repeated [start]/[resume] calls never stack duplicate timers.
  int timersCreated = 0;

  IntervalPhase get phase => _phase;
  int get currentRound => _currentRound;
  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _running;
  bool get isFinished => _phase == IntervalPhase.done;
  int get totalRounds => plan.rounds;

  @visibleForTesting
  bool get hasActiveTimer => _timer != null;

  /// Starts (or restarts) the workout from the beginning.
  void start() {
    _enterInitialPhase();
    _running = true;
    _ensureTimer();
    notifyListeners();
  }

  void pause() {
    if (!_running) return;
    _running = false;
    _cancelTimer();
    notifyListeners();
  }

  void resume() {
    if (_phase == IntervalPhase.idle || _phase == IntervalPhase.done) return;
    if (_running) return;
    _running = true;
    _ensureTimer();
    notifyListeners();
  }

  /// Skips ahead to the work phase of the next round (or finishes).
  void nextRound() {
    if (_phase == IntervalPhase.idle) return;
    if (_currentRound >= plan.rounds) {
      _finish();
    } else {
      _currentRound = (_currentRound + 1).clamp(1, plan.rounds);
      _phase = IntervalPhase.work;
      _secondsRemaining = plan.workSeconds;
    }
    notifyListeners();
  }

  /// Jumps back to the work phase of the previous round.
  void previousRound() {
    if (_phase == IntervalPhase.idle) return;
    _currentRound = (_currentRound - 1).clamp(1, plan.rounds);
    _phase = IntervalPhase.work;
    _secondsRemaining = plan.workSeconds;
    notifyListeners();
  }

  /// Applies one second of progress. Public so tests can advance the clock
  /// deterministically; the periodic timer calls this in the live app.
  void advance() {
    if (!_running ||
        _phase == IntervalPhase.idle ||
        _phase == IntervalPhase.done) {
      return;
    }
    _secondsRemaining -= 1;
    if (_secondsRemaining > 0) {
      notifyListeners();
      return;
    }
    _transitionToNextPhase();
    notifyListeners();
  }

  /// A completion summary for feeding into the history/insight layer.
  IntervalSessionSummary buildSummary() {
    final int completedRounds = _phase == IntervalPhase.done
        ? plan.rounds
        : (_currentRound - 1).clamp(0, plan.rounds);
    final int completedWork =
        _phase == IntervalPhase.done ? plan.intervals : completedRounds;
    return IntervalSessionSummary(
      plannedWorkIntervals: plan.intervals,
      completedWorkIntervals: completedWork,
      totalRounds: plan.rounds,
      completedRounds: completedRounds,
      plannedSeconds: plan.bodySeconds,
      completedSeconds:
          (plan.bodySeconds * completedWork / plan.intervals).round(),
    );
  }

  // ── Internal transitions ─────────────────────────────────────────────────

  void _enterInitialPhase() {
    if (plan.prepareSeconds > 0) {
      _phase = IntervalPhase.getReady;
      _secondsRemaining = plan.prepareSeconds;
      _currentRound = 0;
    } else {
      _phase = IntervalPhase.work;
      _currentRound = 1;
      _secondsRemaining = plan.workSeconds;
    }
  }

  void _transitionToNextPhase() {
    switch (_phase) {
      case IntervalPhase.getReady:
        _phase = IntervalPhase.work;
        _currentRound = 1;
        _secondsRemaining = plan.workSeconds;
        break;
      case IntervalPhase.work:
        if (plan.restSeconds > 0) {
          _phase = IntervalPhase.rest;
          _secondsRemaining = plan.restSeconds;
        } else {
          _advanceRoundOrFinish();
        }
        break;
      case IntervalPhase.rest:
        _advanceRoundOrFinish();
        break;
      case IntervalPhase.idle:
      case IntervalPhase.done:
        break;
    }
  }

  void _advanceRoundOrFinish() {
    if (_currentRound < plan.rounds) {
      _currentRound += 1;
      _phase = IntervalPhase.work;
      _secondsRemaining = plan.workSeconds;
    } else {
      _finish();
    }
  }

  void _finish() {
    _phase = IntervalPhase.done;
    _secondsRemaining = 0;
    _running = false;
    _cancelTimer();
  }

  void _ensureTimer() {
    if (!useRealClock) return;
    // The null-guard is the duplicate-timer protection: a second start()/
    // resume() reuses the existing timer instead of creating another.
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => advance());
    timersCreated += 1;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
