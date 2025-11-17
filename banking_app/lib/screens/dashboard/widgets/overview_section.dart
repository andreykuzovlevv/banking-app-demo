import 'package:flutter/material.dart';

class ActivityPanel extends StatelessWidget {
  const ActivityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      height: 40,
      width: double.infinity,
      child: Text('Activity Panel'),
    );
  }
}

class CyrrencyPanel extends StatelessWidget {
  const CyrrencyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber,
      height: 40,
      width: double.infinity,
      child: Text('Currency Panel'),
    );
  }
}

class StackCards extends StatelessWidget {
  const StackCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent,
      height: 40,
      child: Text('Stack Cards'),
    );
  }
}
