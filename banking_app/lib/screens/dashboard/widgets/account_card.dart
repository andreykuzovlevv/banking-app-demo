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
            const Color.fromARGB(255, 13, 36, 163),
            AppColors.surface,
          ],
          radius: 2,
          center: AlignmentGeometry.xy(0.8, 2.2),
          stops: [0.28, 0.4, 0.5, 0.7],
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
                iconSize: 30,
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
                    Text('Total balance', style: Styles.secondary),
                    Icon(CupertinoIcons.eye, size: 18, color: Colors.grey),
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
            foregroundImage: AssetImage('assets/img/butter_dog.jpg'),
            backgroundColor: Colors.deepOrangeAccent,
          ),
        ),
        Text('Butter Dog', style: Styles.bold),
      ],
    );
  }
}

class UserBalance extends StatelessWidget {
  const UserBalance({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(r'$12 345 678,90', style: Styles.largeTitle);
  }
}

class AccountOperations extends StatelessWidget {
  const AccountOperations({super.key});

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.add,
            label: 'Add saving',
            iconSize: _iconSize,
          ),
        ),
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.arrow_up,
            label: 'Withdraw',
            iconSize: _iconSize,
          ),
        ),
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.arrow_down,
            label: 'Top up',
            iconSize: _iconSize,
          ),
        ),
        SizedBox(
          width: 72,
          child: CircleIconButton(
            icon: CupertinoIcons.arrow_right_arrow_left,
            label: 'Exchange',
            iconSize: _iconSize,
          ),
        ),
      ],
    );
  }
}
