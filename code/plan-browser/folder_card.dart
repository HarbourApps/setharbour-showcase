import 'package:flutter/material.dart';

import '../shared/ui/app_colours.dart';
import '../shared/ui/surface_card.dart';
import '../shared/models/workout_plan.dart';

/// A folder row in folder view: icon, name and the plan count.
class FolderCard extends StatelessWidget {
  const FolderCard({
    super.key,
    required this.folder,
    required this.planCount,
    required this.onTap,
  });

  final PlanFolder folder;
  final int planCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColours.folder.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.folder_rounded,
                color: AppColours.folder, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              folder.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColours.textPrimary(context),
              ),
            ),
          ),
          Text(
            '$planCount plans',
            style: TextStyle(
              fontSize: 13,
              color: AppColours.textMuted(context),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: AppColours.textMuted(context)),
        ],
      ),
    );
  }
}
