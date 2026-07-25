# Validation & error handling

How SetHarbour keeps bad numbers out of your workout history without getting in
your way.

## Numeric-input constraints

Two numeric fields are logged per set:

- **Reps** — a whole number.
- **Weight (kg)** — a number with up to one decimal place.

Both are entered through a custom on-screen keypad, so the app fully controls
what can be typed. The rules live in one pure class,
`core/validation/NumericInputValidator`:

- Whole-number portion: **maximum three digits**.
- Weight: **at most one digit after the decimal point**.
- Reps: **no decimal point**.
- Empty is allowed (a set can simply have no data yet).

## The three-digit rule

Three digits (up to 999) comfortably covers any realistic rep count or kilogram
load. Capping there keeps the big on-screen numbers tidy and, more importantly,
stops obviously-wrong entries (a slipped extra digit turning 150 into 1500) from
ever reaching your history.

## The Superman validation message

When you try to type a fourth whole digit, the app surfaces:

> **This app is not made for Superman — only 3 digits maximum 🦸**

The exact string is a single source-of-truth constant,
`kSupermanValidationMessage`, kept **separate from the rule** that triggers it.
That separation means the wording and the logic can each change independently,
and the wording can be asserted in tests without reaching into UI code.

## Why the message combines validation with product personality

A limit delivered coldly ("Error: maximum 3 digits") is forgettable and a little
hostile. Delivered with a wink, the same hard rule becomes a small moment of
brand character that users remember fondly. It is intentional, finished copy —
documented here so it is never mistaken for a placeholder and "corrected" into
something blander.

## Why input is rejected rather than silently altered

When a keystroke would break a rule, the validator returns the **previous value
unchanged** and flags the rejection. It never truncates. Silent truncation is
dangerous: it would write a plausible-but-wrong number ("150" instead of the
"1500" you fat-fingered) into your permanent history with no signal that
anything happened. A visible, momentary rejection is safer and clearer.

The one exception is a *second* decimal place, which is simply ignored with no
banner — matching production behaviour, where the extra key just does nothing.

## How invalid values are prevented from entering workout history

Because entry goes exclusively through the keypad + validator, an out-of-range
value can never be constructed in the first place. By the time reps/weight are
committed to a `LoggedSet`, they have already passed the rule. There is also a
`validate(String)` method for defensively checking a completed/restored value,
which returns the same branded message for an over-long number.

## How errors remain recoverable

Nothing about a rejection is destructive: the field keeps its last good value,
the warning banner has an **OK** dismiss action, and the user can immediately
backspace or continue. A rejected keystroke never crashes, clears the field or
loses prior input.

## Tests covering validation behaviour

[`../test-examples/numeric_input_validator_test.dart`](../test-examples/numeric_input_validator_test.dart)
asserts, among others:

- valid reps and weights are accepted; a three-digit weight is accepted;
- a fourth whole digit is rejected **with the exact Superman message**;
- excessive digits are **not silently truncated** (value unchanged);
- empty values are handled safely;
- decimals follow the same whole-number rule (`77.5` valid, `77.55` invalid);
- the message constant equals the exact branded string, verbatim.

In the complete application, a widget test additionally drives the real keypad
UI (pressing a fourth digit surfaces the Superman banner, the previous value
survives, and the screen does not crash); that screen-level test is not part of
this review excerpt.
