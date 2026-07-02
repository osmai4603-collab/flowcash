import 'package:flutter/material.dart';

sealed class Paddings {
  const Paddings._();

  static const xsmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xlarge = 32.0;

  static const EdgeInsets xsmallAll = EdgeInsets.all(xsmall);
  static const EdgeInsets smallAll = EdgeInsets.all(small);
  static const EdgeInsets mediumAll = EdgeInsets.all(medium);
  static const EdgeInsets largeAll = EdgeInsets.all(large);
  static const EdgeInsets xlargeAll = EdgeInsets.all(xlarge);

  static const EdgeInsets xsmallHorizontal = EdgeInsets.symmetric(
    horizontal: xsmall,
  );
  static const EdgeInsets smallHorizontal = EdgeInsets.symmetric(
    horizontal: small,
  );
  static const EdgeInsets mediumHorizontal = EdgeInsets.symmetric(
    horizontal: medium,
  );
  static const EdgeInsets largeHorizontal = EdgeInsets.symmetric(
    horizontal: large,
  );
  static const EdgeInsets xlargeHorizontal = EdgeInsets.symmetric(
    horizontal: xlarge,
  );

  static const EdgeInsets xsmallVertical = EdgeInsets.symmetric(
    vertical: xsmall,
  );
  static const EdgeInsets smallVertical = EdgeInsets.symmetric(vertical: small);
  static const EdgeInsets mediumVertical = EdgeInsets.symmetric(
    vertical: medium,
  );
  static const EdgeInsets largeVertical = EdgeInsets.symmetric(vertical: large);
  static const EdgeInsets xlargeVertical = EdgeInsets.symmetric(
    vertical: xlarge,
  );

  static const EdgeInsetsGeometry none = EdgeInsets.all(0.0);
}
