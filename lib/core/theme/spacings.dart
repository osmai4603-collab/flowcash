import 'package:flutter/rendering.dart';

sealed class Spacings {
  const Spacings._();

  static const xsmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xlarge = 32.0;


  static const mediumPadding = EdgeInsets.all(medium);
}
