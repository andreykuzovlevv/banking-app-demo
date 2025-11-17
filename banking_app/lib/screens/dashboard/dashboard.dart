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

class _DashboardScreenState extends State<DashboardScreen> {
  ViewMode overviewMode = ViewMode.currency;

  Currency currencyView = Currency.crypto;

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
            onValueChanged: (Currency? value) {
              if (value != null) {
                setState(() {
                  currencyView = value;
                });
              }
            },
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
          ),
          SizedBox(height: 10),
          ActivityPanel(overviewMode: overviewMode),
        ],
      ),
    );
  }
}
