import 'package:flutter/material.dart';

import '../shared/ui/app_colours.dart';
import '../shared/models/workout_plan.dart';

/// A plan row in list view: accent bar, name, category/difficulty chips,
/// a "Preset" badge and an exercise/duration caption.
class PlanListCard extends StatelessWidget {
  const PlanListCard({super.key, required this.plan, this.onTap});

  final WorkoutPlan plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = _categoryColour(plan.category);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: AppColours.cardBg(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColours.cardBorder(context)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(Icons.grid_view_rounded, size: 18, color: accent),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColours.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _chip(context, plan.category.label, accent, true),
                            _chip(context, plan.difficulty.label,
                                AppColours.textMuted(context), false),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${plan.exerciseCount} exercises · ${plan.estimatedMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColours.textMuted(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColours.chipBg(context),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColours.cardBorder(context)),
                    ),
                    child: Text(
                      plan.isPreset ? 'Preset' : 'Custom',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColours.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String text, Color colour, bool filled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? colour.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled
              ? colour.withValues(alpha: 0.4)
              : AppColours.cardBorder(context),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: filled ? colour : AppColours.textSecondary(context),
        ),
      ),
    );
  }

  Color _categoryColour(PlanCategory category) {
    switch (category) {
      case PlanCategory.fullBody:
        return AppColours.accent;
      case PlanCategory.push:
        return AppColours.warning;
      case PlanCategory.pull:
        return AppColours.success;
      case PlanCategory.legs:
        return AppColours.statPurple;
      case PlanCategory.upper:
        return AppColours.accentDeep;
      case PlanCategory.lower:
        return AppColours.intervalRest;
      case PlanCategory.other:
        return const Color(0xFF8899AA);
    }
  }
}
