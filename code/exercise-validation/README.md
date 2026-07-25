# Exercise input validation (+ the Superman message)

**Related screenshot:** [`../../screenshots/exercise-input-validation.png`](../../screenshots/exercise-input-validation.png)

## The problem

Mid-workout, users enter reps and weight fast and glance away. Bad input (a
slipped fourth digit turning `150` into `1500`) must never reach the workout
history — but validation must be instant and must never crash, block the flow,
or silently "fix" a value behind the user's back.

## The design approach

A pure, UI-independent rule object, `NumericInputValidator`, feeds every keypress
from the custom `NumericKeypad`. The rule:

- whole-number portion: **max three digits**;
- weight: **at most one decimal place**;
- reps: **no decimal point**;
- empty is allowed.

When a keypress would break the rule, the validator returns the **previous value
unchanged** and flags the rejection. For the three-digit limit it also returns
the branded message so the UI can surface a banner.

## The Superman message

The exact, intentional branded copy — preserved verbatim — lives in its own
constant, deliberately **separate** from the rule that triggers it:

> **This app is not made for Superman — only 3 digits maximum 🦸**

Keeping wording and logic apart means either can change independently, and the
string can be asserted in tests without touching UI code. It is finished product
copy, not a placeholder.

## Included files

| File | Role |
|---|---|
| `numeric_input_validator.dart` | The pure rule: `applyDigit` / `applyDecimalPoint` / `backspace` / `validate`. |
| `validation_messages.dart` | The single source-of-truth Superman string constant. |
| `numeric_keypad.dart` | The reusable custom keypad widget that routes presses through the validator. |
| [`../shared/ui/app_colours.dart`](../shared/ui/app_colours.dart) | Shared palette dependency. |

## Main technical decisions

- **Reject, never truncate:** on a rule break the field keeps its last good
  value; `1500` never becomes `150`, so a wrong number can't slip into history.
- **Rule ≠ wording:** the message is a constant; the validator only *decides*.
- **Pure and testable:** the validator has no `BuildContext` and is covered
  exhaustively in [`../../test-examples/numeric_input_validator_test.dart`](../../test-examples/numeric_input_validator_test.dart),
  including a verbatim check of the Superman string.
- **Recoverable errors:** rejections are non-destructive and dismissible; the
  user can backspace or continue immediately.
