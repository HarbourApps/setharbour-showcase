import 'package:flutter/material.dart';

import '../shared/ui/app_colours.dart';
import 'plan_browser_controller.dart';

/// The Folders / List segmented toggle, with a "long press to set default" hint.
class PlanViewToggle extends StatelessWidget {
  const PlanViewToggle({
    super.key,
    required this.mode,
    required this.onSelect,
    required this.onSetDefault,
  });

  final PlanViewMode mode;
  final ValueChanged<PlanViewMode> onSelect;
  final ValueChanged<PlanViewMode> onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _segment(
            context, PlanViewMode.folders, Icons.folder_outlined, 'Folders'),
        const SizedBox(width: 8),
        _segment(context, PlanViewMode.list, Icons.view_list_outlined, 'List'),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Long press to set default',
            style: TextStyle(
              fontSize: 11,
              color: AppColours.textMuted(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _segment(
    BuildContext context,
    PlanViewMode value,
    IconData icon,
    String label,
  ) {
    final bool selected = mode == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      onLongPress: () {
        onSetDefault(value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label set as the default view.')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColours.accent : AppColours.cardBg(context),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                selected ? AppColours.accent : AppColours.cardBorder(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected
                  ? const Color(0xFF06222F)
                  : AppColours.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? const Color(0xFF06222F)
                    : AppColours.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
