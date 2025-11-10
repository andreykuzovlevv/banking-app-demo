import 'package:banking_app/widgets/pressable.dart';
import 'package:flutter/material.dart';

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.label,
    this.showBadge = false,
    this.onPressed,
  });

  final IconData icon;
  final String? label;
  final bool showBadge;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
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
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 40),
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
