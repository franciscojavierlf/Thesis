import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/material.dart';

/// An extension that contains our special themes.
class EcoText extends Text {
  EcoText.h1(
    String text, {
    Color color = Palette.D,
  }) : super(
          text,
          style: TextStyle(
            color: color,
            fontSize: 24.px,
            fontWeight: FontWeight.w600,
          ),
        );

  EcoText.h2(
    String text, {
    Color color = Palette.D,
  }) : super(
          text,
          style: TextStyle(
            color: color,
            fontSize: 20.px,
            fontWeight: FontWeight.w600,
          ),
        );

  EcoText.h3(
    String text, {
    Color color = Palette.D,
  }) : super(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16.px,
            fontWeight: FontWeight.w600,
          ),
        );

  EcoText.h4(
    String text, {
    Color color = Palette.D,
  }) : super(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12.px,
            fontWeight: FontWeight.w600,
          ),
        );

  EcoText.p(
    String text, {
    Color color = Palette.D,
    bool bold = false,
  }) : super(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12.px,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        );

  /// A p text with an icon
  static Wrap pIcon(
    String text,
    Widget icon, {
    Color color = Palette.D,
    bool end = false,
    bool bold = false,
  }) =>
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 5,
        children: [!end ? icon : EcoText.p(text, bold: bold), end ? icon : EcoText.p(text, bold: bold)],
      );
}
