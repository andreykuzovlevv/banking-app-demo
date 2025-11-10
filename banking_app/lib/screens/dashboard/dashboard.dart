import 'package:flutter/material.dart';

import 'widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    body: Column(children: [AccountCard(), OverviewSection()]),
  );
}
