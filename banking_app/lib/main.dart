import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:lottie/lottie.dart';

void main() => runApp(const BankingApp());

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistent Bottom Navigation Bar Demo',
      home: PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: const DashboardScreen(),
            item: ItemConfig(
              // NOTE: icon here is ignored by our custom nav bar;
              // we drive Lottie from the asset list below.
              icon: SizedBox.shrink(),
              title: "Dashboard",
            ),
          ),
          PersistentTabConfig(
            screen: const CardScreen(),
            item: ItemConfig(icon: SizedBox.shrink(), title: "Messages"),
          ),
          PersistentTabConfig(
            screen: const AccountsScreen(),
            item: ItemConfig(icon: SizedBox.shrink(), title: "Accounts"),
          ),
          PersistentTabConfig(
            screen: const SavingsScreen(),
            item: ItemConfig(icon: SizedBox.shrink(), title: "Savings"),
          ),
        ],
        navBarBuilder: (cfg) => AnimatedBottomNavBar(
          navBarConfig: cfg,
          // Provide one asset per item, in order:
          lottieAssets: const [
            'assets/lottie_animations/home.json',
            'assets/lottie_animations/card.json',
            'assets/lottie_animations/wallet.json',
            'assets/lottie_animations/piggy.json',
          ],
        ),
      ),
    );
  }
}

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
  late final List<AnimationController> _lottieControllers;
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
    // If onLoaded hasn’t run yet, fall back to a sensible duration.
    final duration = c.duration ?? const Duration(milliseconds: 900);
    try {
      await c.animateTo(1.0, duration: duration);
    } finally {
      // Reset to 0 so next tap starts from the first frame.
      c.value = 0.0;
    }
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
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressedIndex = i),
            onTapCancel: () => setState(() => _pressedIndex = null),
            onTapUp: (_) => setState(() => _pressedIndex = null),
            onTap: () {
              _playOnce(i); // play Lottie 0→1 only on tap
              widget.navBarConfig.onItemSelected(i);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: bottomPadding),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: _pressedIndex == i ? 0.92 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with per-state opacity
                    Opacity(
                      opacity: isSelected ? 1.0 : 0.5,
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: Lottie.asset(
                          widget.lottieAssets[i],
                          controller: _lottieControllers[i],
                          // No auto play, no repeat — controller drives it.
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
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        // Match icon dimming: 1.0 when selected, 0.5 otherwise.
                        color: Colors.black.withValues(
                          alpha: isSelected ? 1.0 : 0.5,
                        ),
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext c) => const Center(child: Text("Dashboard Screen"));
}

class CardScreen extends StatelessWidget {
  const CardScreen({super.key});
  @override
  Widget build(BuildContext c) => const Center(child: Text("Messages Screen"));
}

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});
  @override
  Widget build(BuildContext c) => const Center(child: Text("Accounts Screen"));
}

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});
  @override
  Widget build(BuildContext c) => const Center(child: Text("Savings Screen"));
}
