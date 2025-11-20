import 'package:banking_app/widgets/pressable.dart';
import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.iconSize = 40,
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
      child: Column(
        spacing: 10,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: iconSize),
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
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          if (label != null && label!.isNotEmpty) Text(label!),
        ],
      ),
    );
  }
}
