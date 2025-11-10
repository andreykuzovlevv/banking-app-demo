import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(children: [Avatar(), NotificationsButton()]),
          Row(children: [Text('Total balance'), Icon(Icons.remove_red_eye)]),
          UserBalance(),
          AccountOperations(),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class NotificationsButton extends StatelessWidget {
  const NotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class UserBalance extends StatelessWidget {
  const UserBalance({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AccountOperations extends StatelessWidget {
  const AccountOperations({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
