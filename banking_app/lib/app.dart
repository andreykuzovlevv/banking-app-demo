import 'package:banking_app/styles/styles.dart';
import 'package:flutter/material.dart';
import 'screens/screens.dart';
import 'widgets/anim_bottom_nav_bar.dart';

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banking App',
      theme: ThemeData.dark(),
      home: const _NavigationShell(),
    );
  }
}

class _NavigationShell extends StatefulWidget {
  const _NavigationShell();

  @override
  State<_NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<_NavigationShell> {
  int _currentIndex = 0;

  static const _screens = [
    DashboardScreen(),
    CardScreen(),
    AccountsScreen(),
    SavingsScreen(),
  ];

  static const _navItems = [
    AnimatedNavItem(
      title: 'Dashboard',
      lottieAsset: 'assets/lottie_animations/home_white.json',
    ),
    AnimatedNavItem(
      title: 'Card',
      lottieAsset: 'assets/lottie_animations/card_white.json',
    ),
    AnimatedNavItem(
      title: 'Accounts',
      lottieAsset: 'assets/lottie_animations/wallet_white.json',
    ),
    AnimatedNavItem(
      title: 'Savings',
      lottieAsset: 'assets/lottie_animations/piggy_white.json',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: AnimatedBottomNavBar(
        items: _navItems,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
