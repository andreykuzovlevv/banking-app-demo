import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class AnimatedBottomNavBar extends StatefulWidget {
  final NavBarConfig navBarConfig;
  final List<String> lottieAssets;

  const AnimatedBottomNavBar({
    super.key,
    required this.navBarConfig,
    required this.lottieAssets,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with TickerProviderStateMixin {
  List<AnimationController> _lottieControllers = [];
  int? _pressedIndex; // for press scale animation

  @override
  void initState() {
    super.initState();
    assert(
      widget.lottieAssets.length == widget.navBarConfig.items.length,
      'lottieAssets length must match number of items',
    );
    _lottieControllers = List.generate(
      widget.lottieAssets.length,
      (_) => AnimationController(vsync: this),
    );
  }

  @override
  void dispose() {
    for (final c in _lottieControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _playOnce(int index) async {
    final c = _lottieControllers[index];

    await c.animateTo(1.0);
    c.value = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final selected = widget.navBarConfig.selectedIndex;

    return SizedBox(
      height: 50 + bottomPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(widget.navBarConfig.items.length, (i) {
          final item = widget.navBarConfig.items[i];
          final isSelected = i == selected;

          return GestureDetector(
            onTapDown: (_) => setState(() => _pressedIndex = i),
            onTapCancel: () => setState(() => _pressedIndex = null),
            onTapUp: (_) => setState(() => _pressedIndex = null),
            onTap: () {
              if (selected != i) {
                _playOnce(i); // play Lottie 0→1 only on tap
                widget.navBarConfig.onItemSelected(i);
              }
            },
            child: Container(
              width: 60,
              margin: EdgeInsets.only(bottom: bottomPadding),
              color: Colors.transparent,
              child: AnimatedScale(
                scale: _pressedIndex == i ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with per-state opacity
                    Opacity(
                      opacity: isSelected ? 1.0 : 0.54,
                      child: SizedBox(
                        height: 32,
                        width: 32,
                        child: Lottie.asset(
                          widget.lottieAssets[i],
                          controller: _lottieControllers[i],
                          repeat: false,
                          animate: false,
                          onLoaded: (composition) {
                            // Use the real comp duration; keep progress at 0.
                            _lottieControllers[i].duration =
                                composition.duration;
                            _lottieControllers[i].value = 0.0;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title ?? '',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
