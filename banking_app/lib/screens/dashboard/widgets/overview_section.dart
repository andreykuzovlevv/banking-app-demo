import 'package:flutter/material.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        OverviewToolbar(),
        ActivityPanel(), // OR InsightsPanel()
      ],
    );
  }
}

class OverviewToolbar extends StatelessWidget {
  const OverviewToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrangeAccent,
      child: SizedBox(height: 100, width: 100),
    );
  }
}

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: SizedBox(height: 100, width: 100),
    );
  }
}
