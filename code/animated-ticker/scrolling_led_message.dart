import 'package:flutter/material.dart';

/// LED-style message text that scrolls horizontally when it overflows.
///
/// Short messages render statically; long ones tick across in a continuous
/// marquee. The [AnimationController] is created lazily and always disposed.
/// When the platform requests reduced motion, scrolling is disabled and the
/// text simply wraps — the LED styling is preserved either way.
class ScrollingLedMessage extends StatefulWidget {
  const ScrollingLedMessage({
    super.key,
    required this.message,
    required this.accent,
    this.reduceMotion = false,
  });

  final String message;
  final Color accent;
  final bool reduceMotion;

  @override
  State<ScrollingLedMessage> createState() => _ScrollingLedMessageState();
}

class _ScrollingLedMessageState extends State<ScrollingLedMessage>
    with SingleTickerProviderStateMixin {
  static const double _pixelsPerSecond = 34.0;
  static const double _gap = 48.0;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle _style() => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.16,
        letterSpacing: 0.7,
        color: const Color(0xFFE8FBFF),
        fontFamilyFallback: const [
          'RobotoMono',
          'Menlo',
          'Courier New',
          'monospace',
        ],
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: [
          Shadow(color: widget.accent.withValues(alpha: 0.35), blurRadius: 6),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final TextStyle style = _style();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: widget.accent.withValues(alpha: 0.92),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = constraints.maxWidth;
              final double textWidth =
                  _measure(widget.message, style, maxWidth);
              final bool overflows = textWidth > maxWidth + 0.5;

              if (widget.reduceMotion || !overflows) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.message,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                );
              }
              return _buildMarquee(widget.message, style, textWidth);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarquee(String message, TextStyle style, double textWidth) {
    final double travel = textWidth + _gap;
    final Duration duration =
        Duration(milliseconds: (travel / _pixelsPerSecond * 1000).round());
    if (_controller.duration != duration) {
      _controller
        ..stop()
        ..duration = duration
        ..repeat();
    }

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(-travel * _controller.value, 0),
            child: child,
          );
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, maxLines: 1, style: style),
              const SizedBox(width: _gap),
              Text(message, maxLines: 1, style: style),
            ],
          ),
        ),
      ),
    );
  }

  double _measure(String text, TextStyle style, double maxWidth) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }
}
