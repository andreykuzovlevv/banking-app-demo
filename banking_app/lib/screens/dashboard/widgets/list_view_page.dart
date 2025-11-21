import 'dart:ui';

import 'package:banking_app/screens/dashboard/widgets/overview_section.dart';
import 'package:banking_app/styles/styles.dart';
import 'package:banking_app/widgets/circle_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double topMargin = 16;

class ListViewPage extends AnimatedWidget {
  const ListViewPage({
    super.key,
    required super.listenable,
    required this.containerRenderBox,
    required this.cardInfoRenderBox,
  });

  final RenderBox? containerRenderBox;
  final RenderBox? cardInfoRenderBox;

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AnimatedAppBar(
        animationValue: Curves.easeInOut.transform(_animation.value),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = MediaQuery.of(context).size;

          final animationValue = _animation.value;
          final curvedValue = Curves.easeInOutCubic.transform(animationValue);

          final bodyOffset =
              (context.findRenderObject() as RenderBox?)?.localToGlobal(
                Offset.zero,
              ) ??
              Offset.zero;

          final containerBox = containerRenderBox;
          if (containerBox == null || !containerBox.attached) {
            return const SizedBox.shrink();
          }

          final topLeftContainer =
              containerBox.localToGlobal(Offset.zero) - bodyOffset;

          // Get value for animation of top for background.
          final containerY = lerpDouble(
            topLeftContainer.dy,
            topMargin,
            curvedValue,
          );

          final containerHeight = lerpDouble(
            containerBox.size.height,
            screenSize.height *
                1.5, // extra height to extend it to bottom faster
            curvedValue,
          );

          return Stack(
            children: [
              Positioned(
                top: containerY,
                height: containerHeight,
                width: screenSize.width,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.onBackground,
                    borderRadius: BorderRadius.circular(38),
                  ),
                ),
              ),
              Container(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.only(top: topMargin, right: 8, left: 8),
                padding: EdgeInsets.only(right: 8, left: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
                ),
                child: _AnimatedCurrencyList(
                  animationValue: curvedValue,
                  cardInfoRenderBox: cardInfoRenderBox,
                  bodyOffset: bodyOffset,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedCurrencyList extends StatefulWidget {
  const _AnimatedCurrencyList({
    required this.animationValue,
    required this.cardInfoRenderBox,
    required this.bodyOffset,
  });

  final double animationValue;
  final RenderBox? cardInfoRenderBox;
  final Offset bodyOffset;

  @override
  State<_AnimatedCurrencyList> createState() => _AnimatedCurrencyListState();
}

class _AnimatedCurrencyListState extends State<_AnimatedCurrencyList> {
  static const double _collapsedSeparatorHeight = 8;
  static const double _extraSeparatorHeight = 500;

  final ScrollController _scrollController = ScrollController();
  double _previousAnimationValue = 0;
  bool _didResetOnReverse = false;

  @override
  void initState() {
    super.initState();
    _previousAnimationValue = widget.animationValue;
  }

  @override
  void didUpdateWidget(covariant _AnimatedCurrencyList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleAnimationProgress();
  }

  void _handleAnimationProgress() {
    final currentValue = widget.animationValue;
    final isReversing = currentValue < _previousAnimationValue;
    final isForward = currentValue > _previousAnimationValue;

    if (isReversing && !_didResetOnReverse && _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
      _didResetOnReverse = true;
    } else if (isForward) {
      _didResetOnReverse = false;
    }

    _previousAnimationValue = currentValue;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardInfoTop =
        widget.cardInfoRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final cardInfoLocalTop = cardInfoTop - widget.bodyOffset;
    final firstCardStartOffset =
        (cardInfoLocalTop.dy - topMargin - _collapsedSeparatorHeight);
    final firstCardAnimatedOffset =
        firstCardStartOffset * (1 - widget.animationValue);

    final separatorAnimatedAddition =
        (1 - widget.animationValue) * _extraSeparatorHeight;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(bottom: 18),
      itemCount: 30,
      itemBuilder: (context, index) {
        final card = const CurrencyInfo();
        final separatorsBefore = index;
        final additionalOffset = separatorAnimatedAddition * separatorsBefore;
        final translationY = firstCardAnimatedOffset + additionalOffset;

        final double topSpacing = _collapsedSeparatorHeight;

        return Padding(
          padding: EdgeInsets.only(
            top: topSpacing,
            bottom: _collapsedSeparatorHeight,
          ),
          child: Transform.translate(
            offset: Offset(0, translationY),
            child: card,
          ),
        );
      },
    );
  }
}

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AnimatedAppBar({super.key, required this.animationValue});

  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final offsetX = (1 - animationValue) * 50.0;
    return Opacity(
      opacity: animationValue,
      child: Transform.translate(
        offset: Offset(offsetX, 0),
        child: Padding(
          padding: EdgeInsets.only(
            top: topPadding,
            left: topMargin,
            right: topMargin,
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircleIconButton(
                  pressedScale: 0.7,
                  icon: CupertinoIcons.clear,
                  backgroundColor: AppColors.onBackground,
                  iconSize: 26,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('\$12 521.21', style: Styles.bold),
                    Text('Spending this month', style: Styles.secondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + topMargin);
}
