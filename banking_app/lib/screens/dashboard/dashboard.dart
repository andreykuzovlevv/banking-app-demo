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

  static const double _slide = 200;

  late final AnimationController overviewTransitionController =
      AnimationController(
        duration: Duration(milliseconds: 1000),
        value: 0,
        vsync: this,
      );

  late final opacityOut = overviewTransitionController
      .drive(
        CurveTween(curve: const Interval(0.0, 0.4, curve: Curves.easeInOut)),
      )
      .drive(Tween<double>(begin: 1.0, end: 0.0));

  late final offsetYOut = overviewTransitionController
      .drive(
        CurveTween(curve: const Interval(0.0, 0.4, curve: Curves.easeInCubic)),
      )
      .drive(Tween<double>(begin: 0.0, end: _slide));

  late final opacityInPanel = overviewTransitionController
      .drive(
        CurveTween(curve: const Interval(0.4, 0.8, curve: Curves.easeInOut)),
      )
      .drive(Tween<double>(begin: 0.0, end: 1.0));

  late final opacityInCards = overviewTransitionController
      .drive(CurveTween(curve: const Interval(0.5, 1, curve: Curves.easeInOut)))
      .drive(Tween<double>(begin: 0.0, end: 1.0));

  late final offsetYInPanel = overviewTransitionController
      .drive(
        CurveTween(curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
      )
      .drive(Tween<double>(begin: _slide, end: 0.0));

  late final offsetYInCards = overviewTransitionController
      .drive(
        CurveTween(curve: const Interval(0.5, 1, curve: Curves.easeOutCubic)),
      )
      .drive(Tween<double>(begin: _slide, end: 0.0));

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
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: topPadding),
          AccountCard(),
          Styles.gap,
          OverviewToolbar<Currency>(
            proportionalWidth: false,
            padding: Styles.horizontalBodyPadding,
            backgroundColor: AppColors.onBackground,
            thumbColor: AppColors.highlighted,
            // This represents the currently selected segmented control.
            groupValue: currencyView,
            // Callback that sets the selected segmented control.
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
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Icon(CupertinoIcons.chevron_down, size: 16, color: Colors.grey),
              ],
            ),
            actionTwo: Icon(CupertinoIcons.gear, color: Color(0xffffffff)),
            onActionOne: () => print('Action One ACTIVATED'),
            onActionTwo: () => print('Action Two ACTIVATED'),

            onModeChanged: _toggleViewMode,
          ),
          SizedBox(height: 10),
          AnimatedBuilder(
            animation: overviewTransitionController,
            builder: (context, child) {
              final bool hasPendingMode = _nextOverviewMode != null;
              final bool isAnimating =
                  overviewTransitionController.isAnimating || hasPendingMode;

              final bool isFadeOutPhase =
                  isAnimating && overviewTransitionController.value <= 0.4;

              final ViewMode currentViewMode = !isAnimating
                  ? overviewMode
                  : isFadeOutPhase
                  ? overviewMode
                  : _nextOverviewMode ?? overviewMode;

              final double panelOpacity;
              final double panelOffsetY;
              final double cardsOpacity;
              final double cardsOffsetY;

              if (!isAnimating) {
                panelOpacity = 1.0;
                panelOffsetY = 0.0;
                cardsOpacity = 1.0;
                cardsOffsetY = 0.0;
              } else if (isFadeOutPhase) {
                panelOpacity = opacityOut.value;
                panelOffsetY = offsetYOut.value;
                cardsOpacity = opacityOut.value;
                cardsOffsetY = offsetYOut.value;
              } else {
                panelOpacity = opacityInPanel.value;
                panelOffsetY = offsetYInPanel.value;
                cardsOpacity = opacityInCards.value;
                cardsOffsetY = offsetYInCards.value;
              }

              return _OverviewAnimatedColumn(
                viewMode: currentViewMode,
                panelOpacity: panelOpacity,
                panelOffsetY: panelOffsetY,
                cardsOpacity: cardsOpacity,
                cardsOffsetY: cardsOffsetY,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewAnimatedColumn extends StatelessWidget {
  const _OverviewAnimatedColumn({
    required this.viewMode,
    required this.panelOpacity,
    required this.panelOffsetY,
    required this.cardsOpacity,
    required this.cardsOffsetY,
  });

  final ViewMode viewMode;
  final double panelOpacity;
  final double panelOffsetY;
  final double cardsOpacity;
  final double cardsOffsetY;

  Widget _buildPanel() {
    switch (viewMode) {
      case ViewMode.activity:
        return const ActivityPanel();
      case ViewMode.currency:
        return const CurrencyPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showBottomSheet() async {
      await Navigator.of(context).push(
        //rootNavigator: true
        PageRouteBuilder(
          transitionDuration: Duration(seconds: 30),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ListViewPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
    }

    return Padding(
      padding: Styles.horizontalBodyPadding,
      child: Column(
        children: [
          Opacity(
            opacity: panelOpacity,
            child: Transform.translate(
              offset: Offset(0, panelOffsetY),
              child: _buildPanel(),
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: cardsOpacity,
            child: Transform.translate(
              offset: Offset(0, cardsOffsetY),
              child: GestureDetector(
                onTap: () => _showBottomSheet(),
                child: const StackCards(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String listViewContainerTag = 'list_view_container_tag';

class ListViewPage extends StatelessWidget {
  const ListViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Hero(
            tag: listViewContainerTag,
            child: Container(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(top: 16, right: 8, left: 8),
              padding: EdgeInsets.only(right: 8, left: 8),
              decoration: BoxDecoration(
                color: AppColors.onBackground,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                  bottom: Radius.circular(30),
                ),
              ),
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.only(top: 16, right: 8, left: 8),
            padding: EdgeInsets.only(right: 8, left: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ListView(
              padding: EdgeInsets.only(bottom: 18),
              children: List.generate(30, (index) {
                final card = const CurrencyInfo();
                if (index == 0) {
                  return Hero(
                    tag: recentTransactionHeroTag,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: card,
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: card,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
