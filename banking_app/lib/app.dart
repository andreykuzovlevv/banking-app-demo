import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import 'screens/screens.dart';
import 'widgets/widgets.dart';

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
