import 'package:flutter/material.dart';

import '../shared/ui/app_colours.dart';
import '../shared/models/workout_plan.dart';
import 'plan_browser_controller.dart';

/// Category + difficulty filter chip rows for list view.
class PlanFilterChips extends StatelessWidget {
  const PlanFilterChips({super.key, required this.controller});

  final PlanBrowserController controller;

  static const List<PlanCategory> _categories = [
    PlanCategory.fullBody,
    PlanCategory.push,
    PlanCategory.pull,
    PlanCategory.legs,
    PlanCategory.upper,
    PlanCategory.lower,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(
                context,
                label: 'All',
                selected: controller.category == null,
                onTap: () => controller.setCategory(null),
                accent: AppColours.accent,
              ),
              for (final c in _categories)
                _chip(
                  context,
                  label: c.label,
                  selected: controller.category == c,
                  onTap: () => controller.setCategory(c),
                  accent: AppColours.accent,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _chip(
                context,
                label: 'All levels',
                selected: controller.difficulty == null,
                onTap: () => controller.setDifficulty(null),
                accent: AppColours.warning,
              ),
              for (final d in Difficulty.values)
                _chip(
                  context,
                  label: d.label,
                  selected: controller.difficulty == d,
                  onTap: () => controller.setDifficulty(d),
                  accent: AppColours.warning,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.18)
                : AppColours.cardBg(context),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent : AppColours.cardBorder(context),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? accent : AppColours.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}
