import 'package:flutter/material.dart';

import '../shared/ui/app_colours.dart';

/// A custom numeric keypad for reps / weight entry.
///
/// Purely presentational: it reports key presses and never mutates values
/// itself, so the validation rules stay in one place (the logger's
/// [NumericInputValidator]). The `.` key is hidden when [allowDecimal] is
/// false (reps).
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.allowDecimal,
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
    required this.onClear,
    required this.onDone,
  });

  final bool allowDecimal;
  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(context, ['7', '8', '9']),
        _row(context, ['4', '5', '6']),
        _row(context, ['1', '2', '3']),
        _row(context, [allowDecimal ? '.' : 'clear', '0', 'back']),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _actionKey(context, 'Clear', onClear,
                  color: AppColours.textSecondary(context)),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _primaryKey(context, 'Done', onDone),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(BuildContext context, List<String> keys) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          for (int i = 0; i < keys.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _key(context, keys[i])),
          ],
        ],
      ),
    );
  }

  Widget _key(BuildContext context, String key) {
    switch (key) {
      case 'back':
        return _iconKey(context, Icons.backspace_outlined, onBackspace);
      case 'clear':
        return _labelKey(context, 'Clear', onClear);
      case '.':
        return _labelKey(context, '.', allowDecimal ? onDecimal : null);
      default:
        return _labelKey(context, key, () => onDigit(key), bold: true);
    }
  }

  Widget _labelKey(BuildContext context, String label, VoidCallback? onTap,
      {bool bold = false}) {
    return _base(
      context,
      onTap,
      Text(
        label,
        style: TextStyle(
          fontSize: bold ? 24 : 18,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          color: AppColours.textPrimary(context),
        ),
      ),
    );
  }

  Widget _iconKey(BuildContext context, IconData icon, VoidCallback onTap) {
    return _base(
        context, onTap, Icon(icon, color: AppColours.textPrimary(context)));
  }

  Widget _actionKey(BuildContext context, String label, VoidCallback onTap,
      {required Color color}) {
    return _base(
      context,
      onTap,
      Text(label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _primaryKey(BuildContext context, String label, VoidCallback onTap) {
    return Material(
      color: AppColours.accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          child: const Text(
            'Done',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF06222F),
            ),
          ),
        ),
      ),
    );
  }

  Widget _base(BuildContext context, VoidCallback? onTap, Widget child) {
    return Material(
      color: AppColours.inputBg(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColours.cardBorder(context)),
          ),
          child: child,
        ),
      ),
    );
  }
}
