import 'package:banking_app/screens/dashboard/widgets/overview_animated_section.dart';
import 'package:banking_app/screens/dashboard/widgets/overview_toolbar.dart';
import 'package:banking_app/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/widgets.dart';

enum ViewMode {
  currency,
  activity;

  ViewMode get opposite {
    switch (this) {
      case ViewMode.currency:
        return ViewMode.activity;
      case ViewMode.activity:
        return ViewMode.currency;
    }
  }

  IconData get icon {
    switch (this) {
      case ViewMode.currency:
        return CupertinoIcons.chart_bar;
      case ViewMode.activity:
        return CupertinoIcons.clear;
    }
  }
}

enum Currency { crypto, fiat, card, savings }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  ViewMode overviewMode = ViewMode.currency;
  ViewMode? _nextOverviewMode;
  bool isLastForward = true;
  Currency currencyView = Currency.crypto;

  int overviewIndex = 0;

  late final AnimationController overviewTransitionController =
      AnimationController(
        duration: const Duration(milliseconds: 1000),
        value: 0,
        vsync: this,
      );

  @override
  void initState() {
    super.initState();
    overviewTransitionController.addStatusListener(_onOverviewTransitionStatus);
  }

  @override
  void dispose() {
    overviewTransitionController.dispose();
    super.dispose();
  }

  void _toggleCurrencyController(Currency? value) {
    if (value != null) {
      setState(() {
        currencyView = value;
      });
    }
  }

  void _toggleViewMode(ViewMode mode) {
    if (overviewTransitionController.isAnimating) {
      if (isLastForward) {
        overviewTransitionController.reverse();
        isLastForward = false;
      } else {
        overviewTransitionController.forward();
        isLastForward = true;
      }
      return;
    }

    if (mode == overviewMode) {
      return;
    }

    setState(() {
      _nextOverviewMode = mode;
    });
    overviewTransitionController.forward(from: 0);
    isLastForward = true;
  }

  void _onOverviewTransitionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (_nextOverviewMode != null) {
          overviewMode = _nextOverviewMode!;
          _nextOverviewMode = null;
        }
      });
      overviewTransitionController.reset();
    } else if (status == AnimationStatus.dismissed &&
        _nextOverviewMode != null) {
      setState(() {
        _nextOverviewMode = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: topPadding),
          AccountCard(),
          Styles.gap,
          OverviewToolbar<Currency>(
            proportionalWidth: false,
            padding: Styles.horizontalPadding,
            backgroundColor: AppColors.onBackground,
            thumbColor: AppColors.highlighted,
            groupValue: currencyView,
            onValueChanged: _toggleCurrencyController,
            children: const <Currency, Widget>{
              Currency.crypto: Text('Crypto'),
              Currency.fiat: Text('Fiat'),
              Currency.card: Text('Card'),
              Currency.savings: Text('Savings'),
            },
            actionOne: Row(
              spacing: 6,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Card analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_down,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
            actionTwo: const Icon(CupertinoIcons.gear, color: AppColors.white),
            onActionOne: () => print('Action One ACTIVATED'),
            onActionTwo: () => print('Action Two ACTIVATED'),
            onModeChanged: _toggleViewMode,
          ),
          Styles.gap,

          // Animated section now lives in its own file, no AnimatedBuilder.
          OverviewAnimatedSection(
            controller: overviewTransitionController,
            isCurrentActivity: overviewMode == ViewMode.activity,
            isNextActivity: _nextOverviewMode == null
                ? null
                : _nextOverviewMode == ViewMode.activity,
            panelBuilder: (isActivity) {
              return isActivity ? const ActivityPanel() : const CurrencyPanel();
            },
          ),

          const SizedBox(height: 150),
        ],
      ),
    );
  }
}
