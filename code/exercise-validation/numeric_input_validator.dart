import 'validation_messages.dart';

/// Result of validating a completed numeric field value.
class NumericValidation {
  const NumericValidation({required this.isValid, this.message});

  final bool isValid;

  /// User-facing message when [isValid] is `false`, otherwise `null`.
  final String? message;

  static const NumericValidation valid = NumericValidation(isValid: true);
}

/// Result of feeding a single keypad press through the validator.
///
/// The validator never silently truncates input: if a press would break a
/// rule, [value] is returned unchanged (equal to the previous value) and
/// [rejected] is `true`. When the rejection is the three-digit limit,
/// [supermanMessage] carries the branded copy so the UI can surface it.
class KeypadResult {
  const KeypadResult({
    required this.value,
    required this.rejected,
    this.supermanMessage,
  });

  final String value;
  final bool rejected;
  final String? supermanMessage;

  bool get accepted => !rejected;
}

/// Pure, UI-independent rules for the reps / weight numeric inputs.
///
/// Production SetHarbour caps whole numbers at three digits and weight decimals
/// at a single place. This class holds only the *rule*; the branded rejection
/// wording lives in [kSupermanValidationMessage] so the two can change
/// independently. Being pure and side-effect free, it is directly unit-testable
/// and is exercised both by the on-screen keypad and by the widget tests.
class NumericInputValidator {
  const NumericInputValidator();

  /// Maximum number of digits before the decimal point.
  static const int maxIntegerDigits = 3;

  /// Maximum number of digits after the decimal point (weight only).
  static const int maxDecimalDigits = 1;

  static final RegExp _digit = RegExp(r'^[0-9]$');

  /// Applies a digit keypress to [current].
  ///
  /// [allowDecimal] is `true` for weight inputs and `false` for reps.
  KeypadResult applyDigit({
    required String current,
    required String digit,
    required bool allowDecimal,
  }) {
    if (!_digit.hasMatch(digit)) {
      return KeypadResult(value: current, rejected: true);
    }

    final bool hasDecimal = current.contains('.');

    if (allowDecimal && hasDecimal) {
      final List<String> parts = current.split('.');
      final String decimalPart = parts.length > 1 ? parts[1] : '';
      // Beyond one decimal place is ignored (no branded banner) — matches
      // production behaviour where the extra key simply does nothing.
      if (decimalPart.length >= maxDecimalDigits) {
        return KeypadResult(value: current, rejected: true);
      }
      return KeypadResult(value: current + digit, rejected: false);
    }

    // Whole-number portion (no decimal typed yet).
    final String integerPart = current == '0' ? '' : current;
    if (integerPart.length >= maxIntegerDigits) {
      // The three-digit ceiling — surface the branded message, keep the old
      // value intact (no truncation, no crash).
      return KeypadResult(
        value: current,
        rejected: true,
        supermanMessage: kSupermanValidationMessage,
      );
    }

    // Replace a lone leading zero rather than producing "07".
    final String next = current == '0' ? digit : '$current$digit';
    return KeypadResult(value: next, rejected: false);
  }

  /// Applies a decimal-point keypress. Ignored for reps and for values that
  /// already contain a decimal point.
  KeypadResult applyDecimalPoint({
    required String current,
    required bool allowDecimal,
  }) {
    if (!allowDecimal || current.contains('.')) {
      return KeypadResult(value: current, rejected: true);
    }
    final String next = current.isEmpty ? '0.' : '$current.';
    return KeypadResult(value: next, rejected: false);
  }

  /// Removes the last character.
  KeypadResult backspace(String current) {
    if (current.isEmpty) {
      return KeypadResult(value: current, rejected: true);
    }
    return KeypadResult(
      value: current.substring(0, current.length - 1),
      rejected: false,
    );
  }

  /// Validates a completed field value (e.g. a value pasted or restored).
  ///
  /// Empty values are considered valid — a blank set simply has no data yet.
  NumericValidation validate(String value, {required bool allowDecimal}) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return NumericValidation.valid;

    final RegExp pattern =
        allowDecimal ? RegExp(r'^\d{1,3}(\.\d{0,1})?$') : RegExp(r'^\d{1,3}$');

    if (!pattern.hasMatch(trimmed)) {
      // Distinguish "too many digits" from "not a number" so the branded
      // message is only used where it makes sense.
      final String integerPart = trimmed.split('.').first;
      if (RegExp(r'^\d+$').hasMatch(integerPart) &&
          integerPart.length > maxIntegerDigits) {
        return const NumericValidation(
          isValid: false,
          message: kSupermanValidationMessage,
        );
      }
      return const NumericValidation(
        isValid: false,
        message: 'Enter a valid number.',
      );
    }
    return NumericValidation.valid;
  }
}
