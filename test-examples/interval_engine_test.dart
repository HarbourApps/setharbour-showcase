import 'package:flutter_test/flutter_test.dart';
import '../code/interval-engine/interval_engine.dart';
import '../code/shared/models/interval_plan.dart';

// Small deterministic plan: 1s prepare, 2s work, 1s rest, 2 rounds.
const IntervalPlan plan = IntervalPlan(
  id: 'ip',
  name: 'Test',
  workSeconds: 2,
  restSeconds: 1,
  rounds: 2,
  prepareSeconds: 1,
);

IntervalEngine make() => IntervalEngine(plan, useRealClock: false);

void main() {
  test('starts in the get-ready state', () {
    final e = make()..start();
    expect(e.phase, IntervalPhase.getReady);
    expect(e.secondsRemaining, 1);
    e.dispose();
  });

  test('transitions get-ready → work → rest → next round → done', () {
    final e = make()..start();
    e.advance(); // prepare elapses -> work, round 1
    expect(e.phase, IntervalPhase.work);
    expect(e.currentRound, 1);

    e.advance(); // 1s of work
    e.advance(); // work elapses -> rest
    expect(e.phase, IntervalPhase.rest);

    e.advance(); // rest elapses -> round 2 work
    expect(e.phase, IntervalPhase.work);
    expect(e.currentRound, 2);

    e.advance();
    e.advance(); // work elapses -> rest (last round)
    expect(e.phase, IntervalPhase.rest);
    e.advance(); // rest elapses -> done
    expect(e.phase, IntervalPhase.done);
    expect(e.isFinished, isTrue);
    e.dispose();
  });

  test('pause stops progress and resume continues it', () {
    final e = make()..start();
    e.advance(); // -> work
    e.pause();
    expect(e.isRunning, isFalse);
    final int before = e.secondsRemaining;
    e.advance(); // ignored while paused
    expect(e.secondsRemaining, before);
    e.resume();
    expect(e.isRunning, isTrue);
    e.advance();
    expect(e.secondsRemaining, before - 1);
    e.dispose();
  });

  test('nextRound advances to the next round work phase', () {
    final e = make()..start();
    e.advance(); // work round 1
    e.nextRound();
    expect(e.currentRound, 2);
    expect(e.phase, IntervalPhase.work);
    e.dispose();
  });

  test('previousRound steps back a round', () {
    final e = make()..start();
    e.advance();
    e.nextRound(); // round 2
    e.previousRound(); // back to round 1
    expect(e.currentRound, 1);
    expect(e.phase, IntervalPhase.work);
    e.dispose();
  });

  test('nextRound on the final round finishes the workout', () {
    final e = make()..start();
    e.advance(); // work round 1
    e.nextRound(); // round 2
    e.nextRound(); // no more rounds -> done
    expect(e.isFinished, isTrue);
    e.dispose();
  });

  test('dispose cancels any active timer', () {
    final e = IntervalEngine(plan)..start();
    expect(e.hasActiveTimer, isTrue);
    e.dispose();
    expect(e.hasActiveTimer, isFalse);
  });

  test('repeated start()/resume() never stacks duplicate timers', () {
    final e = IntervalEngine(plan)..start();
    e.start();
    e.resume();
    expect(e.timersCreated, 1);
    e.dispose();
  });
}
