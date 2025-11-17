import 'package:banking_app/styles/styles.dart';
import 'package:banking_app/widgets/circle_icon_button.dart';
import 'package:banking_app/widgets/pressable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: Styles.horizontalBodyPadding,
      padding: Styles.cardPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: RadialGradient(
          colors: [
            const Color.fromARGB(255, 200, 209, 255),
            const Color.fromARGB(255, 58, 87, 253),
            AppColors.surface,
          ],
          radius: 2,
          center: AlignmentGeometry.xy(0.8, 2.2),
          stops: [0.25, 0.4, 0.65],
          focal: Alignment(0.8, 2.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Avatar(),
              Spacer(),
              CircleIconButton(
                backgroundColor: AppColors.highlighted,
                icon: CupertinoIcons.bell,
                showBadge: true,
              ), // Notifications Button
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 10),
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
            backgroundColor: Colors.deepOrangeAccent,
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
    return Text(r'$12 345 678,90', style: TextStyle(fontSize: 40));
  }
}

class AccountOperations extends StatelessWidget {
  const AccountOperations({super.key});

  static const double iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.add,
            label: 'Add saving',
            iconSize: iconSize,
          ),
        ),
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.add,
            label: 'Withdraw',
            iconSize: iconSize,
          ),
        ),
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.add,
            label: 'Top up',
            iconSize: iconSize,
          ),
        ),
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.add,
            label: 'Exchange',
            iconSize: iconSize,
          ),
        ),
      ],
    );
  }
}
