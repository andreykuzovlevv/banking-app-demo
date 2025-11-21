import 'dart:ui';

import 'package:banking_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedNavItem {
  final String title;
  final String lottieAsset;

  const AnimatedNavItem({required this.title, required this.lottieAsset});
}

class AnimatedBottomNavBar extends StatefulWidget {
  final List<AnimatedNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AnimatedBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : assert(items.length > 1, 'Provide at least two nav items');

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
    _initControllers();
  }

  @override
  void didUpdateWidget(covariant AnimatedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      for (final controller in _lottieControllers) {
        controller.dispose();
      }
      _initControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _lottieControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllers() {
    _lottieControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(vsync: this),
    );
  }

  Future<void> _playOnce(int index) async {
    final c = _lottieControllers[index];

    await c.animateTo(1.0);
    c.value = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final selected = widget.selectedIndex;

    return Container(
      decoration: BoxDecoration(),
      height: Styles.bottomNavBarHeight + bottomPadding + 4,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: AppColors.background.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (i) {
              final item = widget.items[i];
              final isSelected = i == selected;

              return GestureDetector(
                onTapDown: (_) => setState(() => _pressedIndex = i),
                onTapCancel: () => setState(() => _pressedIndex = null),
                onTapUp: (_) => setState(() => _pressedIndex = null),
                onTap: () {
                  if (selected != i) {
                    _playOnce(i); // play Lottie 0→1 only on tap
                    widget.onItemSelected(i);
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
                          opacity: isSelected ? 0.9 : 0.54,
                          child: SizedBox(
                            height: Styles.bottomNavBarIconSize,
                            width: Styles.bottomNavBarIconSize,
                            child: Lottie.asset(
                              item.lottieAsset,
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
                          item.title,
                          maxLines: 1,
                          style: Styles.bottomNavBarTextStyle.apply(
                            color: isSelected ? null : AppColors.inactive,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
