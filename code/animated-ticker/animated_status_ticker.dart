import 'dart:async';

import 'package:flutter/material.dart';

import '../shared/ui/app_colours.dart';
import 'scrolling_led_message.dart';

/// A reusable, self-contained animated status ticker.
///
/// Visual character (matching SetHarbour): a dark rounded panel, a rotating
/// gold "glow" that sweeps around the border, a coloured left indicator and
/// LED-style monospace text that scrolls when it is too long to fit. Multiple
/// [messages] are rotated on a timer with a soft cross-fade.
///
/// The widget has no dependency on the dashboard or any app state — it takes a
/// plain list of strings:
///
/// ```dart
/// AnimatedStatusTicker(
///   messages: const [
///     '20 workout plans set up and ready.',
///     '4 workouts logged this week.',
///     'Your latest backup is ready to export.',
///   ],
/// )
/// ```
///
/// Both animation controllers/timers are disposed correctly, and when the
/// platform requests reduced motion the border stops spinning and the text
/// stops scrolling while the panel still shows each message.
class AnimatedStatusTicker extends StatefulWidget {
  const AnimatedStatusTicker({
    super.key,
    required this.messages,
    this.rotationInterval = const Duration(seconds: 5),
    this.glowColor = AppColours.goldGlow,
    this.indicatorColors = const [AppColours.accent],
    this.emptyPlaceholder = 'No updates right now.',
  });

  final List<String> messages;

  /// How long each message is shown before rotating to the next.
  final Duration rotationInterval;

  /// The colour of the sweeping border glow.
  final Color glowColor;

  /// Per-message left-indicator colours (cycled). Never empty in practice.
  final List<Color> indicatorColors;

  /// Shown when [messages] is empty.
  final String emptyPlaceholder;

  @override
  State<AnimatedStatusTicker> createState() => _AnimatedStatusTickerState();
}

class _AnimatedStatusTickerState extends State<AnimatedStatusTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _borderController;
  Timer? _rotationTimer;
  int _index = 0;
  int _cycle = 0;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _startRotation();
  }

  @override
  void didUpdateWidget(covariant AnimatedStatusTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages.join('|') != widget.messages.join('|') ||
        oldWidget.rotationInterval != widget.rotationInterval) {
      _index = 0;
      _startRotation();
    }
  }

  void _startRotation() {
    _rotationTimer?.cancel();
    if (widget.messages.length < 2) return;
    _rotationTimer = Timer.periodic(widget.rotationInterval, (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % widget.messages.length;
        _cycle++;
      });
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _borderController.dispose();
    super.dispose();
  }

  Color _indicatorColor() {
    if (widget.indicatorColors.isEmpty) return AppColours.accent;
    return widget.indicatorColors[_index % widget.indicatorColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final String message = widget.messages.isEmpty
        ? widget.emptyPlaceholder
        : widget.messages[_index % widget.messages.length];
    final Color accent = _indicatorColor();

    final Widget panel = _buildPanel(context, message, accent, reduceMotion);

    if (reduceMotion) {
      return _borderContainer(child: panel, rotation: 0, animated: false);
    }
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, _) => _borderContainer(
        child: panel,
        rotation: _borderController.value,
        animated: true,
      ),
    );
  }

  Widget _borderContainer({
    required Widget child,
    required double rotation,
    required bool animated,
  }) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
        gradient: SweepGradient(
          transform: GradientRotation(rotation * 6.28318),
          colors: [
            Colors.transparent,
            Colors.transparent,
            widget.glowColor.withValues(alpha: 0.22),
            widget.glowColor.withValues(alpha: 0.70),
            widget.glowColor.withValues(alpha: 0.24),
            Colors.transparent,
          ],
          stops: const [0.0, 0.54, 0.64, 0.69, 0.75, 1.0],
        ),
      ),
      child: child,
    );
  }

  Widget _buildPanel(
    BuildContext context,
    String message,
    Color accent,
    bool reduceMotion,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: AppColours.cardBg(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.glowColor.withValues(alpha: 0.12),
        ),
      ),
      child: SizedBox(
        height: 48,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: ScrollingLedMessage(
            key: ValueKey('$_index:$message:$_cycle'),
            message: message,
            accent: accent,
            reduceMotion: reduceMotion,
          ),
        ),
      ),
    );
  }
}
