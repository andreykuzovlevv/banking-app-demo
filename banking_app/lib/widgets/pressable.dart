import 'package:flutter/material.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.94,
    this.brightnessDelta = 0.3,
    this.duration = const Duration(milliseconds: 110),
    this.curve = Curves.easeOut,
    this.behavior = HitTestBehavior.opaque,
    this.enableHaptic = false,
    this.semanticLabel,
    this.mask, // optional: provide a light mask if child is heavy/stateful
  });

  final Widget child;
  final Widget? mask; // optional mask silhouette; defaults to child
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final double brightnessDelta;
  final Duration duration;
  final Curve curve;
  final HitTestBehavior behavior;
  final bool enableHaptic;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final target = _pressed ? 1.0 : 0.0;

    return Semantics(
      button: widget.onTap != null || widget.onLongPress != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: widget.behavior,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          if (widget.enableHaptic) {
            Feedback.forTap(context);
          }
          widget.onTap?.call();
        },
        onLongPress: widget.onLongPress,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: target),
          duration: widget.duration,
          curve: widget.curve,
          child: widget.child,
          builder: (context, t, baseChild) {
            final scale = _lerp(1.0, widget.pressedScale, t);
            final overlayOpacity = (widget.brightnessDelta.clamp(0.0, 1.0)) * t;

            return Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  baseChild!,
                  if (overlayOpacity > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _AlphaMaskedOverlay(
                          opacity: overlayOpacity,
                          mask: widget.mask ?? baseChild,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Uses the [mask]'s alpha to show a solid white with [opacity].
/// This is equivalent to AE "white solid above" with the masked area equal to the layer's silhouette.
class _AlphaMaskedOverlay extends StatelessWidget {
  const _AlphaMaskedOverlay({required this.opacity, required this.mask});

  final double opacity; // 0..1
  final Widget mask;

  @override
  Widget build(BuildContext context) {
    // We draw a solid white shader, then use the mask widget's alpha to keep only its silhouette.
    return ShaderMask(
      // Solid color shader; the rectangle is updated by layout.
      shaderCallback: (rect) => const LinearGradient(
        colors: [Colors.white, Colors.white],
      ).createShader(rect),
      blendMode: BlendMode.srcATop, // keep shader where mask (child) has alpha
      child: Opacity(
        opacity: opacity,
        // This is the silhouette provider; prefer a lightweight equivalent if the real child is heavy.
        child: mask,
      ),
    );
  }
}
