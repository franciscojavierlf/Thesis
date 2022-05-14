import 'package:ecotoken/utils/theme.dart';
import 'package:flutter/material.dart';

class HubLayout extends StatelessWidget {
  final Widget body;
  final bool scroll;

  HubLayout({
    required this.body,
    this.scroll = true,
  });

  @override
  Widget build(BuildContext context) {
    final child = scroll
        ? SingleChildScrollView(
            child: body.paddingAll(25),
          )
        : body.paddingAll(25);

    return Scaffold(
      backgroundColor: Palette.lightBgColor,
      body: SafeArea(
        child: child,
      ),
    );
  }
}
