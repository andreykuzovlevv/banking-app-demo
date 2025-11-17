import 'package:banking_app/screens/dashboard/widgets/overview_toolbar.dart';
import 'package:banking_app/screens/dashboard/widgets/toggle_modes_button.dart';
import 'package:banking_app/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'widgets/widgets.dart';

enum Currency { crypto, fiat, card, savings }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  ViewMode overviewMode = ViewMode.currency;
  Currency currencyView = Currency.crypto;

  int overviewIndex = 0;
  int? _pendingOverviewIndex;

  late final AnimationController overviewTransitionController =
      AnimationController(
        duration: Duration(seconds: 1),
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
    final nextIndex = mode == ViewMode.currency ? 0 : 1;
    final isAnimating =
        _pendingOverviewIndex != null ||
        overviewTransitionController.isAnimating;

    if (overviewMode == mode || nextIndex == overviewIndex || isAnimating) {
      return;
    }

    setState(() {
      overviewMode = mode;
      _pendingOverviewIndex = nextIndex;
    });

    overviewTransitionController.forward(from: 0);
  }

  void _onOverviewTransitionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _pendingOverviewIndex == null) {
      return;
    }

    setState(() {
      overviewIndex = _pendingOverviewIndex!;
      _pendingOverviewIndex = null;
    });

    overviewTransitionController.reset();
  }

  double _phaseValue(double value, double begin, double end) {
    assert(end > begin);
    final intervalValue = (value - begin) / (end - begin);
    return intervalValue.clamp(0.0, 1.0);
  }

  Widget _buildOverviewStack() {
    return AnimatedBuilder(
      animation: overviewTransitionController,
      builder: (context, child) {
        final hasPending = _pendingOverviewIndex != null;

        if (!hasPending) {
          return _OverviewAnimatedColumn(
            key: ValueKey('overview_$overviewIndex'),
            index: overviewIndex,
            opacity: 1,
            offsetY: 0,
            cardsOpacity: 1,
            cardsOffsetY: 0,
          );
        }

        final controllerValue = overviewTransitionController.value;
        final outgoingPhase = _phaseValue(controllerValue, 0.0, 0.45);
        final incomingPhase = _phaseValue(controllerValue, 0.55, 1.0);
        final outgoingCardsPhase = _phaseValue(controllerValue, 0.0, 0.35);
        final incomingCardsPhase = _phaseValue(controllerValue, 0.65, 1.0);

        final outgoingOpacity = 1 - Curves.easeIn.transform(outgoingPhase);
        final incomingOpacity = Curves.easeOut.transform(incomingPhase);

        final outgoingOffset = Curves.easeInOut.transform(outgoingPhase) * 24;
        final incomingOffset =
            (1 - Curves.easeOut.transform(incomingPhase)) * 24;

        final outgoingCardsOpacity =
            1 - Curves.easeIn.transform(outgoingCardsPhase);
        final incomingCardsOpacity = Curves.easeOut.transform(
          incomingCardsPhase,
        );

        final outgoingCardsOffset =
            Curves.easeIn.transform(outgoingCardsPhase) * 36;
        final incomingCardsOffset =
            (1 - Curves.easeOut.transform(incomingCardsPhase)) * 36;

        return Stack(
          children: [
            _OverviewAnimatedColumn(
              key: ValueKey('overview_out_$overviewIndex'),
              index: overviewIndex,
              opacity: outgoingOpacity,
              offsetY: outgoingOffset,
              cardsOpacity: outgoingCardsOpacity,
              cardsOffsetY: outgoingCardsOffset,
            ),
            if (_pendingOverviewIndex != null)
              _OverviewAnimatedColumn(
                key: ValueKey('overview_in_${_pendingOverviewIndex!}'),
                index: _pendingOverviewIndex!,
                opacity: incomingOpacity,
                offsetY: incomingOffset,
                cardsOpacity: incomingCardsOpacity,
                cardsOffsetY: incomingCardsOffset,
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.black,
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
                Text('Card analysis'),
                Icon(CupertinoIcons.chevron_down, size: 16),
              ],
            ),
            actionTwo: Icon(CupertinoIcons.gear, color: Color(0xffffffff)),
            onActionOne: () => print('Action One ACTIVATED'),
            onActionTwo: () => print('Action Two ACTIVATED'),

            onModeChanged: _toggleViewMode,
          ),
          SizedBox(height: 10),
          _buildOverviewStack(),
        ],
      ),
    );
  }
}

class _OverviewAnimatedColumn extends StatelessWidget {
  const _OverviewAnimatedColumn({
    super.key,
    required this.index,
    required this.opacity,
    required this.offsetY,
    required this.cardsOpacity,
    required this.cardsOffsetY,
  });

  final int index;
  final double opacity;
  final double offsetY;
  final double cardsOpacity;
  final double cardsOffsetY;

  Widget _buildTopSection() {
    switch (index) {
      case 1:
        return const ActivityPanel();
      case 0:
      default:
        return const CyrrencyPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: opacity == 0,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, offsetY),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTopSection(),
              const SizedBox(height: 8),
              Opacity(
                opacity: cardsOpacity,
                child: Transform.translate(
                  offset: Offset(0, cardsOffsetY),
                  child: const StackCards(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
