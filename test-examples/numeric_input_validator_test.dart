import 'package:flutter_test/flutter_test.dart';
import '../code/exercise-validation/numeric_input_validator.dart';
import '../code/exercise-validation/validation_messages.dart';

void main() {
  const NumericInputValidator validator = NumericInputValidator();

  // The exact, intentional branded copy. Kept verbatim.
  const String supermanMessage =
      'This app is not made for Superman — only 3 digits maximum 🦸';

  group('validation messages', () {
    test('the constant is exactly the branded Superman message', () {
      expect(kSupermanValidationMessage, supermanMessage);
    });
  });

  group('reps (no decimals)', () {
    test('valid reps are accepted', () {
      final KeypadResult r =
          validator.applyDigit(current: '1', digit: '2', allowDecimal: false);
      expect(r.accepted, isTrue);
      expect(r.value, '12');
    });

    test('a third digit is accepted', () {
      final KeypadResult r =
          validator.applyDigit(current: '12', digit: '5', allowDecimal: false);
      expect(r.accepted, isTrue);
      expect(r.value, '125');
    });

    test('a fourth digit is rejected with the Superman message', () {
      final KeypadResult r =
          validator.applyDigit(current: '125', digit: '9', allowDecimal: false);
      expect(r.rejected, isTrue);
      expect(r.supermanMessage, supermanMessage);
    });
  });

  group('weight (decimals allowed)', () {
    test('valid weights are accepted', () {
      final KeypadResult r =
          validator.applyDigit(current: '5', digit: '5', allowDecimal: true);
      expect(r.value, '55');
    });

    test('a three-digit weight is accepted', () {
      final KeypadResult r =
          validator.applyDigit(current: '22', digit: '2', allowDecimal: true);
      expect(r.accepted, isTrue);
      expect(r.value, '222');
    });

    test('a fourth whole digit is rejected with the Superman message', () {
      final KeypadResult r =
          validator.applyDigit(current: '222', digit: '5', allowDecimal: true);
      expect(r.rejected, isTrue);
      expect(r.supermanMessage, supermanMessage);
    });

    test('excessive digits are NOT silently truncated — value is unchanged',
        () {
      final KeypadResult r =
          validator.applyDigit(current: '150', digit: '0', allowDecimal: true);
      // Rejected, and the previous value is returned intact (not "1500", not "150" trimmed).
      expect(r.value, '150');
      expect(r.rejected, isTrue);
    });

    test('one decimal place is allowed', () {
      final KeypadResult withDot =
          validator.applyDecimalPoint(current: '77', allowDecimal: true);
      expect(withDot.value, '77.');
      final KeypadResult withTenth =
          validator.applyDigit(current: '77.', digit: '5', allowDecimal: true);
      expect(withTenth.value, '77.5');
    });

    test('a second decimal digit is ignored (production rule)', () {
      final KeypadResult r =
          validator.applyDigit(current: '77.5', digit: '9', allowDecimal: true);
      expect(r.rejected, isTrue);
      expect(r.value, '77.5');
    });

    test('reps do not accept a decimal point', () {
      final KeypadResult r =
          validator.applyDecimalPoint(current: '10', allowDecimal: false);
      expect(r.rejected, isTrue);
      expect(r.value, '10');
    });
  });

  group('validate(completed value)', () {
    test('empty values are valid (handled safely)', () {
      expect(validator.validate('', allowDecimal: true).isValid, isTrue);
      expect(validator.validate('   ', allowDecimal: false).isValid, isTrue);
    });

    test('three digits are valid', () {
      expect(validator.validate('150', allowDecimal: true).isValid, isTrue);
    });

    test('four digits are invalid and carry the Superman message', () {
      final NumericValidation v =
          validator.validate('1500', allowDecimal: true);
      expect(v.isValid, isFalse);
      expect(v.message, supermanMessage);
    });

    test('decimals follow the same three-digit whole-number rule', () {
      expect(validator.validate('77.5', allowDecimal: true).isValid, isTrue);
      expect(validator.validate('77.55', allowDecimal: true).isValid, isFalse);
    });
  });
}
