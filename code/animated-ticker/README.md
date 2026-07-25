# Animated LED status ticker

**Related screenshot:** [`../../screenshots/animated-status-ticker.png`](../../screenshots/animated-status-ticker.png)
(also visible at the top of [`home-dashboard.png`](../../screenshots/home-dashboard.png))

## The problem

The home dashboard needs to surface several short, timely messages ("20 workout
plans set up and ready", "4 workouts logged this week", "your latest backup is
ready to export") in a small amount of space, in a way that feels premium and
on-brand — without dropping frames or leaking animation controllers.

## The design approach

A single self-contained widget, `AnimatedStatusTicker`, that takes a plain list
of strings and needs no knowledge of the dashboard or app state:

```dart
AnimatedStatusTicker(
  messages: const [
    '20 workout plans set up and ready.',
    '4 workouts logged this week.',
    'Your latest backup is ready to export.',
  ],
)
```

- A `SweepGradient` rotated by an `AnimationController` produces the sweeping
  **gold border glow**.
- Messages **cross-fade** on a timer (`AnimatedSwitcher`).
- `ScrollingLedMessage` renders each message LED-style and **scrolls it
  horizontally only when it overflows**, measuring with a `TextPainter`.
- A coloured left indicator bar reflects the message category.

## Included files

| File | Role |
|---|---|
| `animated_status_ticker.dart` | The public, reusable widget (border glow, rotation, message cycling). |
| `scrolling_led_message.dart` | Internal LED-text component with an overflow-only marquee. |
| [`../shared/ui/app_colours.dart`](../shared/ui/app_colours.dart) | Shared palette dependency (gold/accent colours). |

## Main technical decisions

- **Self-contained & reusable:** the widget depends only on a `List<String>`, so
  it can be dropped anywhere and unit-reasoned about in isolation.
- **Correct disposal:** the border `AnimationController`, the rotation `Timer`
  and the marquee controller are all cancelled/disposed in `dispose()`.
- **Reduced-motion fallback:** when `MediaQuery.disableAnimations` is set, the
  border stops rotating and the text stops scrolling — the panel still shows each
  message, so the feature degrades gracefully and accessibly.
- **Overflow-aware text:** short messages render statically; only long ones tick
  across, avoiding pointless motion.
