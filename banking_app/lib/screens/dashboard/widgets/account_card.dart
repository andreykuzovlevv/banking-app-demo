import 'package:banking_app/widgets/circle_icon_button.dart';
import 'package:banking_app/widgets/pressable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(38),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Avatar(),
              Spacer(),
              CircleIconButton(
                icon: CupertinoIcons.bell,
                showBadge: true,
              ), // Notifications Button
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Text('Total balance'),
                    Icon(CupertinoIcons.eye, size: 20),
                  ],
                ),
                UserBalance(),
                SizedBox(height: 30),
                AccountOperations(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Pressable(
          child: CircleAvatar(
            radius: 30,
            foregroundImage: AssetImage('assets/img/Butter_Dog.webp'),
            backgroundColor: Colors.white,
          ),
        ),
        Text('Butter Dog'),
      ],
    );
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
