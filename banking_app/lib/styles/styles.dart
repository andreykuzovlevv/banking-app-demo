import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

part 'app_colors.dart';

abstract class Styles {
  // text

  /// As the name in app card. Bold with normal size.
  ///
  static const bold = TextStyle(fontWeight: FontWeight.w500, fontSize: 18);

  /// Grayish, with size smaller then normal
  ///
  static const secondary = TextStyle(fontSize: 14, color: Colors.grey);

  static const largeTitle = TextStyle(
    fontSize: 44.0,
    fontWeight: FontWeight.w500,
  );
  static const mediumTitle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w500,
  );
  static const smallTitle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
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

  static const formDescription = TextStyle(fontSize: 12);
  static const linkStyle = TextStyle(
    color: Colors.blueAccent,
    decoration: TextDecoration.none,
  );
  static const noResultTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 20.0,
  );

  static const double spaceBetween = 8;

  static const gap = SizedBox(height: spaceBetween, width: spaceBetween);

  // padding
  static const bodyPadding = EdgeInsets.symmetric(
    vertical: spaceBetween,
    horizontal: spaceBetween,
  );
  static const verticalBodyPadding = EdgeInsets.symmetric(vertical: 16.0);
  static const horizontalBodyPadding = EdgeInsets.symmetric(
    horizontal: spaceBetween,
  );
  static const sectionBottomPadding = EdgeInsets.only(bottom: spaceBetween);
  static const sectionTopPadding = EdgeInsets.only(top: 16.0);
  static const cardPadding = EdgeInsets.all(spaceBetween);

  /// Horizontal and bottom padding for the body section.
  static const bodySectionBottomPadding = EdgeInsets.only(
    bottom: 16.0,
    left: 16.0,
    right: 16.0,
  );

  // cards
  static const cardBorderRadius = BorderRadius.all(Radius.circular(12.0));
}
