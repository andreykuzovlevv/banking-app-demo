import 'package:banking_app/screens/dashboard/widgets/overview_toolbar.dart';
import 'package:banking_app/screens/dashboard/widgets/toggle_modes_button.dart';
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
          SizedBox(height: 20),
          OverviewToolbar<Currency>(
            backgroundColor: const Color.fromRGBO(55, 55, 55, 1),
            thumbColor: const Color.fromARGB(255, 110, 110, 110),
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
              Currency.card: Text('Midnight'),
              Currency.crypto: Text('Viridian'),
              Currency.fiat: Text('Cerulean'),
            },
            actionOne: Text('Card analysis >'),
            actionTwo: Icon(
              CupertinoIcons.gear_solid,
              color: Color(0xffffffff),
            ),
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
