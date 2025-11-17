import 'package:flutter/material.dart';

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = 0.9,
    this.brightnessDelta = 0.3, // 0..1
    this.duration = const Duration(milliseconds: 110),
    this.curve = Curves.easeOut,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final double brightnessDelta;
  final Duration duration;
  final Curve curve;
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
    final overlayOpacity = _pressed ? widget.brightnessDelta : 0.0;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: widget.curve,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            if (widget.brightnessDelta > 0)
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: overlayOpacity,
                  duration: widget.duration,
                  curve: widget.curve,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
