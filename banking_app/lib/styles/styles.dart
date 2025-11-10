import 'package:flutter/material.dart';

part 'app_colors.dart';

abstract class Styles {
  // text
  static const bold = TextStyle(fontWeight: FontWeight.bold);
  static const title = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
  static const subtitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const callout = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const mainListTileTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const boardPreviewTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static const subtitleOpacity = 0.7;
  static const timeControl = TextStyle(letterSpacing: 1.2);
  static const formLabel = TextStyle(fontWeight: FontWeight.bold);
  static const formError = TextStyle(color: AppColors.red);
  static const formDescription = TextStyle(fontSize: 12);
  static const linkStyle = TextStyle(
    color: Colors.blueAccent,
    decoration: TextDecoration.none,
  );
  static const noResultTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 20.0,
  );

  // padding
  static const bodyPadding = EdgeInsets.symmetric(
    vertical: 16.0,
    horizontal: 16.0,
  );
  static const verticalBodyPadding = EdgeInsets.symmetric(vertical: 16.0);
  static const horizontalBodyPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const sectionBottomPadding = EdgeInsets.only(bottom: 16.0);
  static const sectionTopPadding = EdgeInsets.only(top: 16.0);
  static const bodySectionPadding = EdgeInsets.all(16.0);

  /// Horizontal and bottom padding for the body section.
  static const bodySectionBottomPadding = EdgeInsets.only(
    bottom: 16.0,
    left: 16.0,
    right: 16.0,
  );

  // cards
  static const cardBorderRadius = BorderRadius.all(Radius.circular(12.0));
}
