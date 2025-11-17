import 'package:banking_app/screens/dashboard/dashboard.dart';
import 'package:flutter/cupertino.dart';

class ToggleModesButton extends StatefulWidget {
  const ToggleModesButton({
    super.key,
    required this.backgroundColor,
    required this.size,
    this.onModeChanged,
  });

  final Color backgroundColor;
  final double size;
  final ValueChanged<ViewMode>? onModeChanged;

  @override
  State<ToggleModesButton> createState() => _ToggleModesButtonState();
}

class _ToggleModesButtonState extends State<ToggleModesButton>
    with SingleTickerProviderStateMixin {
  static const double _kSlideDistance = 20.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  late final Animation<double> _opacity = TweenSequence<double>([
    // First half: fade out 1 → 0
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    // Second half: fade in 0 → 1
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
  ]).animate(_curvedAnimation);

  late final Animation<double> _offsetX = TweenSequence<double>([
    // First half: center → left
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: _kSlideDistance),
      weight: 1,
    ),
    // Second half: right → center
    TweenSequenceItem(
      tween: Tween(begin: -_kSlideDistance, end: 0.0),
      weight: 1,
    ),
  ]).animate(_curvedAnimation);

  ViewMode _viewMode = ViewMode.currency;

  late IconData _icon = _viewMode.icon;

  // Track whether we already flipped in this run
  bool _hasFlippedThisRun = false;

  // Track animation direction
  bool _isAnimatingForward = true;

  // Track previous value to detect crossing 0.5 threshold
  double _previousValue = 0.0;

  // Track pressed state for scale animation
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final currentValue = _controller.value;

      // At halfway point, toggle mode & icon once
      if (!_hasFlippedThisRun) {
        if (_isAnimatingForward &&
            currentValue >= 0.5 &&
            _previousValue < 0.5) {
          // Forward: crossing 0.5 going up
          setState(() {
            _icon = _viewMode.icon; // switch to new icon
          });
          _hasFlippedThisRun = true;
        } else if (!_isAnimatingForward &&
            currentValue <= 0.5 &&
            _previousValue > 0.5) {
          // Reverse: crossing 0.5 going down
          setState(() {
            _icon = _viewMode.icon; // switch to new icon
          });
          _hasFlippedThisRun = true;
        }
      }

      _previousValue = currentValue;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  void _onTap() {
    // if (_controller.isAnimating) return;
    _hasFlippedThisRun = false;
    _previousValue = _controller.value;

    if (_viewMode == ViewMode.currency) {
      _isAnimatingForward = true;
      _viewMode = _viewMode.opposite;
      _controller.forward();
    } else {
      _isAnimatingForward = false;
      _viewMode = _viewMode.opposite;
      _controller.reverse();
    }
    widget.onModeChanged?.call(_viewMode);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: _onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Container(
          clipBehavior: Clip.antiAlias,
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.backgroundColor,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacity.value,
                  child: Transform.translate(
                    offset: Offset(_offsetX.value, 0),
                    child: Icon(_icon, color: const Color(0xffffffff)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
