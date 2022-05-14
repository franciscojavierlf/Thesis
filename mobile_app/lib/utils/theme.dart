import 'package:flutter/material.dart';

// Constants
const CO2 = 'CO\u2082';

/// Class with all colors.
abstract class Palette {
  static const A = Color(0xff54523c);
  static const B = Color(0xffeee062);
  static const C = Color(0xffd4ce96);
  static const D = Color(0xff574e00);
  static const E = Color(0xffa19c72);
  static const midBgColor = Color(0xffeee9b9);
  static const lightBgColor = Color(0xfff2f0db);
}

extension DoubleUtils on num {
  double get px => this * 1.2;
}

extension WidgetUtils on Widget {
  Expanded get expanded => Expanded(child: this);
  Center get centered => Center(child: this);
  Align align(Alignment align) => Align(alignment: align, child: this);
  SizedBox box({double? width, double? height}) =>
      SizedBox(child: this, width: width, height: height);
  Padding paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
  Padding paddingOnly({
    double l = 0,
    double r = 0,
    double t = 0,
    double b = 0,
  }) =>
      Padding(
          padding: EdgeInsets.only(left: l, right: r, top: t, bottom: b),
          child: this);
}
