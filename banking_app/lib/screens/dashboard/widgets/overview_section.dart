import 'package:banking_app/styles/styles.dart';
import 'package:banking_app/widgets/circle_icon_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: Styles.bodyPadding,
      decoration: BoxDecoration(
        color: AppColors.onBackground,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Styles.gap,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Styles.gap,
                    Padding(
                      padding: Styles.horizontalBodyPadding,
                      child: Column(
                        children: [
                          Text('Spending this month', style: Styles.secondary),
                          Styles.gap,
                          Text('\$12 521.21', style: Styles.mediumTitle),
                        ],
                      ),
                    ),
                    Styles.gap,
                    Container(
                      padding: Styles.bodyPadding * 1.2,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.highlighted),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '\u{1F60E}',
                              style: const TextStyle(fontFamily: 'AppleEmoji'),
                            ),
                            const TextSpan(
                              text: " You've made 36 transactions",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 220 - (Styles.spaceBetween * 5) - 52,
                width: 220 - (Styles.spaceBetween * 5) - 52,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    sections: [
                      PieChartSectionData(
                        value: 0.6,
                        showTitle: false,
                        color: Colors.indigo,
                      ),
                      PieChartSectionData(
                        value: 0.25,
                        showTitle: false,
                        color: Colors.deepOrangeAccent,
                      ),
                      PieChartSectionData(
                        value: 0.1,
                        showTitle: false,
                        color: Colors.pinkAccent,
                      ),
                      PieChartSectionData(
                        value: 0.05,
                        showTitle: false,
                        color: Colors.deepPurpleAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Styles.spaceBetween * 2),
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.highlighted),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.highlighted,
                    ),
                    child: Row(
                      spacing: Styles.spaceBetween / 2,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.arrow_up_right, size: 20),
                        Text('Spending'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: double.infinity,
                    child: Row(
                      spacing: Styles.spaceBetween / 2,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_down_left,
                          color: Colors.grey,
                          size: 20,
                        ),
                        Text('Income', style: Styles.secondary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrencyPanel extends StatelessWidget {
  const CurrencyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: List.generate(
          5, // how many times
          (_) => Container(
            height: 180,
            width: 230,
            margin: const EdgeInsets.only(right: 12),
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
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Styles.spaceBetween,
                    children: [
                      Text('1,1272', style: Styles.mediumTitle),
                      Text('\$67 203,95', style: Styles.secondary),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: Styles.spaceBetween / 2,
                    children: [
                      Icon(CupertinoIcons.arrow_up, size: 20),
                      Text('2,15'),
                    ],
                  ),
                ),
              ],
            ),
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
                    children: [
                      Text('USDT to BTC', style: Styles.bold),
                      Text('2023-07-25', style: Styles.secondary),
                    ],
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
        boxShadow: [BoxShadow(color: AppColors.background, blurRadius: 4)],
      ),
      child: child,
    );
  }
}
