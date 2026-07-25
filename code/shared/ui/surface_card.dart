import 'package:flutter/material.dart';

import 'app_colours.dart';

/// The standard rounded card surface used across every screen.
///
/// Centralising it keeps card radius, border and background consistent app-wide
/// — a deliberate UI decision so the dashboard, plans, history and progress
/// screens all feel like one product.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.selected = false,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool selected;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: selected
            ? AppColours.cardSelected(context)
            : AppColours.cardBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ??
              (selected ? AppColours.accent : AppColours.cardBorder(context)),
        ),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
      ),
    );
  }
}
