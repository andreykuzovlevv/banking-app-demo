import 'package:banking_app/screens/dashboard/widgets/toggle_modes_button.dart';
import 'package:flutter/material.dart';

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({super.key, required this.overviewMode});
  final ViewMode overviewMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
      child: SizedBox(height: 100, width: 100),
    );
  }
}
