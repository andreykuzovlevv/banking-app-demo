import 'package:banking_app/styles/styles.dart';
import 'package:banking_app/widgets/pressable.dart';
import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.iconSize = Styles.circleRadius,
    this.label,
    this.backgroundColor = Colors.white24,
    this.showBadge = false,
    this.onPressed,
    this.pressedScale = 0.97,
  });

  final IconData icon;
  final double iconSize;
  final String? label;
  final Color backgroundColor;
  final bool showBadge;
  final VoidCallback? onPressed;
  final double pressedScale;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      pressedScale: pressedScale,
      onTap: onPressed,
      brighten: false,
      child: Column(
        spacing: Styles.spaceBetweenMedium,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Styles.circleSize,
                height: Styles.circleSize,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.white, size: iconSize),
              ),

              // Red badge (optional)
              if (showBadge)
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          if (label != null && label!.isNotEmpty)
            Text(label!, style: Styles.textRegular),
        ],
      ),
    );
  }
}
