import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

part 'app_colors.dart';

abstract class Styles {
  // text

  static const bottomNavBarTextStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  /// As the name in app card. Bold with normal size.
  static const bold = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: AppColors.white,
  );

  static const textRegular = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  /// Grayish, with size smaller then normal
  static const secondary = TextStyle(fontSize: 14, color: AppColors.inactive);

  static const largeTitle = TextStyle(
    fontSize: 44.0,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
  static const mediumTitle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );
  static const smallTitle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const double spaceBetween = 8;

  static const double spaceBetweenSmall = 6;

  static const double spaceBetweenMedium = spaceBetween * 1.5;
  static const double spaceBetweenLarge = spaceBetween * 2;

  static const double bottomNavBarHeight = 50;
  static const double bottomNavBarIconSize = 32;

  static const gap = SizedBox(height: spaceBetween, width: spaceBetween);

  // padding
  static const paddingAll = EdgeInsets.all(spaceBetween);
  static const horizontalPadding = EdgeInsets.symmetric(
    horizontal: spaceBetween,
  );
  static const verticalPadding = EdgeInsets.symmetric(vertical: spaceBetween);

  static const cardPadding = EdgeInsets.all(spaceBetweenMedium);

  // corners
  static const borderRadius = BorderRadius.all(
    Radius.circular(spaceBetween * 4),
  );
  static const borderRadiusLarge = BorderRadius.all(
    Radius.circular(spaceBetween * 5),
  );

  static const double circleRadius = spaceBetween * 4;
  static const double circleSize = circleRadius * 2;
}
