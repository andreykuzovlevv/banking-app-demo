import 'dart:ui';

import 'package:banking_app/screens/dashboard/widgets/overview_toolbar.dart';
import 'package:banking_app/styles/styles.dart';
import 'package:banking_app/widgets/circle_icon_button.dart';
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
    final cardKey = GlobalKey();

    void showBottomSheet() async {
      // Get the source widget's position
      final RenderBox? renderBox =
          cardKey.currentContext?.findRenderObject() as RenderBox?;
      final sourcePosition = renderBox?.localToGlobal(Offset.zero);
      final sourceSize = renderBox?.size;

      await Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return ListViewPage(listenable: animation);
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
                onTap: () => showBottomSheet(),
                child: StackCards(cardKey: cardKey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListViewPage extends AnimatedWidget {
  const ListViewPage({super.key, required super.listenable});

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        leadingWidth: 100,
        leading: CircleIconButton(
          icon: CupertinoIcons.clear,
          backgroundColor: AppColors.onBackground,
          iconSize: 26,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: Stack(
          children: [
            // Background container - rendered first (under everything)
            Container(
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
            // List container - rendered on top
            Container(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.only(top: 16, right: 8, left: 8),
              padding: EdgeInsets.only(right: 8, left: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                padding: EdgeInsets.only(bottom: 18, top: 8),
                children: List.generate(30, (index) {
                  final card = const CurrencyInfo();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: card,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomPageRoute extends PageRoute {
  final Widget child;
  final Offset sourcePosition;
  final Size sourceSize;

  _CustomPageRoute({
    required this.child,
    required this.sourcePosition,
    required this.sourceSize,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 8000);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Pass animation to child so it can animate list items
    return ListViewPage(listenable: animation);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = AppBar().preferredSize.height;

    // Use source position if valid, otherwise calculate a default
    final validSourcePosition = sourcePosition.dx > 0 && sourcePosition.dy > 0
        ? sourcePosition
        : Offset(8, screenSize.height * 0.5);
    final validSourceSize = sourceSize.width > 0 && sourceSize.height > 0
        ? sourceSize
        : Size(screenSize.width - 16, 76.0);

    // Calculate destination position (first list item position)
    final destinationY =
        topPadding +
        appBarHeight +
        16 +
        8; // topPadding + appBar + margin + padding
    final destinationX = 8.0; // margin
    final destinationSize = Size(
      screenSize.width - 16,
      76.0,
    ); // width minus margins, height of card

    // Animation curves for different phases
    final cardMorphCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
    );

    final backgroundExpandCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    );

    final appBarCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );

    final blurCurve = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // Card morphing animation
        final cardProgress = cardMorphCurve.value;
        final cardX =
            validSourcePosition.dx +
            (destinationX - validSourcePosition.dx) * cardProgress;
        final cardY =
            validSourcePosition.dy +
            (destinationY - validSourcePosition.dy) * cardProgress;
        final cardWidth =
            validSourceSize.width +
            (destinationSize.width - validSourceSize.width) * cardProgress;
        final cardHeight =
            validSourceSize.height +
            (destinationSize.height - validSourceSize.height) * cardProgress;
        final cardBorderRadius =
            38.0 * (1 - cardProgress) + 30.0 * cardProgress;
        final cardOpacity = cardProgress < 0.4
            ? 1.0 - (cardProgress / 0.4)
            : 0.0;

        // Background expansion from card position
        final backgroundProgress = backgroundExpandCurve.value;
        final backgroundStartY = validSourcePosition.dy;
        final backgroundEndY = 0.0;
        final backgroundY =
            backgroundStartY +
            (backgroundEndY - backgroundStartY) * backgroundProgress;
        final backgroundHeight =
            validSourceSize.height +
            (screenSize.height - validSourceSize.height) * backgroundProgress;
        final backgroundBorderRadius =
            38.0 * (1 - backgroundProgress) + 30.0 * backgroundProgress;

        // AppBar animation
        final appBarProgress = appBarCurve.value;
        final appBarOpacity = appBarProgress;
        final appBarOffset = (1 - appBarProgress) * -60;

        // Blur effect
        final blurProgress = blurCurve.value;
        final blurSigma = 8.0 * blurProgress;
        final blurOpacity = blurProgress < 0.5
            ? blurProgress * 2
            : 1.0 - (blurProgress - 0.5) * 2;

        return Stack(
          children: [
            // Background blur layer (fades in then out)
            if (blurProgress > 0 && blurOpacity > 0)
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blurSigma,
                      sigmaY: blurSigma,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),

            // Expanding background container
            Positioned(
              left: 8,
              top: backgroundY,
              right: 8,
              height: backgroundHeight,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.onBackground,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(backgroundBorderRadius),
                    bottom: Radius.circular(30),
                  ),
                ),
              ),
            ),

            // Main content (child) - rendered on top
            Transform.translate(
              offset: Offset(0, appBarOffset),
              child: Opacity(opacity: appBarOpacity, child: child),
            ),

            // Morphing card overlay (fades out as it morphs)
            if (cardProgress < 1.0 && cardOpacity > 0)
              Positioned(
                left: cardX,
                top: cardY,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  padding: Styles.bodyPadding,
                  decoration: BoxDecoration(
                    color: AppColors.onBackground,
                    borderRadius: BorderRadius.circular(cardBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.background.withAlpha(60),
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: cardProgress < 0.6 ? const CurrencyInfo() : null,
                ),
              ),
          ],
        );
      },
    );
  }
}
