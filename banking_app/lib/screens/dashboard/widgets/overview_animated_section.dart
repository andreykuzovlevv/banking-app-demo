import 'dart:ui';

import 'package:banking_app/screens/dashboard/widgets/list_view_page.dart';
import 'package:banking_app/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets.dart';

/// Replaces the AnimatedBuilder. Owns the phase logic and rebuilds off [controller].
class OverviewAnimatedSection extends AnimatedWidget {
  OverviewAnimatedSection({
    super.key,
    required this.controller,
    required this.isCurrentActivity,
    required this.isNextActivity,
    required this.panelBuilder,
  }) : opacityOut = controller
           .drive(
             CurveTween(
               curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
             ),
           )
           .drive(Tween<double>(begin: 1.0, end: 0.0)),
       offsetYOut = controller
           .drive(
             CurveTween(
               curve: const Interval(0.0, 0.4, curve: Curves.easeInCubic),
             ),
           )
           .drive(Tween<double>(begin: 0.0, end: _slide)),
       opacityInPanel = controller
           .drive(
             CurveTween(
               curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
             ),
           )
           .drive(Tween<double>(begin: 0.0, end: 1.0)),
       opacityInCards = controller
           .drive(
             CurveTween(curve: const Interval(0.5, 1, curve: Curves.easeInOut)),
           )
           .drive(Tween<double>(begin: 0.0, end: 1.0)),
       offsetYInPanel = controller
           .drive(
             CurveTween(
               curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
             ),
           )
           .drive(Tween<double>(begin: _slide, end: 0.0)),
       offsetYInCards = controller
           .drive(
             CurveTween(
               curve: const Interval(0.5, 1, curve: Curves.easeOutCubic),
             ),
           )
           .drive(Tween<double>(begin: _slide, end: 0.0)),
       super(listenable: controller);

  static const double _slide = 200;

  final AnimationController controller;

  /// Current (committed) mode from parent.
  final bool isCurrentActivity;

  /// Pending (next) mode from parent. Null when none is pending.
  final bool? isNextActivity;

  /// Lets this widget stay enum-free; parent decides what "activity" means.
  final Widget Function(bool isActivity) panelBuilder;

  final Animation<double> opacityOut;
  final Animation<double> offsetYOut;
  final Animation<double> opacityInPanel;
  final Animation<double> opacityInCards;
  final Animation<double> offsetYInPanel;
  final Animation<double> offsetYInCards;

  @override
  Widget build(BuildContext context) {
    final bool hasPendingMode = isNextActivity != null;
    final bool isAnimating = controller.isAnimating || hasPendingMode;

    final bool isFadeOutPhase = isAnimating && controller.value <= 0.4;

    final bool currentIsActivity = !isAnimating
        ? isCurrentActivity
        : isFadeOutPhase
        ? isCurrentActivity
        : isNextActivity ?? isCurrentActivity;

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
      panel: panelBuilder(currentIsActivity),
      panelOpacity: panelOpacity,
      panelOffsetY: panelOffsetY,
      cardsOpacity: cardsOpacity,
      cardsOffsetY: cardsOffsetY,
    );
  }
}

/// Moved out of DashboardScreen, unchanged except it receives [panel].
class _OverviewAnimatedColumn extends StatelessWidget {
  const _OverviewAnimatedColumn({
    required this.panel,
    required this.panelOpacity,
    required this.panelOffsetY,
    required this.cardsOpacity,
    required this.cardsOffsetY,
  });

  final Widget panel;
  final double panelOpacity;
  final double panelOffsetY;
  final double cardsOpacity;
  final double cardsOffsetY;

  @override
  Widget build(BuildContext context) {
    final containerKey = GlobalKey();
    final cardInfoKey = GlobalKey();

    Future<void> showBottomSheet() async {
      final RenderBox? containerRenderBox =
          containerKey.currentContext?.findRenderObject() as RenderBox?;

      final RenderBox? cardInfoRenderBox =
          cardInfoKey.currentContext?.findRenderObject() as RenderBox?;

      await Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          reverseTransitionDuration: const Duration(seconds: 1),
          pageBuilder: (context, animation, secondaryAnimation) {
            return ListViewPage(
              listenable: animation,
              containerRenderBox: containerRenderBox,
              cardInfoRenderBox: cardInfoRenderBox,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final blurCurve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );
            final blurSigma = 8.0 * blurCurve.value;

            return Stack(
              children: [
                if (blurSigma > 0)
                  Positioned.fill(
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: blurSigma,
                          sigmaY: blurSigma,
                        ),
                        child: Opacity(
                          opacity: blurCurve.value,
                          child: Container(color: AppColors.background),
                        ),
                      ),
                    ),
                  ),
                child,
              ],
            );
          },
        ),
      );
    }

    return Padding(
      padding: Styles.horizontalPadding,
      child: Column(
        children: [
          Opacity(
            opacity: panelOpacity,
            child: Transform.translate(
              offset: Offset(0, panelOffsetY),
              child: panel,
            ),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: cardsOpacity,
            child: Transform.translate(
              offset: Offset(0, cardsOffsetY),
              child: StackCards(
                onTap: showBottomSheet,
                containerKey: containerKey,
                cardInfoKey: cardInfoKey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
