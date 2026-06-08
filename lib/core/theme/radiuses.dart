import 'package:flutter/material.dart';

sealed class Radiuses {
  const Radiuses._();

  static const xsmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xlarge = 32.0;

  static const BorderRadius xsmallAll = BorderRadius.all(
    Radius.circular(xsmall),
  );
  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumAll = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(large));
  static const BorderRadius xlargeAll = BorderRadius.all(
    Radius.circular(xlarge),
  );

  static const BorderRadius none = BorderRadius.all(Radius.circular(0));
}
