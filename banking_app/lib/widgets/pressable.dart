import 'package:flutter/material.dart';

/// Wrap any widget to make it pressable with:
///  - scale down on press
///  - brightness increase on press
///
/// Tuning:
///  - [pressedScale]: target scale while pressed (e.g. 0.94)
///  - [brightnessDelta]: 0..1 additive brightness while pressed (e.g. 0.15)
///  - [duration] & [curve]: press/release animation timing
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.94,
    this.brightnessDelta = 0.15,
    this.duration = const Duration(milliseconds: 110),
    this.curve = Curves.easeOut,
    this.behavior = HitTestBehavior.opaque,
    this.enableHaptic = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final double brightnessDelta; // 0..1 (adds up to 255*delta to RGB)
  final Duration duration;
  final Curve curve;
  final HitTestBehavior behavior;
  final bool enableHaptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    // Press progress: 0 (idle) → 1 (pressed)
    final target = _pressed ? 1.0 : 0.0;

    return Semantics(
      button: widget.onTap != null || widget.onLongPress != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () async {
          if (widget.enableHaptic) {
            // ignore: deprecated_member_use
            Feedback.forTap(context);
          }
          widget.onTap?.call();
        },
        onLongPress: widget.onLongPress,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: target),
          duration: widget.duration,
          curve: widget.curve,
          builder: (context, t, child) {
            final scale = _lerp(1.0, widget.pressedScale, t);
            final brighten = _lerp(
              0.0,
              widget.brightnessDelta.clamp(0.0, 1.0),
              t,
            );

            return Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: _BrightnessFilter(delta: brighten, child: child!),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Simple additive brightness filter using a 5x5 color matrix.
/// [delta] in 0..1 adds up to 255*delta to RGB channels.
class _BrightnessFilter extends StatelessWidget {
  const _BrightnessFilter({required this.delta, required this.child});

  final double delta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (delta <= 0) return child;

    final bias = (255.0 * delta).clamp(0.0, 255.0);
    final List<double> matrix = <double>[
      // R
      1, 0, 0, 0, bias,
      // G
      0, 1, 0, 0, bias,
      // B
      0, 0, 1, 0, bias,
      // A
      0, 0, 0, 1, 0,
    ];

    return ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: child);
  }
}
