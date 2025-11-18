import 'package:banking_app/styles/styles.dart';
import 'package:banking_app/widgets/circle_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.onBackground),
      child: Text('Activity Panel'),
    );
  }
}

class CyrrencyPanel extends StatelessWidget {
  const CyrrencyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: Styles.spaceBetween,
      children: List.generate(
        2, // how many times
        (_) => Container(
          height: 180,
          width: 230,
          padding: Styles.bodyPadding,
          decoration: BoxDecoration(
            color: AppColors.onBackground,
            borderRadius: BorderRadius.circular(38),
          ),
          child: Stack(
            children: [
              Positioned(
                child: CircleIconButton(icon: CupertinoIcons.money_dollar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StackCards extends StatelessWidget {
  const StackCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16, top: 16),
          child: Text('Recent transactions'),
        ),
        Stack(
          children: [
            Opacity(
              opacity: 0.6,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translateByDouble(0, 24, 0, 1)
                  ..scaleByDouble(0.8, 0.8, 0.8, 1),
                child: CardContainer(),
              ),
            ),
            Opacity(
              opacity: 0.8,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translateByDouble(0, 12, 0, 1)
                  ..scaleByDouble(0.90, 0.90, 0.90, 1),
                child: CardContainer(),
              ),
            ),
            CardContainer(
              child: Row(
                children: [
                  CircleIconButton(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    iconSize: 24,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [Text('USDT to BTC'), Text('2023-07-25')],
                  ),
                  Spacer(),
                  Text('+0,0116 BTC'),
                  SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CardContainer extends StatelessWidget {
  const CardContainer({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      width: double.infinity,
      padding: Styles.bodyPadding,
      decoration: BoxDecoration(
        color: AppColors.onBackground,
        borderRadius: BorderRadius.circular(38),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 4)],
      ),
      child: child,
    );
  }
}
